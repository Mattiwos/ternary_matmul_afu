
module rowwise_operation import config_pkg::*; (
    input  logic         clk_i,
    input  logic         rst_ni,

    output logic         in_ready_o,
    input  logic         in_valid_i,

    input  operation_t   vector_operation_i,
    output DI_t          vector_addr_o,
    output logic         vector_w_en_o,
    output fixed_point_t vector_w_data_o,
    input  fixed_point_t vector1_r_data_i,
    input  fixed_point_t vector2_r_data_i
);

logic [$clog2(D)-1:0] counter_d, counter_q;

fixed_point_t vector_w_data_o;

enum logic [1:0] {
    WAITING_FOR_IN,
    WORKING
} state_d, state_q;

assign in_ready_o = (state_q == WAITING_FOR_IN);
assign vector_w_en_o = (state_q == WORKING);
assign vector_addr_o = counter_q;

always_comb begin
    counter_d = counter_q;
    state_d = state_q;
    if (state_q == WAITING_FOR_IN) begin
        if (in_valid_i) begin
            state_d = WORKING;
            counter_d = '0;
        end
    end else if (state_q == WORKING) begin
        if (counter_q >= D-1) begin
            state_d = WAITING_FOR_IN;
        end
        counter_d++;
    end
end

always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        counter_q <= '0;
        state_q <= WAITING_FOR_IN;
    end else begin
        counter_q <= counter_d;
        state_q <= state_d;
    end
end

fixed_point_t rowwise_add_result;
rowwise_add rowwise_add (
    .a_i(vector1_r_data_i),
    .b_i(vector2_r_data_i),
    .y_o(rowwise_add_result)
);

fixed_point_t rowwise_sub_result;
rowwise_sub rowwise_sub (
    .a_i(vector1_r_data_i),
    .b_i(vector2_r_data_i),
    .y_o(rowwise_sub_result)
);

fixed_point_t rowwise_mul_result;
rowwise_mul rowwise_mul (
    .a_i(vector1_r_data_i),
    .b_i(vector2_r_data_i),
    .y_o(rowwise_mul_result)
);

fixed_point_t rowwise_div_result;
rowwise_div rowwise_div (
    .a_i(vector1_r_data_i),
    .b_i(vector2_r_data_i),
    .y_o(rowwise_div_result)
);

fixed_point_t rowwise_exp_result;
rowwise_exp rowwise_exp (
    .a_i(vector1_r_data_i),
    .y_o(rowwise_exp_result)
);

fixed_point_t rowwise_sig_result;
rowwise_sig rowwise_sig (
    .a_i(vector1_r_data_i),
    .y_o(rowwise_sig_result)
);

always_comb begin
    unique case (vector_operation_i)
        ADD: vector_w_data_o = rowwise_add_result;
        SUB: vector_w_data_o = rowwise_sub_result;
        MUL: vector_w_data_o = rowwise_mul_result;
        DIV: vector_w_data_o = rowwise_div_result;
        EXP: vector_w_data_o = rowwise_exp_result;
        SIG: vector_w_data_o = rowwise_sig_result;
        default: vector_w_data_o = 'x;
    endcase
end

endmodule
