import subprocess
import numpy as np
import pandas as pd
import random
import ctypes
import time
import re
from multiprocessing import Process, Queue
from .assembler import TMIAssembler


class MUAFUD5005():
    def __init__(
        self,
        uuid, 
        gbs_path,
        clib,
        asm=None,
        dim=512,
        buff_size=2**22,
        debug=False,
        user_fclk_mhz=75
    ):
        # User-defined accelerator ID
        self.asm=asm
        self.uuid=uuid
        self.gbs_path=gbs_path
        self.debug=debug
        self.buff_size=buff_size
        self.dim=dim
        self.user_fclk_mhz=user_fclk_mhz
        # Get the bus ID of an accelerator card
        self.__get_bus_id__()
        # Program the card
        self.__program_afu__()
        # Check UUID
        self.__check_uuid__()
        # Set user clock
        self.__set_uclk__()
        # Load C-lib
        self.clib=clib
        # Get handle/control of AFU and DMA
        self.__init_afu__()
        # Allocate shared buffer
        self.__allocate_shared_buffer__()
        # Initialize ddr address data
        self.ddr_addresses = {}
        self.ddr_addr_span = (0,0)
        # Check dictionary used for light testing
        self.init_vals = {}
        
    def __set_uclk__(self):
        set_clk_str = f'userclk -B 0x{self.bus_id:02x} -H {self.user_fclk_mhz:5.3f} -L {round(self.user_fclk_mhz*1.0/2, 4):5.3f}'
        p = subprocess.Popen([set_clk_str], stdout=subprocess.PIPE, shell=True)
        result, err = p.communicate()
        print(result.decode())
        
    def __get_bus_id__(self):
        '''
        Get the bus ID of an attached D5005 card
        '''
        p = subprocess.Popen(['lspci | grep accel'], stdout=subprocess.PIPE, shell=True)
        result, err = p.communicate()
        bus_id = int(result.split(b' ')[0].split(b':')[0],base=16)
        if(self.debug):
            print(f"Accelerator card found w/ bus ID 0x{bus_id:02X}")
        self.bus_id=bus_id
    
    def __program_afu__(self):
        '''
        Program the AFU to the D5005 platform PR
        
        Intentionally not using the OPAE Python library 
        as it is not easy to setup on DevCloud :(
        '''
        p = subprocess.Popen([f'fpgasupdate {self.gbs_path} {self.bus_id:02x}:00.0'], stdout=subprocess.PIPE, shell=True)
        result, err = p.communicate()
        print(result.decode())
        if(self.debug):
            print(f"---- DEBUG: Programmed card w/ bus ID 0x{self.bus_id:02X}")
    
    def __check_uuid__(self):
        '''
        Check that the expected UUID is discovered by the DFL kernel
        '''
        p = subprocess.Popen([f'fpgainfo port'], stdout=subprocess.PIPE, shell=True)
        result, err = p.communicate()
        success = 0
        for line in result.split(b"\n"):
            line_trim = line.replace(b" ", b"")
            if(f"AcceleratorId:{self.uuid}" in str(line_trim)):
                success=1
                break
        if(success):
            if(self.debug):
                print(f"---- DEBUG: Found accelerator w/ UUID 0x{self.uuid}")
        else:
            raise RuntimeError(
                f"Could not find accelerator w/ UUID {self.uuid}"
            )
    
    def __init_afu__(self):
        '''
        Open AFU and DMA handles
        '''
        self.clib.open_afu_handle(self.uuid.encode('utf-8'))
        self.clib.open_dma_handle()
    
    def __get_instruction_ints__(self, tmi_memb_path):
        with open(tmi_memb_path,"r") as f:
            tmi_memb = f.readlines()
        int_instrs = []
        print_instrs = []
        for instr in tmi_memb:
            int_instr = instr.split('//')[0]
            int_instr = int_instr.replace(' ', "")
            if(int_instr != ""):
                print_instrs.append(int_instr)
                int_instr = int_instr.replace('_', '')
                instr_out = int(int_instr,2)
                int_instrs.append(instr_out)
        return print_instrs, int_instrs
    
    def __allocate_shared_buffer__(self):
        self.clib.allocate_shared_buffer(self.buff_size)

    def __configure_ddr_addresses__(self, ddr_addr_spec):
        '''
        Configure ddr addresses for TMI generation and DMA transactions
        '''
        # Generate ddr address strings for assembler
        ddr_addr_bits = ddr_addr_spec['DDR_addr_bits']
        ddr_offset    = ddr_addr_spec['DDR_offset']
        ddr_addresses_str = {}
        ddr_offset_tmp = ddr_offset
        keys = ['X_size','WK_size','WQ_size','WV_size','eM_size','eNW_size','A_size','B_size','O_size']
        for key in keys:
            key_out = key.replace("_size", "")
            val =  "{addr:0{fmt}b}".format(addr=ddr_offset_tmp, fmt=ddr_addr_bits)
            if(self.debug):
                print(f"---- DEBUG: Mapping {key_out:3} to ADDR 0b{val} in TMI.")
            ddr_addresses_str[key_out] = val
            ddr_offset_tmp += ddr_addr_spec[key]
        self.ddr_addr_span = (ddr_offset, ddr_offset_tmp)
        # Generate ddr address integers
        self.ddr_addresses = {}
        for key in ddr_addresses_str:
            ddr_addr = int(ddr_addresses_str[key], 2)
            self.ddr_addresses[key] = ddr_addr
            if(self.debug):
                val = "{addr:0{fmt}b}".format(addr=ddr_addr, fmt=ddr_addr_bits)
                print(f"---- DEBUG: Mapping {key:3} to ADDR 0b{val} in local object.".format())
        return ddr_addresses_str

    def program_tmi(self, ddr_addr_spec, tmi_asm, tmi_memb, tmi_offset, mmio_group=0x0):
        # Generate the address mapping
        ddr_addresses_str = self.__configure_ddr_addresses__(ddr_addr_spec)
        ddr_addr_bits = ddr_addr_spec['DDR_addr_bits']
        # Assemble the program
        asmbler = TMIAssembler(ddr_addresses_str, ddr_addr_bits)
        asmbler.assemble(tmi_asm, tmi_memb)
        # Convert the binary to data for OCM
        print_instrs, tmi_instrs = self.__get_instruction_ints__(tmi_memb)
        # Program OCM
        for idx,instr in enumerate(tmi_instrs):
            inst_mmio_offset = tmi_offset + (idx<<3)
            self.clib.mmioW64(inst_mmio_offset, mmio_group, instr)
        # Readback program memory and print
        if(self.debug):
            print(f'---- DEBUG: TMI LOADED')
            for idx,instr in enumerate(tmi_instrs):
                inst_mmio_offset = tmi_offset + (idx<<3)
                i_rd = self.clib.mmioR64(inst_mmio_offset, mmio_group)
                print(f"---- DEBUG: Checked instruction 0b{i_rd:064b} to MMIO OFFSET 0x{inst_mmio_offset:03X}")
    
    def __py_bytes_to_fpga_buff__(self, data_in):
        ct = (ctypes.c_uint8*len(data_in))
        buff = ct.from_buffer(data_in)
        self.clib.populate_buffer_bytes(buff, len(data_in))
    
    def __fpga_buff_to_py_bytes__(self, buff_size):
        ct = (ctypes.c_uint8*buff_size)
        ba = bytearray(buff_size)
        buff = ct.from_buffer(ba)
        self.clib.get_buffer_bytes(buff, buff_size)
        return buff
    
    def __poll_ready__(self, ready_offset, mmio_group, timeout):
        total_time = 0
        ext = 0
        time_start = time.time()
        while(total_time <= timeout and not ext):
            ext = self.clib.mmioR32(ready_offset, mmio_group)
            total_time = time.time() - time_start
        if(total_time==timeout):
            raise RuntimeError (
                "Timeout waiting for ready!"
            )
        else:
            return total_time
    
    # Should probably be a transaction class
    def __get_rand_tv__(self, ddr_addr_spec):
        rand_tv = bytearray()
        # Random input vectors
        X   = bytearray(random.getrandbits(8) for _ in range(ddr_addr_spec['X_size']))
        rand_tv += X
        WK  = bytearray(random.getrandbits(8) for _ in range(ddr_addr_spec['WK_size']))
        rand_tv += WK
        WQ  = bytearray(random.getrandbits(8) for _ in range(ddr_addr_spec['WQ_size']))
        rand_tv += WQ
        WV  = bytearray(random.getrandbits(8) for _ in range(ddr_addr_spec['WV_size']))
        rand_tv += WV
        eM  = bytearray(random.getrandbits(8) for _ in range(ddr_addr_spec['eM_size']))
        rand_tv += eM
        eNW = bytearray(random.getrandbits(8) for _ in range(ddr_addr_spec['eNW_size']))
        rand_tv += eNW
        A   = bytearray(0 for _ in range(ddr_addr_spec['A_size']))
        rand_tv += A
        B   = bytearray(0 for _ in range(ddr_addr_spec['B_size']))
        rand_tv += B
        O   = bytearray(0 for _ in range(ddr_addr_spec['O_size']))
        rand_tv += O
        if(self.debug):
            self.init_vals = {
                "X"   : X,
                "WK"  : WK,
                "WQ"  : WQ,
                "WV"  : WV,
                "eM"  : eM,
                "eNW" : eNW,
                "A"   : A,
                "B"   : B,
                "O"   : O
            }    
        return rand_tv

    def __check_rand_tv__(self, ddr_addr_spec, payload_size):
        contant_check_keys = ["X", "WK", "WQ", "eM", "eNW"]
        altered_check_keys = ["O"]
        for key in contant_check_keys:
            init_data = self.init_vals[key]
            base_addr = self.ddr_addresses[key]
            span = ddr_addr_spec[f"{key}_size"]
            self.clib.dma_fpga_to_host(base_addr, span, payload_size)
            rx_data = self.__fpga_buff_to_py_bytes__(span)
            if(rx_data != init_data):
                raise ValueError(
                    f"---- DEBUG: Input vector ({key}) was modified by program!"
                )
            elif(self.debug):
                print(f"---- DEBUG: Checked {key} input vector.")
        for key in altered_check_keys:
            init_data = self.init_vals[key]
            base_addr = self.ddr_addresses[key]
            span = ddr_addr_spec[f"{key}_size"]
            self.clib.dma_fpga_to_host(base_addr, span, payload_size)
            rx_data = self.__fpga_buff_to_py_bytes__(span)
            if(rx_data == init_data):
                raise ValueError(
                    f"---- DEBUG: Output/intermediate vector ({key}) was not modified by program!"
                )
            elif(self.debug):
                print(f"---- DEBUG: Checked {key} output/intermediate vector.")
        # TODO: Add more sophisticated checks here, all data can be queried as shown above

    def random_timed_test(self, ddr_addr_spec, start_offset, ready_offset, mmio_group, n=1, payload_size=2**22):
        '''
        Random test:
        - Loop n:
            - Load DDR4 shared buffer with random bytes
                - (1) X: 1 x dim
                - (2) WK, WQ, WV: dim x dim
                - (3) eM : 1 x dim
                - (4) eNW : 1 x dim
                - (5) A : 1 x dim
                - (6) B : 1 x dim
                - (7) O : 1 x dim
            - Write start
            - Poll ready
            - Copy to buffer
        '''
        timeout = 10*self.dim*self.dim*(1/(self.user_fclk_mhz*10**6))
        ret_dict = {
            "DMA Tx Time" : [],
            "DMA Rx Time" : [],
            "Core Time"   : []
        }
        for _ in range(n):
            # Populate py buffer
            rand_txn = self.__get_rand_tv__(ddr_addr_spec)
            # Populate random data into shared buffer
            self.__py_bytes_to_fpga_buff__(rand_txn)
            # Tx random data to FPGA
            time_start = time.time()
            self.clib.dma_host_to_fpga(self.ddr_addresses["X"], len(rand_txn), payload_size)
            ret_dict["DMA Tx Time"].append(time.time()-time_start)
            # Poll ready
            self.__poll_ready__(ready_offset, mmio_group, timeout)
            # Issue start
            self.clib.mmioW32(start_offset, mmio_group, 0x1)
            # Poll ready and capture time
            ret_dict["Core Time"].append(self.__poll_ready__(ready_offset, mmio_group, timeout))
            # FPGA to host buffer
            time_start = time.time()
            self.clib.dma_fpga_to_host(self.ddr_addresses["O"], ddr_addr_spec["O_size"], payload_size)
            ret_dict["DMA Rx Time"].append(time.time()-time_start)
            if(self. debug):
                self.__check_rand_tv__(ddr_addr_spec, payload_size)
                
        return pd.DataFrame.from_dict(ret_dict)
    
    def get_power(self):
        '''
        TODO: Use SDM mailbox? fpgainfo is slow
        '''
        p = subprocess.Popen(["fpgainfo power"], stdout=subprocess.PIPE, shell=True)
        result, err = p.communicate()
        return result
    
    def __execute_power__(self, start_offset, ready_offset, mmio_group, n_max, payload_size):
        '''
        Repeatedly execute the program without any profiling
        - procedure may be terminated by main thread during power profiling
        '''
        # Timeout increased as there may be bus contention while measuring power
        timeout = 20*self.dim*self.dim*(1/(self.user_fclk_mhz*10**6))
        TV = bytearray(random.getrandbits(8) for _ in range(self.buff_size))
        # Transfer entire buffer, and keep data for checking
        self.__py_bytes_to_fpga_buff__(TV)
        # Tx shared buffer to FPGA
        self.clib.dma_host_to_fpga(self.ddr_addresses["X"], self.buff_size, payload_size)
        for _ in range(n_max):
            # Poll ready
            self.__poll_ready__(ready_offset, mmio_group, timeout)
            # Issue start
            self.clib.mmioW32(start_offset, mmio_group, 0x1)
            # Poll ready and capture time
            self.__poll_ready__(ready_offset, mmio_group, timeout)
            # FPGA to host buffer
            # self.clib.dma_fpga_to_host(self.ddr_addresses["X"], self.buff_size, payload_size)
            
    def __process_power_data__(self, pow_datum, active=False):
        '''
        Processes voltage regulator data retuned by Board Management Controller
        '''
        
        bus_id_str = f"s:b:d:f{self.bus_id:2X}:00:0"
        iv_dict = {
            "12v Backplane Current": [],
            "12v Backplane Voltage": [],
            "1.8v Voltage"         : [],
            "1.8v Current"         : [],
            "3.3v Voltage"         : [],
            "3.3v Current"         : [],
            "FPGA Core Voltage"    : [],
            "FPGA Core Current"    : [],
            "VCCR Voltage"         : [],
            "VCCT Voltage"         : [],
            "VCCR Current"         : [],
            "VCCT Current"         : [],
            "12v AUX Current"      : [],
            "12v AUX Voltage"      : [],
            "VCCERAM Current"      : [],
            "VCCERAM Voltage"      : []
        }
        for pow_data in pow_datum:
            pow_data = str(pow_data)
            p_boards = pow_data.split("//****** POWER ******//")[1:]
            for brd in p_boards:
                if bus_id_str in brd:
                    rel_meas = brd
                    break
            for key in iv_dict.keys():
                tmp = brd.split(key)[1]
                tmp = tmp.split(":")[1]
                tmp = tmp.strip(" ")
                tmp = tmp.split("Volts")[0].split("Amps")[0]
                iv_dict[key].append(float(tmp))

        p_dict = {}
        for key in iv_dict.keys():
            if("Voltage" in key):
                i = np.array(iv_dict[key.replace("Voltage", "Current")])
                v = np.array(iv_dict[key])
                p_dict[key.replace("Voltage", "Avg Power")] =  [np.average(i*v)]
                p_dict[key.replace("Voltage", "Peak Power")] = [np.max(i*v)]

        total_avg_power = 0
        for key in p_dict:
            if("Avg" in key):
                total_avg_power += p_dict[key][0]
        p_dict["Total Avg Power"] = [total_avg_power]
        p_dict["Core Active"] = [active]
        return pd.DataFrame.from_dict(p_dict)
        
    def random_power_test(self, start_offset, ready_offset, mmio_group, n, payload_size):
        n_max = n*1000
        timeout = 20*self.dim*self.dim*(1/(self.user_fclk_mhz*10**6))
        pow_noload = []
        pow_load = []
        # Gather power under no load
        for i in range(n):
            pow_noload.append(self.get_power())
        # Post-process
        df_pow_noload = self.__process_power_data__(pow_noload, active=False) 
        # Initialize test process
        p_pow = Process(target=self.__execute_power__,
                        args=(start_offset, ready_offset, mmio_group, n_max, payload_size))
        # Start test process
        p_pow.start()
        # Measure power under load
        for i in range(n):
            pow_load.append(self.get_power())
        p_pow.terminate()
        # Post-process
        df_pow_load = self.__process_power_data__(pow_load, active=True)
        # Concatonate results into dataframe
        return pd.concat([df_pow_noload, df_pow_load])
    
    def close_afu(self):
        self.clib.close_all()