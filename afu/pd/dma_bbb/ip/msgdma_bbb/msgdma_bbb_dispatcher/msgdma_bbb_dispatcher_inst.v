	msgdma_bbb_dispatcher u0 (
		.clk                    (_connected_to_clk_),                    //   input,    width = 1,                clock.clk
		.reset                  (_connected_to_reset_),                  //   input,    width = 1,          clock_reset.reset
		.csr_writedata          (_connected_to_csr_writedata_),          //   input,   width = 32,                  CSR.writedata
		.csr_write              (_connected_to_csr_write_),              //   input,    width = 1,                     .write
		.csr_byteenable         (_connected_to_csr_byteenable_),         //   input,    width = 4,                     .byteenable
		.csr_readdata           (_connected_to_csr_readdata_),           //  output,   width = 32,                     .readdata
		.csr_read               (_connected_to_csr_read_),               //   input,    width = 1,                     .read
		.csr_address            (_connected_to_csr_address_),            //   input,    width = 3,                     .address
		.src_response_data      (_connected_to_src_response_data_),      //  output,  width = 256,      Response_Source.data
		.src_response_valid     (_connected_to_src_response_valid_),     //  output,    width = 1,                     .valid
		.src_response_ready     (_connected_to_src_response_ready_),     //   input,    width = 1,                     .ready
		.snk_descriptor_data    (_connected_to_snk_descriptor_data_),    //   input,  width = 256,      Descriptor_Sink.data
		.snk_descriptor_valid   (_connected_to_snk_descriptor_valid_),   //   input,    width = 1,                     .valid
		.snk_descriptor_ready   (_connected_to_snk_descriptor_ready_),   //  output,    width = 1,                     .ready
		.src_write_master_data  (_connected_to_src_write_master_data_),  //  output,  width = 256, Write_Command_Source.data
		.src_write_master_valid (_connected_to_src_write_master_valid_), //  output,    width = 1,                     .valid
		.src_write_master_ready (_connected_to_src_write_master_ready_), //   input,    width = 1,                     .ready
		.snk_write_master_data  (_connected_to_snk_write_master_data_),  //   input,  width = 256,  Write_Response_Sink.data
		.snk_write_master_valid (_connected_to_snk_write_master_valid_), //   input,    width = 1,                     .valid
		.snk_write_master_ready (_connected_to_snk_write_master_ready_), //  output,    width = 1,                     .ready
		.src_read_master_data   (_connected_to_src_read_master_data_),   //  output,  width = 256,  Read_Command_Source.data
		.src_read_master_valid  (_connected_to_src_read_master_valid_),  //  output,    width = 1,                     .valid
		.src_read_master_ready  (_connected_to_src_read_master_ready_),  //   input,    width = 1,                     .ready
		.snk_read_master_data   (_connected_to_snk_read_master_data_),   //   input,  width = 256,   Read_Response_Sink.data
		.snk_read_master_valid  (_connected_to_snk_read_master_valid_),  //   input,    width = 1,                     .valid
		.snk_read_master_ready  (_connected_to_snk_read_master_ready_)   //  output,    width = 1,                     .ready
	);

