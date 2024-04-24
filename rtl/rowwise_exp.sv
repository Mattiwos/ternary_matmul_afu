
module rowwise_exp import config_pkg::*; (
    input  fixed_point_t a_i,
    output fixed_point_t y_o
);

fixed_point_t EXPONENT_LUT [UnaryOperationLutSize];
initial $readmemh("rtl/luts/exp_lut.mem", EXPONENT_LUT);
assign operation_result = EXPONENT_LUT[a_i];

endmodule
