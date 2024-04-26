
module rowwise_operation import config_pkg::*; (
    input   logic       clk_i,
    input   logic       rst_ni,

    input   vector_t    a_i,
    input   vector_t    b_i,
    input   operation_t operation_i,
    output  logic       in_ready_o,
    input   logic       in_valid_i,

    output  vector_t    new_result_o,
    input   vector_t    old_result_i
);

logic [$clog2(D)-1:0] counter_d, counter_q;

wire fixed_point_t row_operand_1 = a_i[counter_q];
wire fixed_point_t row_operand_2 = (operation_i inside {EXP,SIG}) ? 'x : b_i[counter_q];
fixed_point_t row_result;

enum logic [1:0] {
    WAITING_FOR_IN,
    WORKING
} state_d, state_q;

assign in_ready_o = (state_q == WAITING_FOR_IN);

always_comb begin
    counter_d = counter_q;
    state_d = state_q;
    new_result_o = 'x;
    if (state_q == WAITING_FOR_IN) begin
        if (in_valid_i) begin
            state_d = WORKING;
            counter_d = '0;
        end
    end else if (state_q == WORKING) begin
        new_result_o = old_result_i;
        new_result_o[counter_q] = row_result;
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
    .a_i(row_operand_1),
    .b_i(row_operand_2),
    .y_o(rowwise_add_result)
);

fixed_point_t rowwise_sub_result;
rowwise_sub rowwise_sub (
    .a_i(row_operand_1),
    .b_i(row_operand_2),
    .y_o(rowwise_sub_result)
);

fixed_point_t rowwise_mul_result;
rowwise_mul rowwise_mul (
    .a_i(row_operand_1),
    .b_i(row_operand_2),
    .y_o(rowwise_mul_result)
);

fixed_point_t rowwise_div_result;
rowwise_div rowwise_div (
    .a_i(row_operand_1),
    .b_i(row_operand_2),
    .y_o(rowwise_div_result)
);

fixed_point_t rowwise_exp_result;
rowwise_exp rowwise_exp (
    .a_i(row_operand_1),
    .y_o(rowwise_exp_result)
);

fixed_point_t rowwise_sig_result;
rowwise_sig rowwise_sig (
    .a_i(row_operand_1),
    .y_o(rowwise_sig_result)
);

always_comb begin
    unique case (operation_i)
        ADD: row_result = rowwise_add_result;
        SUB: row_result = rowwise_sub_result;
        MUL: row_result = rowwise_mul_result;
        DIV: row_result = rowwise_div_result;
        EXP: row_result = rowwise_exp_result;
        SIG: row_result = rowwise_sig_result;
        default: row_result = 'x;
    endcase
end

endmodule
