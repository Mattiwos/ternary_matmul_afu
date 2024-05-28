import subprocess
import numpy as np
import pandas as pd
import random
import ctypes
import time
from multiprocessing import Process, Queue

class MUAFUD5005():
    def __init__(
        self,
        clib,
        uuid, 
        gbs_path,
        mem_map,
        dim=512,
        buff_size=2**22,
        debug=False,
        user_fclk_mhz=75
    ):
        # User-defined accelerator ID
        self.clib=clib
        self.uuid=uuid
        self.gbs_path=gbs_path
        self.debug=debug
        self.buff_size=buff_size
        self.mem_map=mem_map
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
    
    def __set_uclk__(self):
        set_clk_str = f'userclk -B 0x{self.bus_id:02X} -H {self.user_fclk_mhz:5.3f} -L {round(self.user_fclk_mhz*1.0/2, 4):5.3f}'
        p = subprocess.Popen([set_clk_str], stdout=subprocess.PIPE, shell=True)
        result, err = p.communicate()
    
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
        p = subprocess.Popen([f'fpgasupdate {self.gbs_path} {self.bus_id}'], stdout=subprocess.PIPE, shell=True)
        result, err = p.communicate()
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

    def configure_tmi(self, tmi_memb_path, tmi_offset, mmio_group, check=False):
        print_instrs, tmi_instrs = self.__get_instruction_ints__(tmi_memb_path)
        for idx,instr in enumerate(tmi_instrs):
            inst_mmio_offset = tmi_offset + (idx<<3)
            self.clib.mmioW64(inst_mmio_offset, mmio_group, instr)
        # Readback program memory
        if(check):
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
        time_start = time.time()
        total_time = 0
        ext = 0
        while(total_time <= timeout and not ext):
            ext = self.clib.mmioR32(ready_offset, mmio_group)
            total_time = time.time() - time_start
        if(total_time==timeout):
            raise RuntimeError (
                "Timeout waiting for ready!"
            )
        else:
            return total_time
    
    def random_test(self, start_offset, ready_offset, mmio_group, n=1, payload_size=2**22):
        x_size = self.dim*self.dim
        timeout = 100*x_size*(1/(self.user_fclk_mhz*10**6))
        o_size = self.dim
        ret_dict = {
            "DMA Tx Time" : [],
            "DMA Rx Time" : [],
            "Core Time"   : [],
            "Xs"          : [],
            "Os"          : []
        }
        for _ in range(n):
            # Transfer X - ternary weight matrix
            rand_x = bytearray(random.getrandbits(2) for _ in range(x_size))
            ret_dict["Xs"].append(rand_x)
            # Populate random data into buffer
            self.__py_bytes_to_fpga_buff__(rand_x)
            # Tx random X to FPGA
            time_start = time.time()
            self.clib.dma_host_to_fpga(self.mem_map["X"], x_size, payload_size)
            ret_dict["DMA Tx Time"].append(time.time()-time_start)
            # Poll ready
            self.__poll_ready__(ready_offset, mmio_group, timeout)
            # Issue start
            self.clib.mmioW32(start_offset, mmio_group, 0x1)
            # Poll ready and capture time
            ret_dict["Core Time"].append(self.__poll_ready__(ready_offset, mmio_group, timeout))
            # FPGA to host buffer
            time_start = time.time()
            self.clib.dma_fpga_to_host(self.mem_map["O"], o_size, payload_size)
            ret_dict["DMA Rx Time"].append(time.time()-time_start)
            # Hostbuffer to pybytes
            o = self.__fpga_buff_to_py_bytes__(o_size)
            ret_dict["Os"].append(o)
            
        return pd.DataFrame.from_dict(ret_dict)