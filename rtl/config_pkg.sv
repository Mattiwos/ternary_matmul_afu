
package config_pkg;

parameter FixedPointPrecision = 8;
parameter FixedPointExponent = -3;

typedef logic signed [FixedPointPrecision-1:0] fixed_point_t;

localparam fixed_point_t FixedPointMin = (1 << (FixedPointPrecision-1));
localparam fixed_point_t FixedPointMax = (FixedPointMin - 1);

localparam UnaryOperationLutSize = (2 ** FixedPointPrecision);

parameter D = 4;

typedef logic signed [1:0] ternary_t;
typedef fixed_point_t [D-1:0] vector_t;
typedef ternary_t [D-1:0][D-1:0] ternary_matrix_t;

parameter RmsFixedPointPrecision = 9;
parameter RmsFixedPointExponent = 0;

localparam RmsUnaryOperationLutSize = (2 ** RmsFixedPointPrecision);

typedef logic signed [RmsFixedPointPrecision-1:0] rms_fixed_point_t;

typedef rms_fixed_point_t [D-1:0] rms_vector_t;

function automatic rms_fixed_point_t rms_in2internal(fixed_point_t x);
    localparam internalSize = $bits(rms_fixed_point_t) + $bits(fixed_point_t);
    if (RmsFixedPointExponent < FixedPointExponent) begin
        return internalSize'(x) << (FixedPointExponent - RmsFixedPointExponent);
    end else begin
        return internalSize'(x) >>> (RmsFixedPointExponent - FixedPointExponent);
    end
endfunction

function automatic fixed_point_t rms_internal2out(rms_fixed_point_t x);
    localparam internalSize = $bits(rms_fixed_point_t) + $bits(fixed_point_t);
    if (RmsFixedPointExponent < FixedPointExponent) begin
        return internalSize'(x) >>> (FixedPointExponent - RmsFixedPointExponent);
    end else begin
        return internalSize'(x) << (RmsFixedPointExponent - FixedPointExponent);
    end
endfunction

endpackage
