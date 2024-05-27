// msgdma_bbb_frontend.v

// Generated using ACDS version 19.2 57

`timescale 1 ps / 1 ps
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

	mSGDMA_frontend #(
		.ADDRESS_WIDTH         (49),
		.BURST_WIDTH           (3),
		.FETCH_FIFO_DEPTH_LOG2 (7),
		.STORE_FIFO_DEPTH_LOG2 (5),
		.IRQ_ENABLE            (0)
	) msgdma_bbb_frontend (
		.clk                   (clk),                   //   input,    width = 1,                   clock.clk
		.reset                 (reset),                 //   input,    width = 1,                   reset.reset
		.s_address             (s_address),             //   input,    width = 3,               csr_slave.address
		.s_read                (s_read),                //   input,    width = 1,                        .read
		.s_readdata            (s_readdata),            //  output,   width = 64,                        .readdata
		.s_write               (s_write),               //   input,    width = 1,                        .write
		.s_writedata           (s_writedata),           //   input,   width = 64,                        .writedata
		.s_byteenable          (s_byteenable),          //   input,    width = 8,                        .byteenable
		.m_fetch_address       (m_fetch_address),       //  output,   width = 49, descriptor_fetch_master.address
		.m_fetch_burst         (m_fetch_burst),         //  output,    width = 3,                        .burstcount
		.m_fetch_byteenable    (m_fetch_byteenable),    //  output,   width = 64,                        .byteenable
		.m_fetch_read          (m_fetch_read),          //  output,    width = 1,                        .read
		.m_fetch_readdata      (m_fetch_readdata),      //   input,  width = 512,                        .readdata
		.m_fetch_readdatavalid (m_fetch_readdatavalid), //   input,    width = 1,                        .readdatavalid
		.m_fetch_waitrequest   (m_fetch_waitrequest),   //   input,    width = 1,                        .waitrequest
		.m_store_address       (m_store_address),       //  output,   width = 49, descriptor_store_master.address
		.m_store_burst         (m_store_burst),         //  output,    width = 3,                        .burstcount
		.m_store_byteenable    (m_store_byteenable),    //  output,   width = 64,                        .byteenable
		.m_store_waitrequest   (m_store_waitrequest),   //   input,    width = 1,                        .waitrequest
		.m_store_write         (m_store_write),         //  output,    width = 1,                        .write
		.m_store_writedata     (m_store_writedata),     //  output,  width = 512,                        .writedata
		.src_descriptor_data   (src_descriptor_data),   //  output,  width = 256,       descriptor_source.data
		.src_descriptor_ready  (src_descriptor_ready),  //   input,    width = 1,                        .ready
		.src_descriptor_valid  (src_descriptor_valid),  //  output,    width = 1,                        .valid
		.snk_response_data     (snk_response_data),     //   input,  width = 256,           response_sink.data
		.snk_response_ready    (snk_response_ready),    //  output,    width = 1,                        .ready
		.snk_response_valid    (snk_response_valid),    //   input,    width = 1,                        .valid
		.irq                   ()                       // (terminated),                                       
	);

endmodule
