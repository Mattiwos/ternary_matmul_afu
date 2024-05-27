module msgdma_bbb_dispatcher (
		input  wire         clk,                    //                clock.clk
		input  wire         reset,                  //          clock_reset.reset
		input  wire [31:0]  csr_writedata,          //                  CSR.writedata
		input  wire         csr_write,              //                     .write
		input  wire [3:0]   csr_byteenable,         //                     .byteenable
		output wire [31:0]  csr_readdata,           //                     .readdata
		input  wire         csr_read,               //                     .read
		input  wire [2:0]   csr_address,            //                     .address
		output wire [255:0] src_response_data,      //      Response_Source.data
		output wire         src_response_valid,     //                     .valid
		input  wire         src_response_ready,     //                     .ready
		input  wire [255:0] snk_descriptor_data,    //      Descriptor_Sink.data
		input  wire         snk_descriptor_valid,   //                     .valid
		output wire         snk_descriptor_ready,   //                     .ready
		output wire [255:0] src_write_master_data,  // Write_Command_Source.data
		output wire         src_write_master_valid, //                     .valid
		input  wire         src_write_master_ready, //                     .ready
		input  wire [255:0] snk_write_master_data,  //  Write_Response_Sink.data
		input  wire         snk_write_master_valid, //                     .valid
		output wire         snk_write_master_ready, //                     .ready
		output wire [255:0] src_read_master_data,   //  Read_Command_Source.data
		output wire         src_read_master_valid,  //                     .valid
		input  wire         src_read_master_ready,  //                     .ready
		input  wire [255:0] snk_read_master_data,   //   Read_Response_Sink.data
		input  wire         snk_read_master_valid,  //                     .valid
		output wire         snk_read_master_ready   //                     .ready
	);
endmodule

