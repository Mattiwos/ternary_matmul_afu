
module rowwise_mul import config_pkg::*; (
    input  fixed_point_t a_i,
    input  fixed_point_t b_i,
    output fixed_point_t y_o
);

logic signed [2*FixedPointPrecision-1:0] internal;
always_comb begin
    internal = a_i * b_i;
    if (FixedPointExponent < 0) begin
        internal = internal >>> -FixedPointExponent;
    end else begin
        internal = internal << FixedPointExponent;
    end
    if (internal > FixedPointMax) internal = FixedPointMax;
    if (internal < FixedPointMin) internal = FixedPointMin;
    y_o = fixed_point_t'(internal);
end

endmodule
