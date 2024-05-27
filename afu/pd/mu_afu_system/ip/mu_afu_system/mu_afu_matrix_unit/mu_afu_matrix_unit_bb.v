module mu_afu_matrix_unit (
		input  wire [7:0]  avmm_a_csr_address_i,       //    avmm_a_csr.address
		input  wire        avmm_a_csr_chipselect_i,    //              .chipselect
		input  wire        avmm_a_csr_write_i,         //              .write
		input  wire [31:0] avmm_a_csr_writedata_i,     //              .writedata
		output wire [31:0] avmm_a_csr_readdata_o,      //              .readdata
		input  wire        clk_i,                      //    user_clock.clk
		input  wire        rst_n_i,                    //       reset_n.reset_n
		input  wire [7:0]  avmm_h_ddr_readdata_i,      //    avmm_h_ddr.readdata
		input  wire        avmm_h_ddr_readdatavalid_i, //              .readdatavalid
		input  wire        avmm_h_ddr_waitreq_i,       //              .waitrequest
		output wire [7:0]  avmm_h_ddr_writedata_o,     //              .writedata
		output wire [32:0] avmm_h_ddr_address_o,       //              .address
		output wire        avmm_h_ddr_write_o,         //              .write
		output wire        avmm_h_ddr_read_o,          //              .read
		output wire [5:0]  avmm_h_imem_address_o,      // avalon_a_imem.address
		output wire        avmm_h_imem_chipselect_o,   //              .chipselect
		output wire        avmm_h_imem_write_o,        //              .write
		output wire [63:0] avmm_h_imem_writedata_o,    //              .writedata
		input  wire [63:0] avmm_h_imem_readdata_i      //              .readdata
	);
endmodule

