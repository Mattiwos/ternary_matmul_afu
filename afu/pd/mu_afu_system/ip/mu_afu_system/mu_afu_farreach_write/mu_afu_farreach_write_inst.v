	mu_afu_farreach_write u0 (
		.s_clk                (_connected_to_s_clk_),                //   input,    width = 1,    clk.clk
		.reset                (_connected_to_reset_),                //   input,    width = 1,  reset.reset
		.s_address            (_connected_to_s_address_),            //   input,   width = 48,  slave.address
		.s_writedata          (_connected_to_s_writedata_),          //   input,  width = 512,       .writedata
		.s_byteenable         (_connected_to_s_byteenable_),         //   input,   width = 64,       .byteenable
		.s_write              (_connected_to_s_write_),              //   input,    width = 1,       .write
		.s_response           (_connected_to_s_response_),           //  output,    width = 2,       .response
		.s_writeresponsevalid (_connected_to_s_writeresponsevalid_), //  output,    width = 1,       .writeresponsevalid
		.s_waitrequest        (_connected_to_s_waitrequest_),        //  output,    width = 1,       .waitrequest
		.s_burst              (_connected_to_s_burst_),              //   input,    width = 3,       .burstcount
		.m_address            (_connected_to_m_address_),            //  output,   width = 48, master.address
		.m_writedata          (_connected_to_m_writedata_),          //  output,  width = 512,       .writedata
		.m_byteenable         (_connected_to_m_byteenable_),         //  output,   width = 64,       .byteenable
		.m_burst              (_connected_to_m_burst_),              //  output,    width = 3,       .burstcount
		.m_write              (_connected_to_m_write_),              //  output,    width = 1,       .write
		.m_response           (_connected_to_m_response_),           //   input,    width = 2,       .response
		.m_writeresponsevalid (_connected_to_m_writeresponsevalid_), //   input,    width = 1,       .writeresponsevalid
		.m_waitrequest        (_connected_to_m_waitrequest_)         //   input,    width = 1,       .waitrequest
	);

