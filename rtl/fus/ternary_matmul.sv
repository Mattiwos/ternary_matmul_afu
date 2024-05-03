
module ternary_matmul import config_pkg::*; (
    input logic          clk_i,
    input logic          rst_ni,

    output logic         in_ready_o,
    input  logic         in_valid_i,

    output logic         vector_w_en_o,
    output DI_t          vector_w_addr_o,
    output fixed_point_t vector_w_data_o,
    output DI_t          vector_r_addr_o,
    input  fixed_point_t vector_r_data_i,

    output ddr_address_t ddr_address_o,
    output logic         ddr_r_en_o,
    input  ddr_data_t    ddr_r_data_i,
    input  logic         ddr_r_valid_i
);

endmodule
