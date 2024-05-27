module msgdma_bbb_host_read_bridge (
		input  wire         s_clk,           //    clk.clk
		input  wire         reset,           //  reset.reset
		input  wire [47:0]  s_address,       //  slave.address
		input  wire [63:0]  s_byteenable,    //       .byteenable
		input  wire         s_read,          //       .read
		output wire [511:0] s_readdata,      //       .readdata
		output wire         s_readdatavalid, //       .readdatavalid
		output wire         s_waitrequest,   //       .waitrequest
		input  wire [2:0]   s_burst,         //       .burstcount
		output wire [47:0]  m_address,       // master.address
		output wire [63:0]  m_byteenable,    //       .byteenable
		output wire [2:0]   m_burst,         //       .burstcount
		output wire         m_read,          //       .read
		input  wire [511:0] m_readdata,      //       .readdata
		input  wire         m_readdatavalid, //       .readdatavalid
		input  wire         m_waitrequest    //       .waitrequest
	);
endmodule

