from mu_afu_d5005 import MUAFUClib, MUAFUD5005
from math import log2, ceil
import numpy as np
import argparse

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description=
            'This application will (1) update the FPGA PR with the core bitstream '
            'defined by the input .gbs file (2) assemble and program the core instruction memory '
            '(3) perform the program n-times populating new test-vectors each time. '
            'In (3), the execution time of the program is recorded. Finally, the '
            'application will (4) spawn a subprocess to continuously operate the core '
            'while the main thread records the power draw of the D5005 platform. '
            'All test vectors are randomized, and no functional verification is performed.'
    )
    parser.add_argument('--gbs', required=True, dest='gbs_path', type=str,
        help='path to green bitstream (.gbs) programming file.')
    
    parser.add_argument('--tmi_asm', required=True, dest='tmi_asm', type=str,
        help='path to assembly file for the core.')
    
    parser.add_argument('--num_runs_time', default = 100, dest='num_runs_time', type=int,
        help='integer number of profiling runs for core runtime analysis.')
    
    parser.add_argument('--num_runs_pwr', default = 1000, dest='num_runs_pwr', type=int,
        help='integer number of profiling runs for power analysis.')
    
    parser.add_argument('--dim', required=True, dest='dim', type=int,
        help='integer dimension of input vector.')
    
    parser.add_argument('--debug', default=False, dest='debug', type=bool,
        help='integer dimension of input vector.')
    
    parser.add_argument('--fclk_mhz', default=50, dest='fclk_mhz', type=bool,
        help='integer dimension of input vector.')
    
    args            = parser.parse_args()
    dim             = args.dim
    gbs_path        = args.gbs_path
    tmi_asm         = args.tmi_asm
    num_runs_time   = args.num_runs_time
    num_runs_pwr    = args.num_runs_pwr
    debug           = args.debug
    user_fclk_mhz   = args.fclk_mhz
    
    # HW configuration
    uuid            = "bf8a475d-817f-4bec-9e87-7816be249566"
    tmi_base_offset = 0x1000
    start_offset    = 0x400
    ready_offset    = 0x404
    mmio_grp        = 0x0
    ddr_addr_bits   = 33
    
    # Options
    mu_ddr_offset   = 0
    tmi_memb        = "./process.memb"
    
    # DDR dimension specifications
    mu_ddr_addr_spec = {
        'DDR_addr_bits' : ddr_addr_bits,
        'DDR_offset'    : mu_ddr_offset,
        'X_size'        : dim,
        'WK_size'       : dim*dim,
        'WQ_size'       : dim*dim,
        'WV_size'       : dim*dim,
        'eM_size'       : dim,
        'eNW_size'      : dim,
        'A_size'        : dim,
        'B_size'        : dim,
        'O_size'        : dim
    }
    
    # Caluclate shared buffer size
    buffer_size=0
    for key in mu_ddr_addr_spec:
        if("_size" in key):
            buffer_size+=mu_ddr_addr_spec[key]
    buffer_size = int(2**(ceil(log2(buffer_size))))
    
    # Instantiate clib class
    clib = MUAFUClib(
        clib_dir="../cpp",
        quiet_comp=True,
        # Enable this to see print statements from C-drivers
        debug_clib=False
    ) 
    
    # Instantiate afu class
    afu = MUAFUD5005(
        clib=clib,
        uuid=uuid, 
        gbs_path=gbs_path,
        dim=dim,
        buff_size=buffer_size,
        debug=debug,
        user_fclk_mhz=user_fclk_mhz
    )
        
    # Program the TMI to on-chip RAM
    afu.program_tmi(
        mu_ddr_addr_spec,
        tmi_asm,
        tmi_memb, 
        tmi_base_offset, 
        mmio_grp
    )
    
    print(f"Profiling core runtime...")
    # Run n random test
    #   (1) Fill buffer with random data - time DDR4 Tx
    #   (2) Issue a start - time compute start
    #   (3) Poll ready - time compute stop
    #   (4) Capture fields - time DDR4 Rx
    df_time = afu.random_timed_test(mu_ddr_addr_spec, start_offset, 
                                    ready_offset, mmio_grp, n=num_runs_time, 
                                    payload_size=2**22)
    if(debug):
        print(df_time)
    
    print(f"Profiling core power...")
    # Measure power
    #   (1) Spawn worker process
    #       - Transact random data and continuously start/poll core
    #   (1) Query power sensors from BMC
    #       - Thus is quite slow, physical power measurement would be better
    #   (2) Post process data
    df_power = afu.random_power_test(start_offset, ready_offset, mmio_grp, 
                                     n=num_runs_pwr, payload_size=2**22)
    if(debug):
        print(df_power)
    
    # Print key results
    print("********* RESULTS ********* ")
    avg_core_time = df_time["Core Time"].mean()
    print(f"      AVG CORE TIME : {avg_core_time:05.4f} s")
    ddr4_total_time = df_time["DMA Tx Time"].values + df_time["DMA Rx Time"].values
    avg_ddr4_time = np.mean(ddr4_total_time)
    print(f"       AVG DMA TIME : {avg_ddr4_time:05.4f} s")
    avg_core_active_power = df_power[df_power["Core Active"]==True]["FPGA Core Avg Power"].values[0]
    print(f"AVG CORE ACTIVE PWR : {avg_core_active_power:05.4f} W")
    avg_core_idle_power = df_power[df_power["Core Active"]==False]["FPGA Core Avg Power"].values[0]
    print(f"  AVG CORE IDLE PWR : {avg_core_idle_power:05.4f} W")
    
    # Close the AFU handles (afu and dma) with this call
    afu.close_afu()
    