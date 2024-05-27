module mu_afu_system (
		input  wire [47:0]  avmm_mmio_address,             //  avmm_mmio.address
		input  wire [63:0]  avmm_mmio_writedata,           //           .writedata
		input  wire [7:0]   avmm_mmio_byteenable,          //           .byteenable
		input  wire         avmm_mmio_write,               //           .write
		input  wire         avmm_mmio_read,                //           .read
		output wire [63:0]  avmm_mmio_readdata,            //           .readdata
		output wire         avmm_mmio_readdatavalid,       //           .readdatavalid
		output wire         avmm_mmio_waitrequest,         //           .waitrequest
		input  wire [0:0]   avmm_mmio_burstcount,          //           .burstcount
		input  wire         ddr4a_host_waitrequest,        // ddr4a_host.waitrequest
		input  wire [511:0] ddr4a_host_readdata,           //           .readdata
		input  wire         ddr4a_host_readdatavalid,      //           .readdatavalid
		output wire [2:0]   ddr4a_host_burstcount,         //           .burstcount
		output wire [511:0] ddr4a_host_writedata,          //           .writedata
		output wire [32:0]  ddr4a_host_address,            //           .address
		output wire         ddr4a_host_write,              //           .write
		output wire         ddr4a_host_read,               //           .read
		output wire [63:0]  ddr4a_host_byteenable,         //           .byteenable
		output wire         ddr4a_host_debugaccess,        //           .debugaccess
		input  wire         dma_clk_clk,                   //    dma_clk.clk
		output wire [47:0]  host_read_address,             //  host_read.address
		output wire [63:0]  host_read_byteenable,          //           .byteenable
		output wire [2:0]   host_read_burstcount,          //           .burstcount
		output wire         host_read_read,                //           .read
		input  wire [511:0] host_read_readdata,            //           .readdata
		input  wire         host_read_readdatavalid,       //           .readdatavalid
		input  wire         host_read_waitrequest,         //           .waitrequest
		output wire [47:0]  host_write_address,            // host_write.address
		output wire [511:0] host_write_writedata,          //           .writedata
		output wire [63:0]  host_write_byteenable,         //           .byteenable
		output wire [2:0]   host_write_burstcount,         //           .burstcount
		output wire         host_write_write,              //           .write
		input  wire [1:0]   host_write_response,           //           .response
		input  wire         host_write_writeresponsevalid, //           .writeresponsevalid
		input  wire         host_write_waitrequest,        //           .waitrequest
		input  wire         host_reset_reset,              // host_reset.reset
		input  wire         mu_clk_clk                     //     mu_clk.clk
	);
endmodule

