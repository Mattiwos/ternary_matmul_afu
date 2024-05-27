module msgdma_bbb_frontend (
		input  wire         clk,                   //                   clock.clk
		input  wire         reset,                 //                   reset.reset
		input  wire [2:0]   s_address,             //               csr_slave.address
		input  wire         s_read,                //                        .read
		output wire [63:0]  s_readdata,            //                        .readdata
		input  wire         s_write,               //                        .write
		input  wire [63:0]  s_writedata,           //                        .writedata
		input  wire [7:0]   s_byteenable,          //                        .byteenable
		output wire [48:0]  m_fetch_address,       // descriptor_fetch_master.address
		output wire [2:0]   m_fetch_burst,         //                        .burstcount
		output wire [63:0]  m_fetch_byteenable,    //                        .byteenable
		output wire         m_fetch_read,          //                        .read
		input  wire [511:0] m_fetch_readdata,      //                        .readdata
		input  wire         m_fetch_readdatavalid, //                        .readdatavalid
		input  wire         m_fetch_waitrequest,   //                        .waitrequest
		output wire [48:0]  m_store_address,       // descriptor_store_master.address
		output wire [2:0]   m_store_burst,         //                        .burstcount
		output wire [63:0]  m_store_byteenable,    //                        .byteenable
		input  wire         m_store_waitrequest,   //                        .waitrequest
		output wire         m_store_write,         //                        .write
		output wire [511:0] m_store_writedata,     //                        .writedata
		output wire [255:0] src_descriptor_data,   //       descriptor_source.data
		input  wire         src_descriptor_ready,  //                        .ready
		output wire         src_descriptor_valid,  //                        .valid
		input  wire [255:0] snk_response_data,     //           response_sink.data
		output wire         snk_response_ready,    //                        .ready
		input  wire         snk_response_valid     //                        .valid
	);
endmodule

