	matmul_afu_system_fixed u0 (
		.avmm_mmio_address                (_connected_to_avmm_mmio_address_),                //   input,   width = 48,          avmm_mmio.address
		.avmm_mmio_writedata              (_connected_to_avmm_mmio_writedata_),              //   input,   width = 64,                   .writedata
		.avmm_mmio_byteenable             (_connected_to_avmm_mmio_byteenable_),             //   input,    width = 8,                   .byteenable
		.avmm_mmio_write                  (_connected_to_avmm_mmio_write_),                  //   input,    width = 1,                   .write
		.avmm_mmio_read                   (_connected_to_avmm_mmio_read_),                   //   input,    width = 1,                   .read
		.avmm_mmio_readdata               (_connected_to_avmm_mmio_readdata_),               //  output,   width = 64,                   .readdata
		.avmm_mmio_readdatavalid          (_connected_to_avmm_mmio_readdatavalid_),          //  output,    width = 1,                   .readdatavalid
		.avmm_mmio_waitrequest            (_connected_to_avmm_mmio_waitrequest_),            //  output,    width = 1,                   .waitrequest
		.avmm_mmio_burstcount             (_connected_to_avmm_mmio_burstcount_),             //   input,    width = 1,                   .burstcount
		.ddr4a_master_dma_waitrequest     (_connected_to_ddr4a_master_dma_waitrequest_),     //   input,    width = 1,   ddr4a_master_dma.waitrequest
		.ddr4a_master_dma_readdata        (_connected_to_ddr4a_master_dma_readdata_),        //   input,  width = 512,                   .readdata
		.ddr4a_master_dma_readdatavalid   (_connected_to_ddr4a_master_dma_readdatavalid_),   //   input,    width = 1,                   .readdatavalid
		.ddr4a_master_dma_burstcount      (_connected_to_ddr4a_master_dma_burstcount_),      //  output,    width = 3,                   .burstcount
		.ddr4a_master_dma_writedata       (_connected_to_ddr4a_master_dma_writedata_),       //  output,  width = 512,                   .writedata
		.ddr4a_master_dma_address         (_connected_to_ddr4a_master_dma_address_),         //  output,   width = 33,                   .address
		.ddr4a_master_dma_write           (_connected_to_ddr4a_master_dma_write_),           //  output,    width = 1,                   .write
		.ddr4a_master_dma_read            (_connected_to_ddr4a_master_dma_read_),            //  output,    width = 1,                   .read
		.ddr4a_master_dma_byteenable      (_connected_to_ddr4a_master_dma_byteenable_),      //  output,   width = 64,                   .byteenable
		.ddr4a_master_dma_debugaccess     (_connected_to_ddr4a_master_dma_debugaccess_),     //  output,    width = 1,                   .debugaccess
		.dma_clk_clk                      (_connected_to_dma_clk_clk_),                      //   input,    width = 1,            dma_clk.clk
		.dma_reset_reset                  (_connected_to_dma_reset_reset_),                  //   input,    width = 1,          dma_reset.reset
		.host_read_address                (_connected_to_host_read_address_),                //  output,   width = 48,          host_read.address
		.host_read_byteenable             (_connected_to_host_read_byteenable_),             //  output,   width = 64,                   .byteenable
		.host_read_burstcount             (_connected_to_host_read_burstcount_),             //  output,    width = 3,                   .burstcount
		.host_read_read                   (_connected_to_host_read_read_),                   //  output,    width = 1,                   .read
		.host_read_readdata               (_connected_to_host_read_readdata_),               //   input,  width = 512,                   .readdata
		.host_read_readdatavalid          (_connected_to_host_read_readdatavalid_),          //   input,    width = 1,                   .readdatavalid
		.host_read_waitrequest            (_connected_to_host_read_waitrequest_),            //   input,    width = 1,                   .waitrequest
		.host_write_address               (_connected_to_host_write_address_),               //  output,   width = 48,         host_write.address
		.host_write_writedata             (_connected_to_host_write_writedata_),             //  output,  width = 512,                   .writedata
		.host_write_byteenable            (_connected_to_host_write_byteenable_),            //  output,   width = 64,                   .byteenable
		.host_write_burstcount            (_connected_to_host_write_burstcount_),            //  output,    width = 3,                   .burstcount
		.host_write_write                 (_connected_to_host_write_write_),                 //  output,    width = 1,                   .write
		.host_write_response              (_connected_to_host_write_response_),              //   input,    width = 2,                   .response
		.host_write_writeresponsevalid    (_connected_to_host_write_writeresponsevalid_),    //   input,    width = 1,                   .writeresponsevalid
		.host_write_waitrequest           (_connected_to_host_write_waitrequest_),           //   input,    width = 1,                   .waitrequest
		.matmul_clk_clk                   (_connected_to_matmul_clk_clk_),                   //   input,    width = 1,         matmul_clk.clk
		.ddr4a_slave_matmul_waitrequest   (_connected_to_ddr4a_slave_matmul_waitrequest_),   //  output,    width = 1, ddr4a_slave_matmul.waitrequest
		.ddr4a_slave_matmul_readdata      (_connected_to_ddr4a_slave_matmul_readdata_),      //  output,    width = 8,                   .readdata
		.ddr4a_slave_matmul_readdatavalid (_connected_to_ddr4a_slave_matmul_readdatavalid_), //  output,    width = 1,                   .readdatavalid
		.ddr4a_slave_matmul_burstcount    (_connected_to_ddr4a_slave_matmul_burstcount_),    //   input,    width = 1,                   .burstcount
		.ddr4a_slave_matmul_writedata     (_connected_to_ddr4a_slave_matmul_writedata_),     //   input,    width = 8,                   .writedata
		.ddr4a_slave_matmul_address       (_connected_to_ddr4a_slave_matmul_address_),       //   input,   width = 33,                   .address
		.ddr4a_slave_matmul_write         (_connected_to_ddr4a_slave_matmul_write_),         //   input,    width = 1,                   .write
		.ddr4a_slave_matmul_read          (_connected_to_ddr4a_slave_matmul_read_),          //   input,    width = 1,                   .read
		.ddr4a_slave_matmul_byteenable    (_connected_to_ddr4a_slave_matmul_byteenable_),    //   input,    width = 1,                   .byteenable
		.ddr4a_slave_matmul_debugaccess   (_connected_to_ddr4a_slave_matmul_debugaccess_),   //   input,    width = 1,                   .debugaccess
		.matmul_ready_export              (_connected_to_matmul_ready_export_),              //   input,   width = 32,       matmul_ready.export
		.matmul_reset_reset               (_connected_to_matmul_reset_reset_),               //  output,    width = 1,       matmul_reset.reset
		.matmul_pgm_ram_address           (_connected_to_matmul_pgm_ram_address_),           //   input,    width = 6,     matmul_pgm_ram.address
		.matmul_pgm_ram_chipselect        (_connected_to_matmul_pgm_ram_chipselect_),        //   input,    width = 1,                   .chipselect
		.matmul_pgm_ram_clken             (_connected_to_matmul_pgm_ram_clken_),             //   input,    width = 1,                   .clken
		.matmul_pgm_ram_write             (_connected_to_matmul_pgm_ram_write_),             //   input,    width = 1,                   .write
		.matmul_pgm_ram_readdata          (_connected_to_matmul_pgm_ram_readdata_),          //  output,   width = 64,                   .readdata
		.matmul_pgm_ram_writedata         (_connected_to_matmul_pgm_ram_writedata_),         //   input,   width = 64,                   .writedata
		.matmul_pgm_ram_byteenable        (_connected_to_matmul_pgm_ram_byteenable_),        //   input,    width = 8,                   .byteenable
		.matmul_start_export              (_connected_to_matmul_start_export_)               //  output,   width = 32,       matmul_start.export
	);

