	mu_afu_mu_pgm_ram u0 (
		.address     (_connected_to_address_),     //   input,   width = 6,     s1.address
		.clken       (_connected_to_clken_),       //   input,   width = 1,       .clken
		.chipselect  (_connected_to_chipselect_),  //   input,   width = 1,       .chipselect
		.write       (_connected_to_write_),       //   input,   width = 1,       .write
		.readdata    (_connected_to_readdata_),    //  output,  width = 64,       .readdata
		.writedata   (_connected_to_writedata_),   //   input,  width = 64,       .writedata
		.byteenable  (_connected_to_byteenable_),  //   input,   width = 8,       .byteenable
		.address2    (_connected_to_address2_),    //   input,   width = 6,     s2.address
		.chipselect2 (_connected_to_chipselect2_), //   input,   width = 1,       .chipselect
		.clken2      (_connected_to_clken2_),      //   input,   width = 1,       .clken
		.write2      (_connected_to_write2_),      //   input,   width = 1,       .write
		.readdata2   (_connected_to_readdata2_),   //  output,  width = 64,       .readdata
		.writedata2  (_connected_to_writedata2_),  //   input,  width = 64,       .writedata
		.byteenable2 (_connected_to_byteenable2_), //   input,   width = 8,       .byteenable
		.clk         (_connected_to_clk_),         //   input,   width = 1,   clk1.clk
		.reset       (_connected_to_reset_)        //   input,   width = 1, reset1.reset
	);
