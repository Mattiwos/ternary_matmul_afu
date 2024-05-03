
module vector_load_store import config_pkg::*; (
    input  logic                  clk_i,
    input  logic                  rst_ni,

    input  load_store_operation_t vector_operation_i,
    output DI_t                   vector_addr_o,
    input  fixed_point_t          vector_r_data_i,
    output fixed_point_t          vector_w_data_o,
    output logic                  vector_w_en_o,
    input  ddr_address_t          vector_memory_address_i,

    output logic                  in_ready_o,
    input  logic                  in_valid_i,

    output ddr_address_t          ddr_address_o,
    output logic                  ddr_w_en_o,
    output ddr_data_t             ddr_w_data_o,
    input  logic                  ddr_w_done_i,
    output logic                  ddr_r_en_o,
    input  ddr_data_t             ddr_r_data_i,
    input  logic                  ddr_r_valid_i
);

endmodule
