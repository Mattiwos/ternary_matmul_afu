
module rowwise_operation import config_pkg::*; #(
    parameter operation_t operation = NOP
) (
    input   logic               clk_i,
    input   logic               rst_ni,

    input   vector_t            a_i,
    input   vector_t            b_i,
    output  logic               in_ready_o,
    input   logic               in_valid_i,

    output  vector_t            vector_o,
    input   logic               out_ready_i,
    output  logic               out_valid_o
);

fixed_point_t operation_result;

case (operation)

NOP: begin
assign operation_result = '0;

end ADD: begin
always_comb operation_result = fixed_point_add(a_i[counter_q], b_i[counter_q]);

end SUB: begin
always_comb operation_result = fixed_point_sub(a_i[counter_q], b_i[counter_q]);

end DIV: begin
always_comb operation_result = fixed_point_div(a_i[counter_q], b_i[counter_q]);

end MUL: begin
always_comb operation_result = fixed_point_mul(a_i[counter_q], b_i[counter_q]);

end EXP: begin
fixed_point_t EXPONENT_LUT [UnaryOperationLutSize];
initial $readmemh("rtl/luts/exp_lut.mem", EXPONENT_LUT);
always_comb operation_result = EXPONENT_LUT[a_i[counter_q]];

end
endcase

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
    counter_d = counter_q;
    vector_d = vector_q;
    state_d = state_q;
    if (state_q == WAITING_FOR_IN) begin
        if (in_valid_i) begin
            state_d = WORKING;
            counter_d = '0;
        end
    end else if (state_q == WORKING) begin
        if (counter_d >= D-1) begin // reached end
            state_d = WAITING_FOR_OUT;
        end
        // array access could probably be optimized with a shift register
        vector_d[counter_q] = operation_result;
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
