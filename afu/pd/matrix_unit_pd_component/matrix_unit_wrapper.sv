module matrix_unit_wrapper
#(
    parameter  ddr_addr_w    = 33,
    parameter  ddr_data_w    = 8,
    parameter  csr_addr_w    = 8,
    parameter  csr_data_w    = 32,
    parameter  imem_w_instr  = 64,
    parameter  imem_w_addr   = 5
) (
    // CLOCK/RST
    input logic
        clk_i,
        rst_n_i,
    // DDR AVMM-HOST interface
    input logic [ddr_data_w-1:0]
        avmm_h_ddr_readdata_i,
    input logic
        avmm_h_ddr_readdatavalid_i,
        avmm_h_ddr_waitreq_i,
    output logic [ddr_data_w-1:0] 
        avmm_h_ddr_writedata_o,
    output logic [ddr_addr_w-1:0]
        avmm_h_ddr_address_o,
    output logic 
        avmm_h_ddr_write_o,
        avmm_h_ddr_read_o,
    // IMEM AVMM-HOST interface
    output logic [imem_w_addr-1:0]  
        avmm_h_imem_address_o,
    output logic         
        avmm_h_imem_chipselect_o,
        avmm_h_imem_write_o,
    output logic [imem_w_instr-1:0]  
        avmm_h_imem_writedata_o,
    input logic [imem_w_instr-1:0]  
        avmm_h_imem_readdata_i,
    // CSR AVMM-AGENT interface
    input logic [7:0]  
        avmm_a_csr_address_i,
    input logic
        avmm_a_csr_chipselect_i,
        avmm_a_csr_write_i,
    input logic [csr_data_w-1:0]
        avmm_a_csr_writedata_i,
    output logic [csr_data_w-1:0]
        avmm_a_csr_readdata_o
);

localparam CSR_ADDR_START = 7'h0;
localparam CSR_ADDR_READY = 7'h1;

// Local signals
logic
    mu_start_i,
    mu_ready_o;

// CSR logic
always_ff@(posedge clk_i) begin
    if(avmm_a_csr_chipselect_i && rst_n_i) begin
        if(avmm_a_csr_write_i) begin
            case(avmm_a_csr_address_i)
                CSR_ADDR_START : begin
                    mu_start_i <= 1'b1;
                end
                default : begin
                    mu_start_i <= 1'b0;
                end
            endcase
        end else begin
            mu_start_i <= 1'b0;
            case(avmm_a_csr_address_i)
                CSR_ADDR_READY : begin
                    avmm_a_csr_readdata_o <= {31'b0, mu_ready_o};
                end
                default : begin
                    // For validation
                    avmm_a_csr_readdata_o <= 32'hAAAAAAAA;
                end
            endcase
        end
    end else begin
        mu_start_i <= 1'b0;
        // For validation
        avmm_a_csr_readdata_o <= 32'hCCCCCCCC;
    end
end

// Constant assignments for IMEM ROM
always_comb begin
    avmm_h_imem_chipselect_o = 1'b1;
    avmm_h_imem_write_o = 1'b0;
    avmm_h_imem_writedata_o = 64'b0;
end

matrix_unit mmu (
    .clk_i                 ( clk_i ),
    .rst_ni                ( rst_n_i ),
    .ready_o               ( mu_ready_o ),
    .start_i               ( mu_start_i ),
    .ddr_address_o         ( avmm_h_ddr_address_o ),
    .ddr_w_en_o            ( avmm_h_ddr_write_o ),
    .ddr_w_data_o          ( avmm_h_ddr_writedata_o ),
    // NOTE: AVMM uses a WAITREQUEST instead of done flag
    .ddr_waitrequest_n_i   (!avmm_h_ddr_waitreq_i ),
    .ddr_r_en_o            ( avmm_h_ddr_read_o ),
    .ddr_r_data_i          ( avmm_h_ddr_readdata_i ),
    .ddr_r_valid_i         ( avmm_h_ddr_readdatavalid_i ),
    .imem_rd_i             ( avmm_h_imem_readdata_i ),
    .imem_addr_o           ( avmm_h_imem_address_o )
);

endmodule