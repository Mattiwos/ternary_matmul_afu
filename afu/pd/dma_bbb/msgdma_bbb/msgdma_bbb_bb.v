module msgdma_bbb (
		input  wire         clk_clk,                       //            clk.clk
		input  wire [7:0]   csr_address,                   //            csr.address
		input  wire [63:0]  csr_writedata,                 //               .writedata
		input  wire [7:0]   csr_byteenable,                //               .byteenable
		input  wire         csr_write,                     //               .write
		input  wire         csr_read,                      //               .read
		output wire [63:0]  csr_readdata,                  //               .readdata
		output wire         csr_readdatavalid,             //               .readdatavalid
		output wire         csr_waitrequest,               //               .waitrequest
		input  wire [0:0]   csr_burstcount,                //               .burstcount
		output wire [47:0]  host_read_address,             //      host_read.address
		output wire [63:0]  host_read_byteenable,          //               .byteenable
		output wire [2:0]   host_read_burstcount,          //               .burstcount
		output wire         host_read_read,                //               .read
		input  wire [511:0] host_read_readdata,            //               .readdata
		input  wire         host_read_readdatavalid,       //               .readdatavalid
		input  wire         host_read_waitrequest,         //               .waitrequest
		output wire [47:0]  host_write_address,            //     host_write.address
		output wire [511:0] host_write_writedata,          //               .writedata
		output wire [63:0]  host_write_byteenable,         //               .byteenable
		output wire [2:0]   host_write_burstcount,         //               .burstcount
		output wire         host_write_write,              //               .write
		input  wire [1:0]   host_write_response,           //               .response
		input  wire         host_write_writeresponsevalid, //               .writeresponsevalid
		input  wire         host_write_waitrequest,        //               .waitrequest
		output wire [47:0]  mem_read_write_address,        // mem_read_write.address
		output wire [511:0] mem_read_write_writedata,      //               .writedata
		output wire [63:0]  mem_read_write_byteenable,     //               .byteenable
		output wire [2:0]   mem_read_write_burstcount,     //               .burstcount
		output wire         mem_read_write_write,          //               .write
		output wire         mem_read_write_read,           //               .read
		input  wire [511:0] mem_read_write_readdata,       //               .readdata
		input  wire         mem_read_write_readdatavalid,  //               .readdatavalid
		input  wire         mem_read_write_waitrequest,    //               .waitrequest
		input  wire         reset_reset                    //          reset.reset
	);
endmodule

