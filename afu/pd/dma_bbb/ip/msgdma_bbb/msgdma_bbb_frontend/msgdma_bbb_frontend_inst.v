	msgdma_bbb_frontend u0 (
		.clk                   (_connected_to_clk_),                   //   input,    width = 1,                   clock.clk
		.reset                 (_connected_to_reset_),                 //   input,    width = 1,                   reset.reset
		.s_address             (_connected_to_s_address_),             //   input,    width = 3,               csr_slave.address
		.s_read                (_connected_to_s_read_),                //   input,    width = 1,                        .read
		.s_readdata            (_connected_to_s_readdata_),            //  output,   width = 64,                        .readdata
		.s_write               (_connected_to_s_write_),               //   input,    width = 1,                        .write
		.s_writedata           (_connected_to_s_writedata_),           //   input,   width = 64,                        .writedata
		.s_byteenable          (_connected_to_s_byteenable_),          //   input,    width = 8,                        .byteenable
		.m_fetch_address       (_connected_to_m_fetch_address_),       //  output,   width = 49, descriptor_fetch_master.address
		.m_fetch_burst         (_connected_to_m_fetch_burst_),         //  output,    width = 3,                        .burstcount
		.m_fetch_byteenable    (_connected_to_m_fetch_byteenable_),    //  output,   width = 64,                        .byteenable
		.m_fetch_read          (_connected_to_m_fetch_read_),          //  output,    width = 1,                        .read
		.m_fetch_readdata      (_connected_to_m_fetch_readdata_),      //   input,  width = 512,                        .readdata
		.m_fetch_readdatavalid (_connected_to_m_fetch_readdatavalid_), //   input,    width = 1,                        .readdatavalid
		.m_fetch_waitrequest   (_connected_to_m_fetch_waitrequest_),   //   input,    width = 1,                        .waitrequest
		.m_store_address       (_connected_to_m_store_address_),       //  output,   width = 49, descriptor_store_master.address
		.m_store_burst         (_connected_to_m_store_burst_),         //  output,    width = 3,                        .burstcount
		.m_store_byteenable    (_connected_to_m_store_byteenable_),    //  output,   width = 64,                        .byteenable
		.m_store_waitrequest   (_connected_to_m_store_waitrequest_),   //   input,    width = 1,                        .waitrequest
		.m_store_write         (_connected_to_m_store_write_),         //  output,    width = 1,                        .write
		.m_store_writedata     (_connected_to_m_store_writedata_),     //  output,  width = 512,                        .writedata
		.src_descriptor_data   (_connected_to_src_descriptor_data_),   //  output,  width = 256,       descriptor_source.data
		.src_descriptor_ready  (_connected_to_src_descriptor_ready_),  //   input,    width = 1,                        .ready
		.src_descriptor_valid  (_connected_to_src_descriptor_valid_),  //  output,    width = 1,                        .valid
		.snk_response_data     (_connected_to_snk_response_data_),     //   input,  width = 256,           response_sink.data
		.snk_response_ready    (_connected_to_snk_response_ready_),    //  output,    width = 1,                        .ready
		.snk_response_valid    (_connected_to_snk_response_valid_)     //   input,    width = 1,                        .valid
	);

