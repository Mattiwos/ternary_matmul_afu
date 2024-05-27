	matmul_afu_csr_bridge u0 (
		.s_clk           (_connected_to_s_clk_),           //   input,   width = 1,    clk.clk
		.reset           (_connected_to_reset_),           //   input,   width = 1,  reset.reset
		.s_address       (_connected_to_s_address_),       //   input,  width = 48,  slave.address
		.s_writedata     (_connected_to_s_writedata_),     //   input,  width = 64,       .writedata
		.s_byteenable    (_connected_to_s_byteenable_),    //   input,   width = 8,       .byteenable
		.s_write         (_connected_to_s_write_),         //   input,   width = 1,       .write
		.s_read          (_connected_to_s_read_),          //   input,   width = 1,       .read
		.s_readdata      (_connected_to_s_readdata_),      //  output,  width = 64,       .readdata
		.s_readdatavalid (_connected_to_s_readdatavalid_), //  output,   width = 1,       .readdatavalid
		.s_waitrequest   (_connected_to_s_waitrequest_),   //  output,   width = 1,       .waitrequest
		.s_burst         (_connected_to_s_burst_),         //   input,   width = 1,       .burstcount
		.m_address       (_connected_to_m_address_),       //  output,  width = 48, master.address
		.m_writedata     (_connected_to_m_writedata_),     //  output,  width = 64,       .writedata
		.m_byteenable    (_connected_to_m_byteenable_),    //  output,   width = 8,       .byteenable
		.m_burst         (_connected_to_m_burst_),         //  output,   width = 1,       .burstcount
		.m_write         (_connected_to_m_write_),         //  output,   width = 1,       .write
		.m_read          (_connected_to_m_read_),          //  output,   width = 1,       .read
		.m_readdata      (_connected_to_m_readdata_),      //   input,  width = 64,       .readdata
		.m_readdatavalid (_connected_to_m_readdatavalid_), //   input,   width = 1,       .readdatavalid
		.m_waitrequest   (_connected_to_m_waitrequest_)    //   input,   width = 1,       .waitrequest
	);

