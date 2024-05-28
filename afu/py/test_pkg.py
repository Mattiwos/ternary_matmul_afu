from mu_afu_d5005 import MUAFUClib, MUAFUD5005

if __name__ == '__main__':
    uuid = "bf8a475d-817f-4bec-9e87-7816be249566"
    gbs_path = "../build_synth/mu_afu_S10.gbs"   
    
    tmi_base_offset = 0x1000
    start_offset    = 0x400
    ready_offset    = 0x404
    mmio_grp        = 0x0
    
    user_fclk_mhz = 60
    dim = 512
    
    # Copied from modified assembly. TODO: use the address map as an input to assembly.
    ddr_addrs_strs = {
        'X'  :'000000000000000000000000000000000',
        'WK' :'000000000000001000000000000000000',
        'WQ' :'000000000000001000000001000000000',
        'WV' :'000000000000001000000010000000000',
        'eM' :'000000000000001000000011000000000',
        'eNW':'000000000000001000000100000000000',
        'A'  :'000000000000001000000101000000000',
        'B'  :'000000000000001000000110000000000',
        'O'  :'000000000000001000000111000000000'
    }
    o_size = dim
    ddr_addresses = {}
    all_addrs = []
    for key in ddr_addrs_strs:
        ddr_addr = int(ddr_addrs_strs[key], 2)
        ddr_addresses[key] = ddr_addr
        all_addrs.append(ddr_addr)
    
    # Calculate shared buffer size
    #   Assumes all vectors are stored contiguously
    min_addr = min(all_addrs)
    max_addr = max(all_addrs)
    buffer_size = max_addr - min_addr + o_size
    
    tmi_memb_path = "./process.memb"
    
    # Instantiate clib class
    clib = MUAFUClib(
        clib_dir="../cpp",
        quiet_comp=True,
        debug_clib=False
    )
    
    # Instantiate afu class
    afu = MUAFUD5005(
        clib=clib,
        uuid=uuid, 
        gbs_path=gbs_path,
        dim=dim,
        buff_size=buffer_size,
        mem_map=ddr_addresses,
        debug=True,
        user_fclk_mhz=user_fclk_mhz
    )
    
    # Program the tmi RAM
    afu.configure_tmi(
        tmi_memb_path, 
        tmi_base_offset, 
        mmio_grp, 
        check=True)
    
    # Run a random test
    #   (1) Fill buffer with random data - time DDR4 Tx
    #   (2) Issue a start - time compute start
    #   (3) Poll ready - time compute stop
    #   (4) Capture fields - time DDR4 Rx
    print(afu.random_test(start_offset, ready_offset, mmio_grp, n=20, payload_size=2**22))
    
    
    