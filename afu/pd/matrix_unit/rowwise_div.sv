
module rowwise_div import config_pkg::*; (
    input  fixed_point_t a_i,
    input  fixed_point_t b_i,
    output fixed_point_t y_o
);

logic signed [2*FixedPointPrecision-1:0] internal_b;
logic signed [2*FixedPointPrecision-1:0] internal_y;

always_comb begin
    internal_y = 'x;
    internal_b = b_i;
    if (FixedPointExponent < 0) begin
        internal_b = internal_b >>> -FixedPointExponent;
    end else begin
        internal_b = internal_b << FixedPointExponent;
    end
    if (internal_b == 0) begin
        if (a_i < 0)
            y_o = FixedPointMin;
        else if (a_i > 0)
            y_o = FixedPointMax;
        else
            y_o = 0;
    end else begin
        // internal_y = a_i / internal_b;
        if (internal_y > FixedPointMax) internal_y = FixedPointMax;
        if (internal_y < FixedPointMin) internal_y = FixedPointMin;
        y_o = fixed_point_t'(internal_y);
    end
end

// Divide IP optimized for Stratix 10
div uDiv (
	.numer(a_i),
	.denom(internal_b),
	.quotient(internal_y),
	.remain()
);

endmodule
