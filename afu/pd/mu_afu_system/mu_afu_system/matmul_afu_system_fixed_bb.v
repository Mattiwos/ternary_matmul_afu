module matmul_afu_system_fixed (
		input  wire [47:0]  avmm_mmio_address,                //          avmm_mmio.address
		input  wire [63:0]  avmm_mmio_writedata,              //                   .writedata
		input  wire [7:0]   avmm_mmio_byteenable,             //                   .byteenable
		input  wire         avmm_mmio_write,                  //                   .write
		input  wire         avmm_mmio_read,                   //                   .read
		output wire [63:0]  avmm_mmio_readdata,               //                   .readdata
		output wire         avmm_mmio_readdatavalid,          //                   .readdatavalid
		output wire         avmm_mmio_waitrequest,            //                   .waitrequest
		input  wire [0:0]   avmm_mmio_burstcount,             //                   .burstcount
		input  wire         ddr4a_master_dma_waitrequest,     //   ddr4a_master_dma.waitrequest
		input  wire [511:0] ddr4a_master_dma_readdata,        //                   .readdata
		input  wire         ddr4a_master_dma_readdatavalid,   //                   .readdatavalid
		output wire [2:0]   ddr4a_master_dma_burstcount,      //                   .burstcount
		output wire [511:0] ddr4a_master_dma_writedata,       //                   .writedata
		output wire [32:0]  ddr4a_master_dma_address,         //                   .address
		output wire         ddr4a_master_dma_write,           //                   .write
		output wire         ddr4a_master_dma_read,            //                   .read
		output wire [63:0]  ddr4a_master_dma_byteenable,      //                   .byteenable
		output wire         ddr4a_master_dma_debugaccess,     //                   .debugaccess
		input  wire         dma_clk_clk,                      //            dma_clk.clk
		input  wire         dma_reset_reset,                  //          dma_reset.reset
		output wire [47:0]  host_read_address,                //          host_read.address
		output wire [63:0]  host_read_byteenable,             //                   .byteenable
		output wire [2:0]   host_read_burstcount,             //                   .burstcount
		output wire         host_read_read,                   //                   .read
		input  wire [511:0] host_read_readdata,               //                   .readdata
		input  wire         host_read_readdatavalid,          //                   .readdatavalid
		input  wire         host_read_waitrequest,            //                   .waitrequest
		output wire [47:0]  host_write_address,               //         host_write.address
		output wire [511:0] host_write_writedata,             //                   .writedata
		output wire [63:0]  host_write_byteenable,            //                   .byteenable
		output wire [2:0]   host_write_burstcount,            //                   .burstcount
		output wire         host_write_write,                 //                   .write
		input  wire [1:0]   host_write_response,              //                   .response
		input  wire         host_write_writeresponsevalid,    //                   .writeresponsevalid
		input  wire         host_write_waitrequest,           //                   .waitrequest
		input  wire         matmul_clk_clk,                   //         matmul_clk.clk
		output wire         ddr4a_slave_matmul_waitrequest,   // ddr4a_slave_matmul.waitrequest
		output wire [7:0]   ddr4a_slave_matmul_readdata,      //                   .readdata
		output wire         ddr4a_slave_matmul_readdatavalid, //                   .readdatavalid
		input  wire [0:0]   ddr4a_slave_matmul_burstcount,    //                   .burstcount
		input  wire [7:0]   ddr4a_slave_matmul_writedata,     //                   .writedata
		input  wire [32:0]  ddr4a_slave_matmul_address,       //                   .address
		input  wire         ddr4a_slave_matmul_write,         //                   .write
		input  wire         ddr4a_slave_matmul_read,          //                   .read
		input  wire [0:0]   ddr4a_slave_matmul_byteenable,    //                   .byteenable
		input  wire         ddr4a_slave_matmul_debugaccess,   //                   .debugaccess
		input  wire [31:0]  matmul_ready_export,              //       matmul_ready.export
		output wire         matmul_reset_reset,               //       matmul_reset.reset
		input  wire [5:0]   matmul_pgm_ram_address,           //     matmul_pgm_ram.address
		input  wire         matmul_pgm_ram_chipselect,        //                   .chipselect
		input  wire         matmul_pgm_ram_clken,             //                   .clken
		input  wire         matmul_pgm_ram_write,             //                   .write
		output wire [63:0]  matmul_pgm_ram_readdata,          //                   .readdata
		input  wire [63:0]  matmul_pgm_ram_writedata,         //                   .writedata
		input  wire [7:0]   matmul_pgm_ram_byteenable,        //                   .byteenable
		output wire [31:0]  matmul_start_export               //       matmul_start.export
	);
endmodule

