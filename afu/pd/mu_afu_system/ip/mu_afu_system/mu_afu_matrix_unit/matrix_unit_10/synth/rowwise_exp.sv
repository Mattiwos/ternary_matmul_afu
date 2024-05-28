
module rowwise_exp import config_pkg::*; (
    input  fixed_point_t a_i,
    output fixed_point_t y_o
);

fixed_point_t EXPONENT_LUT [UnaryOperationLutSize];

`ifdef REL_MEMB_RD
    initial $readmemh("./exp_lut.memh", EXPONENT_LUT);
`else
    initial $readmemh("rtl/luts/exp_lut.memh", EXPONENT_LUT);
`endif

assign y_o = EXPONENT_LUT[a_i];

endmodule
