
package config_pkg;

parameter FixedPointPrecision = 8;
parameter FixedPointExponent = -3;

typedef logic signed [FixedPointPrecision-1:0] fixed_point_t;

localparam fixed_point_t FixedPointMin = (1 << (FixedPointPrecision-1));
localparam fixed_point_t FixedPointMax = (FixedPointMin - 1);

localparam UnaryOperationLutSize = (2 ** FixedPointPrecision);

parameter D = 4;

// index into dimension size
typedef logic [$clog2(D)-1:0] DI_t;

typedef logic signed [1:0] ternary_t;

parameter RmsFixedPointPrecision = 9;
parameter RmsFixedPointExponent = 0;

localparam RmsUnaryOperationLutSize = (2 ** RmsFixedPointPrecision);

typedef logic signed [RmsFixedPointPrecision-1:0] rms_fixed_point_t;

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

localparam NumVectorRegisters = 4;
typedef logic [$clog2(NumVectorRegisters)-1:0] v_addr_t;

typedef enum logic [2:0] {
    ADD,
    SUB,
    MUL,
    DIV,
    EXP,
    SIG
} operation_t;

typedef enum logic [1:0] {
    LDV,
    SV
} load_store_operation_t;

typedef enum logic [2:0] {
    NOP,
    LOAD_STORE,
    ROWWISE_OPERATION,
    TMATMUL,
    RMS
} fu_t;

localparam DdrAddressWidth = 16;
localparam DdrDataWidth = 8;

typedef logic [DdrAddressWidth-1:0] ddr_address_t;
typedef logic [DdrDataWidth-1:0] ddr_data_t;

typedef struct packed {
    fu_t fu;
    operation_t operation;
    v_addr_t v_a;
    v_addr_t v_b;
    v_addr_t v_y;
    load_store_operation_t loadstore_operation;
    ddr_address_t ddr_address;
} instruction_t;

localparam NumInstructions = 38;

typedef logic [$clog2(NumInstructions)-1:0] pc_t;

parameter MatrixFifoSize = 2048;

endpackage
