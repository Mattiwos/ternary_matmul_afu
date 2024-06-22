	msgdma_bbb u0 (
		.clk_clk                       (_connected_to_clk_clk_),                       //   input,    width = 1,            clk.clk
		.csr_address                   (_connected_to_csr_address_),                   //   input,    width = 8,            csr.address
		.csr_writedata                 (_connected_to_csr_writedata_),                 //   input,   width = 64,               .writedata
		.csr_byteenable                (_connected_to_csr_byteenable_),                //   input,    width = 8,               .byteenable
		.csr_write                     (_connected_to_csr_write_),                     //   input,    width = 1,               .write
		.csr_read                      (_connected_to_csr_read_),                      //   input,    width = 1,               .read
		.csr_readdata                  (_connected_to_csr_readdata_),                  //  output,   width = 64,               .readdata
		.csr_readdatavalid             (_connected_to_csr_readdatavalid_),             //  output,    width = 1,               .readdatavalid
		.csr_waitrequest               (_connected_to_csr_waitrequest_),               //  output,    width = 1,               .waitrequest
		.csr_burstcount                (_connected_to_csr_burstcount_),                //   input,    width = 1,               .burstcount
		.host_read_address             (_connected_to_host_read_address_),             //  output,   width = 48,      host_read.address
		.host_read_byteenable          (_connected_to_host_read_byteenable_),          //  output,   width = 64,               .byteenable
		.host_read_burstcount          (_connected_to_host_read_burstcount_),          //  output,    width = 3,               .burstcount
		.host_read_read                (_connected_to_host_read_read_),                //  output,    width = 1,               .read
		.host_read_readdata            (_connected_to_host_read_readdata_),            //   input,  width = 512,               .readdata
		.host_read_readdatavalid       (_connected_to_host_read_readdatavalid_),       //   input,    width = 1,               .readdatavalid
		.host_read_waitrequest         (_connected_to_host_read_waitrequest_),         //   input,    width = 1,               .waitrequest
		.host_write_address            (_connected_to_host_write_address_),            //  output,   width = 48,     host_write.address
		.host_write_writedata          (_connected_to_host_write_writedata_),          //  output,  width = 512,               .writedata
		.host_write_byteenable         (_connected_to_host_write_byteenable_),         //  output,   width = 64,               .byteenable
		.host_write_burstcount         (_connected_to_host_write_burstcount_),         //  output,    width = 3,               .burstcount
		.host_write_write              (_connected_to_host_write_write_),              //  output,    width = 1,               .write
		.host_write_response           (_connected_to_host_write_response_),           //   input,    width = 2,               .response
		.host_write_writeresponsevalid (_connected_to_host_write_writeresponsevalid_), //   input,    width = 1,               .writeresponsevalid
		.host_write_waitrequest        (_connected_to_host_write_waitrequest_),        //   input,    width = 1,               .waitrequest
		.mem_read_write_address        (_connected_to_mem_read_write_address_),        //  output,   width = 48, mem_read_write.address
		.mem_read_write_writedata      (_connected_to_mem_read_write_writedata_),      //  output,  width = 512,               .writedata
		.mem_read_write_byteenable     (_connected_to_mem_read_write_byteenable_),     //  output,   width = 64,               .byteenable
		.mem_read_write_burstcount     (_connected_to_mem_read_write_burstcount_),     //  output,    width = 3,               .burstcount
		.mem_read_write_write          (_connected_to_mem_read_write_write_),          //  output,    width = 1,               .write
		.mem_read_write_read           (_connected_to_mem_read_write_read_),           //  output,    width = 1,               .read
		.mem_read_write_readdata       (_connected_to_mem_read_write_readdata_),       //   input,  width = 512,               .readdata
		.mem_read_write_readdatavalid  (_connected_to_mem_read_write_readdatavalid_),  //   input,    width = 1,               .readdatavalid
		.mem_read_write_waitrequest    (_connected_to_mem_read_write_waitrequest_),    //   input,    width = 1,               .waitrequest
		.reset_reset                   (_connected_to_reset_reset_)                    //   input,    width = 1,          reset.reset
	);

