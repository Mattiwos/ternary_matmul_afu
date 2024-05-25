
module ternary_matmul import config_pkg::*; (
    input logic          clk_i,
    input logic          rst_ni,

    output logic         in_ready_o,
    input  logic         in_valid_i,
    input  ddr_address_t maxtrix_memory_address_i,

    output DI_t          vector_addr_o,
    output logic         vector_w_en_o,
    output fixed_point_t vector_w_data_o,
    input  fixed_point_t vector_r_data_i,

    output ddr_address_t ddr_address_o,
    output logic         ddr_r_en_o,
    input  ddr_data_t    ddr_r_data_i,
    input  logic         ddr_r_valid_i
);

enum logic [1:0] {
    WAITING_FOR_IN,
    WORKING,
    COPYING
} state_d, state_q;

// Read from DDR into FIFO

enum logic [1:0] {
    IDLE,
    START,
    READING,
    DONE
} ddr_state_d, ddr_state_q;

logic      fifo_full;
ddr_data_t fifo_data_i;
logic      fifo_push;

logic      fifo_valid;
ternary_t  fifo_data_o;
logic      fifo_pop;

matrix_fifo matrix_fifo (
    .clk_i,
    .rst_ni,

    .full_o(fifo_full),
    .data_i(fifo_data_i),
    .push_i(fifo_push),

    .valid_o(fifo_valid),
    .data_o(fifo_data_o),
    .pop_i(fifo_pop)
);

localparam CellsPerData = (DdrDataWidth / $bits(ternary_t));
localparam NumDdrReads = D*D / CellsPerData;

typedef logic [$clog2(NumDdrReads):0] ddr_counter_t;
ddr_counter_t ddr_counter_d, ddr_counter_q;

always_comb begin
    fifo_push = 0;
    fifo_data_i = 'x;

    ddr_counter_d = ddr_counter_q;
    ddr_state_d = ddr_state_q;

    ddr_address_o = 'x;
    ddr_r_en_o = 0;

    if (ddr_state_q == IDLE && state_q == WORKING) begin
        ddr_counter_d = 0;
        ddr_state_d = START;
    end else if (ddr_state_q == START && !fifo_full) begin
        ddr_address_o = maxtrix_memory_address_i + ddr_counter_q;
        ddr_r_en_o = 1;
        ddr_state_d = READING;
    end else if (ddr_state_q == READING && ddr_r_valid_i) begin
        fifo_push = 1;
        fifo_data_i = ddr_r_data_i;
        ddr_counter_d++;
        if (ddr_counter_d < NumDdrReads) begin
            ddr_state_d = START;
        end else begin
            ddr_state_d = DONE;
            ddr_counter_d = 0;
        end
    end else if (ddr_state_q == DONE && state_q != WORKING) begin
        ddr_state_d = IDLE;
    end
end

always_ff @(posedge clk_i) begin
    ddr_counter_q <= ddr_counter_d;
end
always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        ddr_state_q <= IDLE;
    end else begin
        ddr_state_q <= ddr_state_d;
    end
end

// Read from FIFO into Matmul

localparam RollingSumPrecision = 2*FixedPointPrecision;
typedef logic signed [RollingSumPrecision-1:0] rolling_sum_t;

localparam rolling_sum_t RollingSumMin = (1 << (RollingSumPrecision-1));
localparam rolling_sum_t RollingSumMax = (RollingSumMin - 1);

function automatic fixed_point_t ternary_mul(ternary_t ternary, fixed_point_t fixed_point);
    unique case (ternary)
        0: return '0;
        1: return fixed_point;
        -1: return -fixed_point;
        default: return 'x;
    endcase
endfunction

function automatic rolling_sum_t fixed_point_add(rolling_sum_t a, fixed_point_t b);
    logic signed [RollingSumPrecision:0] out = a + b;
    if (out < RollingSumMin) out = RollingSumMin;
    if (out > RollingSumMax) out = RollingSumMax;
    return out;
endfunction

logic         rolling_sum_w_en;
DI_t          rolling_sum_addr;
rolling_sum_t rolling_sum_w_data;
rolling_sum_t rolling_sum_r_data;
fixed_point_t rolling_sum_r_data_clamped;
always_comb begin
    if (rolling_sum_r_data < FixedPointMin) rolling_sum_r_data_clamped = FixedPointMin;
    else if (rolling_sum_r_data > FixedPointMax) rolling_sum_r_data_clamped = FixedPointMax;
    else rolling_sum_r_data_clamped = rolling_sum_r_data;
end

rolling_sum_t rolling_sum_vector [D];
always_ff @(posedge clk_i) begin
    if (rolling_sum_w_en)
        rolling_sum_vector[rolling_sum_addr] <= rolling_sum_w_data;
end
assign rolling_sum_r_data = rolling_sum_vector[rolling_sum_addr];

typedef logic [$clog2(D):0] counter_t;

counter_t i1_d, i1_q;
counter_t i2_d, i2_q;

assign in_ready_o = (state_q == WAITING_FOR_IN);
always_comb begin
    i1_d = i1_q;
    i2_d = i2_q;
    state_d = state_q;

    rolling_sum_w_en = 0;
    rolling_sum_addr = 'x;
    rolling_sum_w_data = 'x;

    fifo_pop = 0;

    vector_addr_o = 'x;
    vector_w_en_o = 0;
    vector_w_data_o = 'x;
    if (state_q == WAITING_FOR_IN && in_valid_i) begin
        i1_d = 0;
        i2_d = 0;
        state_d = WORKING;
    end else if (state_q == WORKING && fifo_valid) begin
        // vector_d[i1] =
        //     fixed_point_add(vector_q[i1],
        //                     ternary_mul(matrix_i[i1][i2],
        //                                 vector_i[i2]));
        rolling_sum_w_en = 1;
        rolling_sum_addr = i1_q;
        vector_addr_o = i2_q;
        rolling_sum_w_data = fixed_point_add(((i1_q==0) ? 0 : rolling_sum_r_data),
                                             ternary_mul(fifo_data_o,
                                                         vector_r_data_i));
        fifo_pop = 1;

        i1_d++;
        if (i1_d >= D) begin
            i1_d = 0;
            i2_d++;
        end
        if (i2_d >= D) begin
            i2_d = 0;
            state_d = COPYING;
        end
    end else if (state_q == COPYING) begin
        vector_addr_o = i1_q;
        vector_w_en_o = 1;
        vector_w_data_o = rolling_sum_r_data_clamped;
        i1_d++;
        if (i1_d >= D) begin
            i1_d = 0;
            state_d = WAITING_FOR_IN;
        end
    end
end

always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        state_q <= WAITING_FOR_IN;
    end else begin
        state_q <= state_d;
    end
end
always_ff @(posedge clk_i) begin
    i1_q <= i1_d;
    i2_q <= i2_d;
end

endmodule
