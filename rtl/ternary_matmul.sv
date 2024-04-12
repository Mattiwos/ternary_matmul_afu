
module ternary_matmul import config_pkg::*; (
    input   logic               clk_i,
    input   logic               rst_ni,

    input   vector_t            vector_i,
    input   ternary_matrix_t    matrix_i,
    output  logic               in_ready_o,
    input   logic               in_valid_i,

    output  vector_t            vector_o,
    input   logic               out_ready_i,
    output  logic               out_valid_o
);

logic [$clog2(D)-1:0] counter_d, counter_q;
vector_t vector_d, vector_q;

assign vector_o = vector_q;

enum logic [1:0] {
    WAITING_FOR_IN,
    WORKING,
    WAITING_FOR_OUT
} state_d, state_q;

assign in_ready_o = (state_q == WAITING_FOR_IN);
assign out_valid_o = (state_q == WAITING_FOR_OUT);

always_comb begin
    integer i = 'x;
    counter_d = counter_q;
    vector_d = vector_q;
    state_d = state_q;
    if (state_q == WAITING_FOR_IN) begin
        if (in_valid_i) begin
            state_d = WORKING;
            for (i = 0; i < D; i++)
                vector_d[i] = '0;
            counter_d = '0;
        end
    end else if (state_q == WORKING) begin
        if (counter_d >= D-1) begin // reached end
            state_d = WAITING_FOR_OUT;
        end
        // array access could probably be optimized with a shift register
        for (i = 0; i < D; i++) begin
            vector_d[i] =
                fixed_point_add(vector_q[i],
                                ternary_mul(matrix_i[i][counter_q],
                                            vector_i[counter_q]));
        end
        counter_d++;
    end else if (state_q == WAITING_FOR_OUT) begin
        if (out_ready_i) begin
            state_d = WAITING_FOR_IN;
        end
    end
end

always_ff @(posedge clk_i) begin
    integer i = 'x;
    if (!rst_ni) begin
        counter_q <= '0;
        for (i = 0; i < D; i++)
            vector_q[i] <= '0;
        state_q <= WAITING_FOR_IN;
    end else begin
        counter_q <= counter_d;
        vector_q <= vector_d;
        state_q <= state_d;
    end
end

endmodule
