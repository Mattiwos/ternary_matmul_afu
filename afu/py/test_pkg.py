from mu_afu_d5005 import MUAFUClib, MUAFUD5005

if __name__ == '__main__':
    # Application settings
    uuid            = "bf8a475d-817f-4bec-9e87-7816be249566"
    gbs_path        = "../build_synth/mu_afu_S10.gbs"   
    tmi_asm         = "../../tmi/process.tmi"
    
    # HW configuration
    tmi_base_offset = 0x1000
    start_offset    = 0x400
    ready_offset    = 0x404
    mmio_grp        = 0x0
    ddr_addr_bits   = 33
    user_fclk_mhz   = 60
    dim             = 512
    
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
        debug=True,
        user_fclk_mhz=user_fclk_mhz
    )
        
    # Program the TMI to on-chip RAM
    afu.program_tmi(
        mu_ddr_addr_spec,
        tmi_asm,
        tmi_memb, 
        tmi_base_offset, 
        mmio_grp, 
        check=True
    )
    
    # Run n random test
    #   (1) Fill buffer with random data - time DDR4 Tx
    #   (2) Issue a start - time compute start
    #   (3) Poll ready - time compute stop
    #   (4) Capture fields - time DDR4 Rx
    print(afu.random_test(mu_ddr_addr_spec, start_offset, ready_offset, mmio_grp, n=20, payload_size=2**22))
    
    afu.close_afu()
    