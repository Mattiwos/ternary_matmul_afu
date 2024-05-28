
module rowwise_sig import config_pkg::*; (
    input  fixed_point_t a_i,
    output fixed_point_t y_o
);

fixed_point_t SIGMOID_LUT [UnaryOperationLutSize];

`ifdef REL_MEMB_RD
    initial $readmemh("./sig_lut.memh", SIGMOID_LUT);
`else
    initial $readmemh("rtl/luts/sig_lut.memh", SIGMOID_LUT);
`endif

assign y_o = SIGMOID_LUT[a_i];

endmodule
