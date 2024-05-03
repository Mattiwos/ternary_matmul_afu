
module matrix_unit import config_pkg::*; (
    input  logic         clk_i,
    input  logic         rst_ni,

    output logic         ready_o,
    input  logic         start_i,

    output ddr_address_t ddr_address_o,
    output logic         ddr_w_en_o,
    output ddr_data_t    ddr_w_data_o,
    input  logic         ddr_w_done_i,
    output logic         ddr_r_en_o,
    input  ddr_data_t    ddr_r_data_i,
    input  logic         ddr_r_valid_i
);

endmodule
