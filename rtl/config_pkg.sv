
package config_pkg;

parameter FixedPointIntegerPrecision = 5;
parameter FixedPointFractionalPrecision = 3;

localparam FixedPointPrecision = FixedPointIntegerPrecision + FixedPointFractionalPrecision;

typedef logic signed [FixedPointPrecision-1:0] fixed_point_t;

localparam fixed_point_t FixedPointMin = (1 << (FixedPointPrecision-1));
localparam fixed_point_t FixedPointMax = (FixedPointMin - 1);

parameter D = 4;

typedef logic signed [1:0] ternary_t;
typedef fixed_point_t [D-1:0] vector_t;
typedef ternary_t [D-1:0][D-1:0] ternary_matrix_t;

typedef enum logic [2:0] {
    NOP,
    ADD,
    SUB,
    DIV,
    MUL,
    EXP
} operation_t;

function automatic fixed_point_t ternary_mul(ternary_t ternary, fixed_point_t fixed_point);
    unique case (ternary)
        0: return '0;
        1: return fixed_point;
        -1: return -fixed_point;
        default: return 'x;
    endcase
endfunction

function automatic fixed_point_t fixed_point_mul(fixed_point_t a, fixed_point_t b);
    logic signed [2*FixedPointPrecision-1:0] out = a * b;
    // arithmetic shift
    out = out >>> FixedPointFractionalPrecision;
    if (out > FixedPointMax) out = FixedPointMax;
    if (out < FixedPointMin) out = FixedPointMin;
    return out;
endfunction

function automatic fixed_point_t fixed_point_div(fixed_point_t a, fixed_point_t b);
    logic signed [2*FixedPointPrecision-1:0] out;
    // arithmetic shift
    b = b >>> FixedPointFractionalPrecision;
    out = a / b;
    if (out > FixedPointMax) out = FixedPointMax;
    if (out < FixedPointMin) out = FixedPointMin;
    return out;
endfunction

function automatic fixed_point_t fixed_point_add(fixed_point_t a, fixed_point_t b);
    logic signed [FixedPointPrecision:0] out = a + b;
    if (out > FixedPointMax) out = FixedPointMax;
    if (out < FixedPointMin) out = FixedPointMin;
    return out;
endfunction

function automatic fixed_point_t fixed_point_sub(fixed_point_t a, fixed_point_t b);
    logic signed [FixedPointPrecision:0] out = a - b;
    if (out > FixedPointMax) out = FixedPointMax;
    if (out < FixedPointMin) out = FixedPointMin;
    return out;
endfunction

endpackage
