
module vector_registers import config_pkg::*; (
    input  logic                                  clk_i,

    input  logic         [NumVectorRegisters-1:0] vector_w_en_i,
    input  DI_t          [NumVectorRegisters-1:0] vector_w_addr_i,
    input  fixed_point_t [NumVectorRegisters-1:0] vector_w_data_i,
    input  DI_t          [NumVectorRegisters-1:0] vector_r_addr_i,
    output fixed_point_t [NumVectorRegisters-1:0] vector_r_data_o
);

genvar i_gen;
for (i_gen = 0; i_gen < NumVectorRegisters; i_gen++) begin
    fixed_point_t vector_register [D];
    always_ff @(posedge clk_i) begin
        if (vector_w_en_i[i_gen])
            vector_register[vector_w_addr_i[i_gen]] <= vector_w_data_i[i_gen];
    end
    assign vector_r_data_o[i_gen] = vector_register[vector_r_addr_i[i_gen]];
end

endmodule
