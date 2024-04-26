
module load_store import config_pkg::*; (
    input  logic                               clk_i,
    input  logic                               rst_ni,

    input  load_store_operation_t              operation_i,
    input  ddr_address_t                       ddr_address_i,
    input  logic [$bits(vector_t)-1:0]         vector_i,
    output logic [$bits(vector_t)-1:0]         vector_o,
    output logic                               vector_wen_o,
    input  logic [$bits(ternary_matrix_t)-1:0] matrix_i,
    output logic [$bits(ternary_matrix_t)-1:0] matrix_o,
    output logic                               matrix_wen_o,
    output logic                               in_ready_o,
    input  logic                               in_valid_i,

    output ddr_address_t                       ddr_w_address_o,
    output logic                               ddr_w_en_o,
    output ddr_data_t                          ddr_w_data_o,

    output ddr_address_t                       ddr_r_address_o,
    output logic                               ddr_r_en_o,
    input  ddr_data_t                          ddr_r_data_i
);

localparam MaxVectorCounter = ($bits(vector_t)/DdrDataWidth);
localparam MaxMatrixCounter = ($bits(ternary_matrix_t)/DdrDataWidth);

localparam MaxCounter = (MaxVectorCounter>MaxMatrixCounter) ? MaxVectorCounter : MaxMatrixCounter;

logic [$clog2(MaxCounter):0] counter_d, counter_q;

enum logic [1:0] {
    WAITING_FOR_IN,
    WORKING
} state_d, state_q;

always_comb begin
    in_ready_o = 0;

    counter_d = counter_q;
    state_d = state_q;

    vector_o = 'x;
    vector_wen_o = 0;
    matrix_o = 'x;
    matrix_wen_o = 0;

    ddr_w_address_o = 'x;
    ddr_w_en_o = 0;
    ddr_w_data_o = 'x;

    ddr_r_address_o = 'x;
    ddr_r_en_o = 0;

    if (state_q == WAITING_FOR_IN) begin
        in_ready_o = 1;
        if (in_valid_i) begin
            state_d = WORKING;
            counter_d = '0;
        end
    end else if (state_q == WORKING) begin
        unique case (operation_i)
            LDV: begin
                ddr_r_en_o = 1;
                ddr_r_address_o = ddr_address_i + counter_q;
                vector_wen_o = 1;
                vector_o = vector_i;
                vector_o[DdrDataWidth*counter_q +: DdrDataWidth] = ddr_r_data_i;
                if (counter_q >= ($bits(vector_t)/DdrDataWidth)-1) begin
                    state_d = WAITING_FOR_IN;
                end
            end SV: begin
                ddr_w_en_o = 1;
                ddr_w_address_o = ddr_address_i + counter_q;
                ddr_w_data_o = vector_i[DdrDataWidth*counter_q +: DdrDataWidth];
                if (counter_q >= ($bits(vector_t)/DdrDataWidth)-1) begin
                    state_d = WAITING_FOR_IN;
                end
            end LDTM: begin
                ddr_r_en_o = 1;
                ddr_r_address_o = ddr_address_i + counter_q;
                matrix_wen_o = 1;
                matrix_o = matrix_i;
                matrix_o[DdrDataWidth*counter_q +: DdrDataWidth] = ddr_r_data_i;
                if (counter_q >= ($bits(ternary_matrix_t)/DdrDataWidth)-1) begin
                    state_d = WAITING_FOR_IN;
                end
            end STM: begin
                ddr_w_en_o = 1;
                ddr_w_address_o = ddr_address_i + counter_q;
                ddr_w_data_o = matrix_i[DdrDataWidth*counter_q +: DdrDataWidth];
                if (counter_q >= ($bits(ternary_matrix_t)/DdrDataWidth)-1) begin
                    state_d = WAITING_FOR_IN;
                end
            end
        endcase
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

endmodule
