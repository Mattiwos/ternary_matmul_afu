
module vector_load_store import config_pkg::*; (
    input  logic                  clk_i,
    input  logic                  rst_ni,

    output logic                  in_ready_o,
    input  logic                  in_valid_i,
    input  load_store_operation_t vector_operation_i,
    input  ddr_address_t          vector_memory_address_i,

    output DI_t                   vector_addr_o,
    input  fixed_point_t          vector_r_data_i,
    output fixed_point_t          vector_w_data_o,
    output logic                  vector_w_en_o,

    output ddr_address_t          ddr_address_o,
    output logic                  ddr_w_en_o,
    output ddr_data_t             ddr_w_data_o,

    input  logic                  ddr_waitrequest_n_i,
    output logic                  ddr_r_en_o,
    input  ddr_data_t             ddr_r_data_i,
    input  logic                  ddr_r_valid_i
);

if (DdrDataWidth == FixedPointPrecision) begin

    enum logic [1:0] {
        WAITING_FOR_IN,
        WORKING
    } state_d, state_q;

    logic [$clog2(D):0] vector_counter_d, vector_counter_q;
    ddr_address_t vector_memory_address_d, vector_memory_address_q;

    assign in_ready_o = (state_q == WAITING_FOR_IN) && ddr_waitrequest_n_i;

    load_store_operation_t vector_operation_d, vector_operation_q;

    always_comb begin
        state_d = state_q;
        vector_counter_d = vector_counter_q;
        vector_operation_d = vector_operation_q;
        vector_memory_address_d = vector_memory_address_q;

        vector_addr_o = 'x;
        vector_w_data_o = 'x;
        vector_w_en_o = 0;

        ddr_address_o = 'x;
        ddr_w_en_o = 0;
        ddr_w_data_o = 'x;
        ddr_r_en_o = 0;

        if ((state_q == WAITING_FOR_IN)&&(in_valid_i)) begin
            state_d = WORKING;
            vector_counter_d = 0;
            vector_operation_d = vector_operation_i;
            vector_memory_address_d = vector_memory_address_i;
            if (vector_operation_i == LDV) begin
                vector_addr_o = 0;
                ddr_address_o = vector_memory_address_i;
                ddr_r_en_o = 1;
            end else if (vector_operation_i == SV) begin
                vector_addr_o = 0;
                ddr_address_o = vector_memory_address_i;
                ddr_w_en_o = 1;
                ddr_w_data_o = vector_r_data_i;
            end
        end else if ((state_q == WORKING)&&(vector_operation_q == LDV)) begin
            if(ddr_r_valid_i) begin
                // data was recieved from mem
                vector_addr_o = vector_counter_q;
                vector_w_data_o = ddr_r_data_i;
                vector_w_en_o = 1;
            end 
            if ((vector_counter_q < D-1 )) begin
                if(ddr_waitrequest_n_i) begin
                    // request more memory
                    vector_counter_d++;
                    ddr_address_o = vector_memory_address_q + vector_counter_d;
                    ddr_r_en_o = 1;
                end
            end else begin
                state_d = WAITING_FOR_IN;
            end
        end else if ((state_q == WORKING)&&(vector_operation_q == SV) && (ddr_waitrequest_n_i)) begin
            if (vector_counter_q < D-1) begin
                // read from vector register
                vector_counter_d++;
                vector_addr_o = vector_counter_d;
                // save memory
                ddr_w_data_o = vector_r_data_i;
                ddr_address_o = vector_memory_address_q + vector_counter_d;
                ddr_w_en_o = 1;
            end else begin
                state_d = WAITING_FOR_IN;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            state_q <= WAITING_FOR_IN;
            vector_counter_q <= 0;
        end else begin
            state_q <= state_d;
            vector_counter_q <= vector_counter_d;
        end
    end
    always_ff @(posedge clk_i) begin
        vector_operation_q <= vector_operation_d;
        vector_memory_address_q <= vector_memory_address_d;
    end

end else if (DdrDataWidth > FixedPointPrecision) begin
    initial $error("Not implemented.");
end else if (DdrDataWidth < FixedPointPrecision) begin
    initial $error("Not implemented.");
end

endmodule