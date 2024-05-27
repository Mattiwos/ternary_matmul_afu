module msgdma_bbb_csr (
		input  wire        s_clk,           //    clk.clk
		input  wire        reset,           //  reset.reset
		input  wire [7:0]  s_address,       //  slave.address
		input  wire [63:0] s_writedata,     //       .writedata
		input  wire [7:0]  s_byteenable,    //       .byteenable
		input  wire        s_write,         //       .write
		input  wire        s_read,          //       .read
		output wire [63:0] s_readdata,      //       .readdata
		output wire        s_readdatavalid, //       .readdatavalid
		output wire        s_waitrequest,   //       .waitrequest
		input  wire [0:0]  s_burst,         //       .burstcount
		output wire [7:0]  m_address,       // master.address
		output wire [63:0] m_writedata,     //       .writedata
		output wire [7:0]  m_byteenable,    //       .byteenable
		output wire [0:0]  m_burst,         //       .burstcount
		output wire        m_write,         //       .write
		output wire        m_read,          //       .read
		input  wire [63:0] m_readdata,      //       .readdata
		input  wire        m_readdatavalid, //       .readdatavalid
		input  wire        m_waitrequest    //       .waitrequest
	);
endmodule

