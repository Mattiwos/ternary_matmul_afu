from opae import fpga
import subprocess
import ctypes
import os
import inspect
from time import time, sleep
import random
from multiprocessing import Process, Queue
import numpy as np
from bitstring import BitArray

def get_bus_id():
    p = subprocess.Popen(['lspci | grep accel'], stdout=subprocess.PIPE, shell=True)
    result, err = p.communicate()
    bus_id = int(result.split(" ")[0].split(":")[0],16)
    print("Card detected w/ BUS_ID 0x{:02X}".format(bus_id))
    return bus_id

def program_gbs(bus_id, gbs_file, uuid):
    tokens = fpga.enumerate(type=fpga.DEVICE, bus=bus_id)
    assert tokens, "Could not enumerate device on bus: {}".format(bus_id)
    print("Reconfiguring PR...")
    with open(gbs_file, 'rb') as fd, fpga.open(tokens[0]) as device:
        device.reconfigure(0, fd)

def get_git_top():
    p = subprocess.Popen(['git rev-parse --show-toplevel'], stdout=subprocess.PIPE, shell=True)
    result, err = p.communicate()
    return result.strip("\n")

def set_uclk(fclk, bus_id):
    set_clk_str = 'userclk -B 0x{:02X} -H {:5.3f} -L {:5.3f}'.format(bus_id, fclk, round(fclk*1.0/2, 4))
    p = subprocess.Popen([set_clk_str], stdout=subprocess.PIPE, shell=True)
    result, err = p.communicate()
    print(result)

def load_c_libs(debug_dma=False, quiet=False):
    if(quiet):
        verb = ""
    else:
        verb = "VERBOSE=1"
    if(debug_dma):
        debug_flag = "FPGA_DMA_DEBUG=1"
    else:
        debug_flag = ""
    matmul_c_lib_dir  = "{}/cpp/".format(git_top)
    fpga_dma_path = "{}/fpga_dma.so".format(matmul_c_lib_dir)
    matmul_c_lib_path = "{}/matmul_c_lib.so".format(matmul_c_lib_dir)
    p = subprocess.Popen(['make -C {} clean'.format(matmul_c_lib_dir)], stdout=subprocess.PIPE, shell=True)
    result, err = p.communicate()
    p = subprocess.Popen(['make -C {} {} {}'.format(matmul_c_lib_dir, debug_flag, verb)], stdout=subprocess.PIPE, shell=True)
    result, err = p.communicate()
    assert(os.path.exists(matmul_c_lib_path))
    assert(os.path.exists(fpga_dma_path))
    ctypes.CDLL(fpga_dma_path, mode = ctypes.RTLD_GLOBAL)

    matmul_c_lib = ctypes.CDLL(matmul_c_lib_path)

    matmul_c_lib.open_afu_handle.restype = ctypes.c_bool
    matmul_c_lib.open_afu_handle.argtypes = [
        ctypes.c_char_p
    ]

    matmul_c_lib.allocate_buffer.restype = ctypes.c_bool
    matmul_c_lib.allocate_buffer.argtypes = [
        ctypes.c_uint64, # BUFFER SIZE BYTES
    ]
    
    matmul_c_lib.dma_host_to_fpga.restype = ctypes.c_bool
    matmul_c_lib.dma_host_to_fpga.argtypes = [
        ctypes.c_uint64, # FPGA ADDRESS to TRANSFER BUFFER TO
        ctypes.c_uint64  # CHUNK SIZE
    ]

    matmul_c_lib.dma_fpga_to_host.restype = ctypes.c_bool
    matmul_c_lib.dma_fpga_to_host.argtypes = [
        ctypes.c_uint64, # FPGA ADDRESS to TRANSFER BUFFER FROM
        ctypes.c_uint64  # CHUNK SIZE
    ]
    
    matmul_c_lib.mmioW64.restype = ctypes.c_bool
    matmul_c_lib.mmioW64.argtypes = [
        ctypes.c_uint64, # MMIO Offset
        ctypes.c_uint32, # MMIO Num/IDX
        ctypes.c_uint64  # MMIO Data
    ]

    matmul_c_lib.mmioR64.restype = ctypes.c_uint64
    matmul_c_lib.mmioR64.argtypes = [
        ctypes.c_uint64, # MMIO Offset
        ctypes.c_uint32, # MMIO Num/IDX
    ]

    matmul_c_lib.mmioW32.restype = ctypes.c_bool
    matmul_c_lib.mmioW32.argtypes = [
        ctypes.c_uint64, # MMIO Offset
        ctypes.c_uint32, # MMIO Num/IDX
        ctypes.c_uint32  # MMIO Data
    ]

    matmul_c_lib.mmioR32.restype = ctypes.c_uint64
    matmul_c_lib.mmioR32.argtypes = [
        ctypes.c_uint64, # MMIO Offset
        ctypes.c_uint32  # MMIO Num/IDX
    ]
    
    matmul_c_lib.open_dma_handle.restype = ctypes.c_bool
    matmul_c_lib.free_buffer.restype = ctypes.c_bool
    matmul_c_lib.reset_afu.restype = ctypes.c_bool
    matmul_c_lib.close_all.restype = ctypes.c_bool
    
    return matmul_c_lib

def dma_transact(handle):
    buff_addr = ctypes.c_uint64(buff.io_address)


def run_core(matmul_c_lib, start_addr, ready_addr, itr=1000, mmio_group=0x0):
    for i in range(itr):
        assign_start(matmul_c_lib, 1, mmio_group, start_addr)
        assign_start(matmul_c_lib, 0, mmio_group, start_addr)
        poll_ready(matmul_c_lib, mmio_group, ready_addr)

def open_afu(matmul_c_lib, uuid):
    matmul_c_lib.open_afu_handle(uuid.upper())

def py_bytes_to_fpga_buff(matmul_c_lib, data_in):
    ct = (ctypes.c_uint8*len(data_in))
    buff = ct.from_buffer(data_in)
    matmul_c_lib.populate_buffer_bytes(buff, len(data_in))
    return buff

def fpga_buff_to_py_bytes(matmul_c_lib, buff_size, buff=None):
    if(buff==None):
        ct = (ctypes.c_uint8*buff_size)
        ba = bytearray(buff_size)
        buff = ct.from_buffer(ba)
    matmul_c_lib.get_buffer_bytes(buff, buff_size)
    return buff

def run_dma_check_random(matmul_c_lib, buff_size, debug=False):
    # POPULATE RANDOM TEST DATA INTO BUFFER
    print("Running random DMA transfer...")

    # POPULATE DMA SHARED BUFFER
    data_in = bytearray(random.getrandbits(8) & 0x3 for _ in xrange(buff_size))
    buff = py_bytes_to_fpga_buff (
        matmul_c_lib,
        data_in
    )
    
    # FOR CHECKS
    if(check_dma):
        in_ba = (bytearray(buff))

    # TRANSACT TO FPGA
    if (matmul_c_lib.dma_host_to_fpga(0x00000000, 2**12)):
        matmul_c_lib.close_all()
        raise RuntimeError(
            "Couldn't transfer to FPGA."
        )

    # TRANSACT FROM FPGA
    if (matmul_c_lib.dma_fpga_to_host(0x00000000, 2**12)):
        matmul_c_lib.close_all()
        raise RuntimeError(
            "Couldn't transfer from FPGA."
        )

    # CAPTURE BUFFER CONTENTS
    buff = fpga_buff_to_py_bytes(matmul_c_lib, buff_size, buff)

    # FOR CHECKS
    if(check_dma):
        out_ba = (bytearray(buff))
        if(in_ba != out_ba):
            matmul_c_lib.close_all()
            raise RuntimeError(
                "Couldn't transfer from FPGA."
            )
        else:
            print("DMA GOOD!")

    print("Random DMA transfer successful!")

def get_power(delay=0.2):
    '''
    TODO: Use SDM mailbox? fpgainfo is slow
    '''
    sleep(delay)
    p = subprocess.Popen(["fpgainfo power"], stdout=subprocess.PIPE, shell=True)
    result, err = p.communicate()
    return result

def get_thermal(q_p):
    therm_arr =[]
    q_p.get()
    while(q_p.empty()!= "done"):
        p = subprocess.Popen(["fpgainfo temp"], stdout=subprocess.PIPE, shell=True)
        result, err = p.communicate()
        therm_arr.append(result)
    q_p.put(therm_arr)

def poll_ready(matmul_c_lib, mmio_group, ready_offst, timeout = 100000):
    timeout = 1000000
    ext = 0
    while(ext != 1):
        ext = matmul_c_lib.mmioR32(ctypes.c_uint64(ready_offst), ctypes.c_uint32(mmio_group))
        timeout -= 1
        if(timeout == 0 or ext==0x7FFFFFFF):
            matmul_c_lib.close_all()
            raise RuntimeError(
                "AFU was never ready for transaction ext {:08x}!".format(ext)
            )
        continue

def assign_start(matmul_c_lib, val, mmio_group, start_offst, timeout = 100000):
    if(matmul_c_lib.mmioW32(ctypes.c_uint64(start_offst), ctypes.c_uint32(mmio_group), ctypes.c_uint32(val))):
        matmul_c_lib.close_all()
        raise RuntimeError(
            "Could not start AFU!"
        )

def run_matmul_test(matmul_c_lib, buff_size, n_tests,
    start_addr, ready_addr, mmio_group=0x1, matmul_base_addr=0x0, timer=False, profile=False):

    max_payload = 2**22 # From the streaming DMA doc
    payload = buff_size if buff_size < max_payload else max_payload

    if(timer):
        meas_d = {
            "DMA_Tx_ms"      : [],
            "DMA_Rx_ms"      : [],
            "CORE_ms"        : [],
        }

    # Generate and populate random data into buffer - not included in perf
    data_in = bytearray(random.getrandbits(8) & 0x3 for _ in xrange(buff_size))
    buff = py_bytes_to_fpga_buff (
        matmul_c_lib,
        data_in
    )

    # These are post-processed after the test completes
    for test_itr in range(n_tests):
        
        if(timer):
            time_start = time()
        # Tx DATA - Random for now
        if (matmul_c_lib.dma_host_to_fpga(matmul_base_addr, payload)):
            matmul_c_lib.close_all()
            raise RuntimeError(
                "Couldn't transfer to FPGA."
            )
        if(timer):
            time_stop = time()
            meas_d["DMA_Tx_ms"].append(time_stop-time_start)

        poll_ready(matmul_c_lib, mmio_group, ready_addr)
        print("Starting...")
        assign_start(matmul_c_lib, 1, mmio_group, start_addr)
        if(timer):
            time_start = time()
        assign_start(matmul_c_lib, 0, mmio_group, start_addr)
        poll_ready(matmul_c_lib, mmio_group, ready_addr)
        if(timer):
            time_stop  = time()
        meas_d["CORE_ms"].append(time_stop-time_start)

        # Rx DATA
        if(timer):
            time_start = time()
        if (matmul_c_lib.dma_fpga_to_host(matmul_base_addr, payload)):
            matmul_c_lib.close_all()
            raise RuntimeError(
                "Couldn't transfer from FPGA."
            )
            matmul_c_lib.close_all()
        if (matmul_c_lib.dma_fpga_to_host(matmul_base_addr, payload)):
            matmul_c_lib.close_all()
            raise RuntimeError(
                "Couldn't transfer from FPGA."
            )
            matmul_c_lib.close_all()
        if(timer):
            time_stop = time()
            meas_d["DMA_Rx_ms"].append(time_stop-time_start)

        if(not profile):
            buff = fpga_buff_to_py_bytes(matmul_c_lib, buff_size, None)
            dout = (bytearray(buff))
            with open("mat_out.txt", "w") as f:
                for idx in range(int(len(dout))):
                    if(dout[idx] != data_in[idx]):
                        f.write("| 0x{:02x}, 0x{:02x} |".format(int(data_in[idx]),int(dout[idx])))
                    
            # When we are not profiling send new data
            data_in = bytearray(random.getrandbits(8) & 0x3 for _ in xrange(buff_size))
            buff = py_bytes_to_fpga_buff (
                matmul_c_lib,
                data_in
            )

    if(timer):
        return meas_d

def get_instruction_ints(tmi_memb_path):
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
            instr_out = BitArray(bin=int_instr).uint
            int_instrs.append(instr_out)
    return print_instrs, int_instrs

def configure_tmi(matmul_c_lib, tmi_memb_path, tmi_offset, tmi_mmio_group, debug=False):
    print_instrs, tmi_instrs = get_instruction_ints(tmi_memb_path)
    for idx,instr in enumerate(tmi_instrs):
        inst_mmio_offset = tmi_offset + (idx<<3)
        matmul_c_lib.mmioW64(ctypes.c_uint64(inst_mmio_offset), ctypes.c_uint32(tmi_mmio_group), ctypes.c_uint64(instr))
    # Readback program memory
    if(debug):
        for idx,instr in enumerate(tmi_instrs):
            inst_mmio_offset = tmi_offset + (idx<<3)
            i_rd = matmul_c_lib.mmioR64(ctypes.c_uint64(inst_mmio_offset), ctypes.c_uint32(tmi_mmio_group))
            print("---- DEBGUG: Checked 0b{:064b} to MMIO OFFSET 0x{:03X}".format(i_rd, inst_mmio_offset))

def process_power_meas(ret_str_lst, bus_id):
    bus_id_str = "PCIe s:b:d:f                        : 0000:{:2X}:00:0".format(bus_id)
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
    for ret_str in ret_str_lst:
        p_boards = ret_str.split("//****** POWER ******//")[1:]
        for brd in p_boards:
            if(bus_id_str in brd):
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
            p_dict[key.replace("Voltage", "Avg Power")] = np.average(i*v)

    total_avg_power = 0
    for key in p_dict:
        total_avg_power += p_dict[key]
    p_dict["Card Avg Power"] = total_avg_power

    return p_dict

if __name__ == '__main__':

    # CONFIGURATION
    fclk           = 75 # in MHz
    check_dma      = False
    debug_dma      = False
    n_tests        = 100
    make_lib_quiet = True
    
    # SET TMI FILE RELATIVE TO GIT TOP
    tmi_memb_path  = "hw/rtl/ternary_matmul/tmi/process.memb"

    # AFU IO
    uuid = "bf8a475d-817f-4bec-9e87-7816be249566"
    
    # FIXED MATRIX DIMENSION
    matdim = 512
    
    # HOST-FPGA SHARED BUFFER SIZE
    buff_size = 2*matdim*matdim

    # AFU MMAP
    TMI   = 0x1000
    READY = 0x500
    START = 0x400

    # PGM PR
    git_top  = get_git_top()
    gbs_file = "/home/u204427/ternary_matmul_afu/build_synth/ternary_matmul_S10.gbs"
    # gbs_file = "{}/build_synth/ternary_matmul_S10.gbs".format(git_top)

    # GET DARBY BUSID
    bus_id = get_bus_id()
    
    # PGM GBS
    program_gbs(bus_id, gbs_file, uuid)

    # IMPORT C-LIB
    matmul_c_lib = load_c_libs(debug_dma=debug_dma)
    
    # # SET CLK
    set_uclk(fclk, bus_id)

    # OPEN AFU - reset automatically performed here
    if (open_afu(matmul_c_lib, uuid)):
        matmul_c_lib.close_all()
        raise RuntimeError(
            "AFU failed to init."
        )

    # OPEN DMA
    if (matmul_c_lib.open_dma_handle()):
        matmul_c_lib.close_all()
        raise RuntimeError(
            "DMA failed to init."
        )

    # GET SHARED BUFFER
    if (matmul_c_lib.allocate_buffer(buff_size)):
        matmul_c_lib.close_all()
        raise RuntimeError(
            "Couldn't init a shared buffer."
        )

    # PROGRAM TMI VIA MMIO
    tmi_memb_full_path = "{}/{}".format(git_top, tmi_memb_path)
    configure_tmi(matmul_c_lib, tmi_memb_full_path, TMI, 0x0, debug=True)

    run_dma_check_random(matmul_c_lib, buff_size, debug=True)
    meas_d = run_matmul_test(matmul_c_lib, buff_size, n_tests, START, READY, 0x0, 0x0, True)

    # print(meas_d)
    avg_dram_t = np.average(np.array(meas_d["DMA_Tx_ms"]) + np.array(meas_d["DMA_Rx_ms"]))
    avg_core_t = np.average(np.array(meas_d["CORE_ms"]))
    print("avg_dram_tx time (ms): {:5f}".format(avg_dram_t * 1000 ))
    print("avg_core_t  time (ms): {:5f}".format(avg_core_t * 1000 ))    

    pow_noload = []
    pow_load = []

    for i in range(100):
        pow_noload.append(get_power())

    p_pow = Process(target=run_matmul_test, args=(matmul_c_lib, buff_size, 1000000, START, READY, 0x0, 0x0, False, True))
    p_pow.start()
    for i in range(100):
        pow_load.append(get_power())
    
    p_pow.terminate()

    # WRAP UP
    # Will print errors if shared buffer is already free (this is okay as errors are handled in C)
    if ( matmul_c_lib.close_all()):
        raise RuntimeError(
            "AFU did not close properly!"
        )

    p_pow.terminate()
    p_dict_nold = process_power_meas(pow_noload, bus_id)
    print(p_dict_nold)
    p_dict_ld = process_power_meas(pow_load, bus_id)
    print(p_dict_ld)
    for key in p_dict_nold.keys():
        print("{}: LD {:5.3f}, NLD {:5.3f}".format(key, p_dict_ld[key], p_dict_nold[key]))

    print(meas_d)
