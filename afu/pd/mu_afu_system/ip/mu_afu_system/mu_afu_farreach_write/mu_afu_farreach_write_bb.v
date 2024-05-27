module mu_afu_farreach_write (
		input  wire         s_clk,                //    clk.clk
		input  wire         reset,                //  reset.reset
		input  wire [47:0]  s_address,            //  slave.address
		input  wire [511:0] s_writedata,          //       .writedata
		input  wire [63:0]  s_byteenable,         //       .byteenable
		input  wire         s_write,              //       .write
		output wire [1:0]   s_response,           //       .response
		output wire         s_writeresponsevalid, //       .writeresponsevalid
		output wire         s_waitrequest,        //       .waitrequest
		input  wire [2:0]   s_burst,              //       .burstcount
		output wire [47:0]  m_address,            // master.address
		output wire [511:0] m_writedata,          //       .writedata
		output wire [63:0]  m_byteenable,         //       .byteenable
		output wire [2:0]   m_burst,              //       .burstcount
		output wire         m_write,              //       .write
		input  wire [1:0]   m_response,           //       .response
		input  wire         m_writeresponsevalid, //       .writeresponsevalid
		input  wire         m_waitrequest         //       .waitrequest
	);
endmodule

