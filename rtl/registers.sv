
module registers import config_pkg::*; (
    input  logic                             clk_i,

    input  logic [NumVectorRegisters-1:0]    w_v_en_i,
    input  vector_t [NumVectorRegisters-1:0] w_v_data_i,
    output vector_t [NumVectorRegisters-1:0] r_v_data_o,

    input  logic                             w_tm_en_i,
    input  ternary_matrix_t                  w_tm_data_i,
    output ternary_matrix_t                  r_tm_data_o
);

vector_t [NumVectorRegisters-1:0] vector_registers;
integer i;
always_ff @(posedge clk_i) begin
    for (i = 0; i < NumVectorRegisters; i++) begin
        if (w_v_en_i[i])
            vector_registers[i] <= w_v_data_i[i];
    end
end
assign r_v_data_o = vector_registers;

ternary_matrix_t ternary_matrix_register;
always_ff @(posedge clk_i) begin
    if (w_tm_en_i) begin
        ternary_matrix_register <= w_tm_data_i;
    end
end
assign r_tm_data_o = ternary_matrix_register;

endmodule
