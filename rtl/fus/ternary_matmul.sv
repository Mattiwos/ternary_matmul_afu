
module ternary_matmul import config_pkg::*; (
    input logic             clk_i,
    input logic             rst_ni,

    input  vector_t         vector_i,
    input  ternary_matrix_t matrix_i,
    output logic            in_ready_o,
    input  logic            in_valid_i,

    output vector_t         result_o,
    output logic            out_valid_o
);

logic [$clog2(D)-1:0] counter_d, counter_q;
vector_t vector_d, vector_q;

assign result_o = vector_q;

enum logic [1:0] {
    WAITING_FOR_IN,
    WORKING,
    SENDING_OUT
} state_d, state_q;

function automatic fixed_point_t ternary_mul(ternary_t ternary, fixed_point_t fixed_point);
    unique case (ternary)
        0: return '0;
        1: return fixed_point;
        -1: return -fixed_point;
        default: return 'x;
    endcase
endfunction

function automatic fixed_point_t fixed_point_add(fixed_point_t a, fixed_point_t b);
    logic signed [FixedPointPrecision:0] out = a + b;
    if (out > FixedPointMax) out = FixedPointMax;
    if (out < FixedPointMin) out = FixedPointMin;
    return out;
endfunction

always_comb begin
    integer i = 'x;
    out_valid_o = 0;
    in_ready_o = 0;

    counter_d = counter_q;
    vector_d = vector_q;
    state_d = state_q;

    if (state_q == WAITING_FOR_IN) begin
        in_ready_o = 1;
        if (in_valid_i) begin
            state_d = WORKING;
            vector_d = '0;
            counter_d = '0;
        end
    end else if (state_q == WORKING) begin
        if (counter_q >= D-1) begin
            state_d = SENDING_OUT;
        end
        // array access could probably be optimized with a shift register
        for (i = 0; i < D; i++) begin
            vector_d[i] =
                fixed_point_add(vector_q[i],
                                ternary_mul(matrix_i[i][counter_q],
                                            vector_i[counter_q]));
        end
        counter_d++;
    end else if (state_q == SENDING_OUT) begin
        out_valid_o = 1;
        state_d = WAITING_FOR_IN;
    end
end

always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        counter_q <= '0;
        vector_q <= '0;
        state_q <= WAITING_FOR_IN;
    end else begin
        counter_q <= counter_d;
        vector_q <= vector_d;
        state_q <= state_d;
    end
end

endmodule
