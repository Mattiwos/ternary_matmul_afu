	mu_afu_matrix_unit u0 (
		.avmm_a_csr_address_i       (_connected_to_avmm_a_csr_address_i_),       //   input,   width = 8,    avmm_a_csr.address
		.avmm_a_csr_chipselect_i    (_connected_to_avmm_a_csr_chipselect_i_),    //   input,   width = 1,              .chipselect
		.avmm_a_csr_write_i         (_connected_to_avmm_a_csr_write_i_),         //   input,   width = 1,              .write
		.avmm_a_csr_writedata_i     (_connected_to_avmm_a_csr_writedata_i_),     //   input,  width = 32,              .writedata
		.avmm_a_csr_readdata_o      (_connected_to_avmm_a_csr_readdata_o_),      //  output,  width = 32,              .readdata
		.clk_i                      (_connected_to_clk_i_),                      //   input,   width = 1,    user_clock.clk
		.rst_n_i                    (_connected_to_rst_n_i_),                    //   input,   width = 1,       reset_n.reset_n
		.avmm_h_ddr_readdata_i      (_connected_to_avmm_h_ddr_readdata_i_),      //   input,   width = 8,    avmm_h_ddr.readdata
		.avmm_h_ddr_readdatavalid_i (_connected_to_avmm_h_ddr_readdatavalid_i_), //   input,   width = 1,              .readdatavalid
		.avmm_h_ddr_waitreq_i       (_connected_to_avmm_h_ddr_waitreq_i_),       //   input,   width = 1,              .waitrequest
		.avmm_h_ddr_writedata_o     (_connected_to_avmm_h_ddr_writedata_o_),     //  output,   width = 8,              .writedata
		.avmm_h_ddr_address_o       (_connected_to_avmm_h_ddr_address_o_),       //  output,  width = 33,              .address
		.avmm_h_ddr_write_o         (_connected_to_avmm_h_ddr_write_o_),         //  output,   width = 1,              .write
		.avmm_h_ddr_read_o          (_connected_to_avmm_h_ddr_read_o_),          //  output,   width = 1,              .read
		.avmm_h_imem_address_o      (_connected_to_avmm_h_imem_address_o_),      //  output,   width = 6, avalon_a_imem.address
		.avmm_h_imem_chipselect_o   (_connected_to_avmm_h_imem_chipselect_o_),   //  output,   width = 1,              .chipselect
		.avmm_h_imem_write_o        (_connected_to_avmm_h_imem_write_o_),        //  output,   width = 1,              .write
		.avmm_h_imem_writedata_o    (_connected_to_avmm_h_imem_writedata_o_),    //  output,  width = 64,              .writedata
		.avmm_h_imem_readdata_i     (_connected_to_avmm_h_imem_readdata_i_)      //   input,  width = 64,              .readdata
	);

