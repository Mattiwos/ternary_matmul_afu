
module rowwise_sig import config_pkg::*; (
    input  fixed_point_t a_i,
    output fixed_point_t y_o
);

fixed_point_t SIGMOID_LUT [UnaryOperationLutSize];
initial $readmemh("rtl/luts/sig_lut.mem", SIGMOID_LUT);
assign operation_result = SIGMOID_LUT[a_i];

endmodule
