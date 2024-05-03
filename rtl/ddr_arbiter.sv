
module ddr_arbiter (
    input  logic         clk_i,
    input  logic         rst_ni,

    input  ddr_address_t req1_address_i,
    input  logic         req1_w_en_i,
    input  ddr_data_t    req1_w_data_i,
    output logic         req1_w_done_o,
    input  logic         req1_r_en_i,
    output ddr_data_t    req1_r_data_o,
    output logic         req1_r_valid_o

    input  ddr_address_t req2_address_i,
    input  logic         req2_w_en_i,
    input  ddr_data_t    req2_w_data_i,
    output logic         req2_w_done_o,
    input  logic         req2_r_en_i,
    output ddr_data_t    req2_r_data_o,
    output logic         req2_r_valid_o

    output ddr_address_t ddr_address_o,
    output logic         ddr_w_en_o,
    output ddr_data_t    ddr_w_data_o,
    input  logic         ddr_w_done_i,
    output logic         ddr_r_en_o,
    input  ddr_data_t    ddr_r_data_i,
    input  logic         ddr_r_valid_i
);

endmodule
