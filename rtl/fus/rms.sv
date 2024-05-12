
module rms import config_pkg::*; (
    input  logic         clk_i,
    input  logic         rst_ni,

    output logic         in_ready_o,
    input  logic         in_start_i,

    output DI_t          vector_addr_o,
    output logic         vector_w_en_o,
    output fixed_point_t vector_w_data_o,
    input  fixed_point_t vector_r_data_i
);

localparam PARALLEL = 2;
localparam LEVELS = $rtoi( $ln(D) / $ln(PARALLEL) );

typedef logic [$clog2(D):0] counter_t;

function automatic counter_t levelWidth(counter_t level);
    counter_t out = D;
    for (int i = 0; i < LEVELS; i++) if (i < level) begin
        out /= PARALLEL;
    end
    return out;
endfunction

initial assert (
    $ceil( $ln(D) / $ln(PARALLEL) )
    == $floor( $ln(D) / $ln(PARALLEL) )
) else $error("Value of PARALLEL is invalid for D.");
initial assert (
    PARALLEL > 1
) else $error("Value of PARALLEL must be greater than 1.");

enum logic [1:0] {
    WAITING_FOR_IN,
    SQUARING,
    AVERAGING,
    DIVIDING
} state_d, state_q;

rms_fixed_point_t [PARALLEL-1:0] rms_vector [D / PARALLEL];

logic [$clog2(D/PARALLEL)-1:0] rms_vector_r_addr;
wire rms_fixed_point_t [PARALLEL-1:0] rms_vector_r_data = rms_vector[rms_vector_r_addr];

logic rms_vector_w_en;
logic [$clog2(D/PARALLEL)-1:0] rms_vector_w_addr;
rms_fixed_point_t [PARALLEL-1:0] rms_vector_w_data;

always_ff @(posedge clk_i) begin
    if (rms_vector_w_en)
        rms_vector[rms_vector_w_addr] <= rms_vector_w_data;
end

counter_t i1_d, i1_q;
counter_t i2_d, i2_q;
fixed_point_t rms_value_d, rms_value_q;

typedef logic signed [RmsFixedPointPrecision-2+PARALLEL:0] rolling_sum_t;
rolling_sum_t [PARALLEL-1:0] rolling_sum_d, rolling_sum_q;

always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        state_q <= WAITING_FOR_IN;
        i1_q <= '0;
        i2_q <= '0;
        rms_value_q <= '0;
        rolling_sum_q <= '0;
    end else begin
        state_q <= state_d;
        i1_q <= i1_d;
        i2_q <= i2_d;
        rms_value_q <= rms_value_d;
        rolling_sum_q <= rolling_sum_d;
    end
end

fixed_point_t div_a;
fixed_point_t div_b;
fixed_point_t div_y;

rowwise_div rowwise_div (
    .a_i(div_a),
    .b_i(div_b),
    .y_o(div_y)
);

rms_fixed_point_t SQUARE_LUT [UnaryOperationLutSize];
initial $readmemh("rtl/luts/rms_sqa_lut.memh", SQUARE_LUT);

fixed_point_t SQRT_LUT [RmsUnaryOperationLutSize];
initial $readmemh("rtl/luts/rms_sqt_lut.memh", SQRT_LUT);

integer i;
always_comb begin
    state_d = state_q;
    i1_d = i1_q;
    i2_d = i2_q;
    rms_value_d = rms_value_q;

    vector_addr_o = 'x;
    vector_w_en_o = 0;
    vector_w_data_o = 'x;

    rms_vector_r_addr = 'x;
    rms_vector_w_en = 0;
    rms_vector_w_addr = 'x;
    rms_vector_w_data = 'x;

    i = 'x;
    in_ready_o = 0;
    rolling_sum_d = rolling_sum_q;
    div_a = 'x;
    div_b = 'x;

    if (state_q == WAITING_FOR_IN) begin
        in_ready_o = 1;
        if (in_start_i) begin
            state_d = SQUARING;
            i1_d = 0;
            i2_d = 0;
        end
    end else if (state_q == SQUARING) begin
        vector_addr_o = i1_q;
        rms_vector_w_addr = (i1_q / PARALLEL);
        rms_vector_r_addr = (i1_q / PARALLEL);

        rms_vector_w_data = rms_vector_r_data;
        rms_vector_w_data[i1_q % PARALLEL] = SQUARE_LUT[ vector_r_data_i ];
        rms_vector_w_en = 1;

        i1_d++;
        if (i1_d == D) begin
            state_d = AVERAGING;
            i1_d = 0;
        end
    end else if (state_q == AVERAGING) begin
        rolling_sum_d[i1_q % PARALLEL] = 0;
        rms_vector_r_addr = i1_q;
        for (i = 0; i < PARALLEL; i++) begin
            rolling_sum_d[i1_q % PARALLEL] += rms_vector_r_data[i];
        end
        rolling_sum_d[i1_q % PARALLEL] /= PARALLEL;

        i1_d++;
        if ((i1_d % PARALLEL) == 0) begin
            rms_vector_w_addr = (i1_q / PARALLEL);
            for (i = 0; i < PARALLEL; i++) begin
                rms_vector_w_data[i] = rolling_sum_d[i];
            end
            rms_vector_w_en = 1;
        end
        if (i1_d == levelWidth(i2_q+1)) begin
            i1_d = 0;
            i2_d++;
        end
        if (i2_d == LEVELS) begin
            state_d = DIVIDING;
            rms_vector_r_addr = 0;
            rms_value_d = SQRT_LUT[rms_vector_r_data[0]];
            i1_d = 0;
            i2_d = 0;
        end
    end else if (state_q == DIVIDING) begin
        vector_w_en_o = 1;
        vector_w_data_o = div_y;
        vector_addr_o = i1_q;
        div_a = vector_r_data_i;
        div_b = rms_value_q;
        i1_d++;
        if (i1_q >= D-1) begin
            state_d = WAITING_FOR_IN;
            i1_d = 0;
        end
    end
end

endmodule
