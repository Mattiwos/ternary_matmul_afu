module matmul_afu_pgm_ram (
		input  wire [5:0]  address,     //     s1.address
		input  wire        clken,       //       .clken
		input  wire        chipselect,  //       .chipselect
		input  wire        write,       //       .write
		output wire [63:0] readdata,    //       .readdata
		input  wire [63:0] writedata,   //       .writedata
		input  wire [7:0]  byteenable,  //       .byteenable
		input  wire [5:0]  address2,    //     s2.address
		input  wire        chipselect2, //       .chipselect
		input  wire        clken2,      //       .clken
		input  wire        write2,      //       .write
		output wire [63:0] readdata2,   //       .readdata
		input  wire [63:0] writedata2,  //       .writedata
		input  wire [7:0]  byteenable2, //       .byteenable
		input  wire        clk,         //   clk1.clk
		input  wire        reset        // reset1.reset
	);
endmodule

