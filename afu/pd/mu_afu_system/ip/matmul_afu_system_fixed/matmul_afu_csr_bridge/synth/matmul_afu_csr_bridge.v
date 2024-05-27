// matmul_afu_csr_bridge.v

// Generated using ACDS version 19.2 57

`timescale 1 ps / 1 ps
module matmul_afu_csr_bridge (
		input  wire        s_clk,           //    clk.clk
		input  wire        reset,           //  reset.reset
		input  wire [47:0] s_address,       //  slave.address
		input  wire [63:0] s_writedata,     //       .writedata
		input  wire [7:0]  s_byteenable,    //       .byteenable
		input  wire        s_write,         //       .write
		input  wire        s_read,          //       .read
		output wire [63:0] s_readdata,      //       .readdata
		output wire        s_readdatavalid, //       .readdatavalid
		output wire        s_waitrequest,   //       .waitrequest
		input  wire [0:0]  s_burst,         //       .burstcount
		output wire [47:0] m_address,       // master.address
		output wire [63:0] m_writedata,     //       .writedata
		output wire [7:0]  m_byteenable,    //       .byteenable
		output wire [0:0]  m_burst,         //       .burstcount
		output wire        m_write,         //       .write
		output wire        m_read,          //       .read
		input  wire [63:0] m_readdata,      //       .readdata
		input  wire        m_readdatavalid, //       .readdatavalid
		input  wire        m_waitrequest    //       .waitrequest
	);

	far_reach_avalon_mm_bridge #(
		.DATA_WIDTH                      (64),
		.ADDRESS_WIDTH                   (48),
		.BURST_WIDTH                     (1),
		.MAX_PENDING_READS               (64),
		.MAX_PENDING_WRITES              (64),
		.WRITE_TRACKING_ENABLE           (0),
		.DOWNSTREAM_PIPELINE_STAGES      (2),
		.WAITREQUEST_PIPELINE_STAGES     (2),
		.UPSTREAM_PIPELINE_STAGES        (2),
		.SKID_FIFO_DEPTH                 (16),
		.SKID_FIFO_ALMOST_FULL_LEVEL     (11),
		.SKID_FIFO_CLOCK_CROSSING_ENABLE (0),
		.UPSTREAM_CLOCK_CROSSING_ENABLE  (0),
		.UPSTREAM_FIFO_DEPTH             (32),
		.UPSTREAM_FIFO_ALMOST_FULL_LEVEL (10)
	) matmul_afu_csr_bridge (
		.s_clk                (s_clk),           //   input,   width = 1,    clk.clk
		.reset                (reset),           //   input,   width = 1,  reset.reset
		.s_address            (s_address),       //   input,  width = 48,  slave.address
		.s_writedata          (s_writedata),     //   input,  width = 64,       .writedata
		.s_byteenable         (s_byteenable),    //   input,   width = 8,       .byteenable
		.s_write              (s_write),         //   input,   width = 1,       .write
		.s_read               (s_read),          //   input,   width = 1,       .read
		.s_readdata           (s_readdata),      //  output,  width = 64,       .readdata
		.s_readdatavalid      (s_readdatavalid), //  output,   width = 1,       .readdatavalid
		.s_waitrequest        (s_waitrequest),   //  output,   width = 1,       .waitrequest
		.s_burst              (s_burst),         //   input,   width = 1,       .burstcount
		.m_address            (m_address),       //  output,  width = 48, master.address
		.m_writedata          (m_writedata),     //  output,  width = 64,       .writedata
		.m_byteenable         (m_byteenable),    //  output,   width = 8,       .byteenable
		.m_burst              (m_burst),         //  output,   width = 1,       .burstcount
		.m_write              (m_write),         //  output,   width = 1,       .write
		.m_read               (m_read),          //  output,   width = 1,       .read
		.m_readdata           (m_readdata),      //   input,  width = 64,       .readdata
		.m_readdatavalid      (m_readdatavalid), //   input,   width = 1,       .readdatavalid
		.m_waitrequest        (m_waitrequest),   //   input,   width = 1,       .waitrequest
		.m_clk                (1'b0),            // (terminated),                     
		.s_response           (),                // (terminated),                     
		.s_writeresponsevalid (),                // (terminated),                     
		.m_response           (2'b00),           // (terminated),                     
		.m_writeresponsevalid (1'b0)             // (terminated),                     
	);

endmodule