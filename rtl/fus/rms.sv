
module rms import config_pkg::*; (
    input  logic         clk_i,
    input  logic         rst_ni,

    output logic         in_ready_o,
    input  logic         in_valid_i,
    input  vector_t      a_i,

    input  logic         out_ready_i,
    output logic         out_valid_o,
    output fixed_point_t rms_o,
    output vector_t      y_o
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

enum logic [2:0] {
    WAITING_FOR_IN,
    SQUARING,
    AVERAGING,
    DIVIDING,
    WAITING_FOR_OUT
} state_d, state_q;


rms_vector_t rms_vector_d, rms_vector_q;
vector_t out_vector_d, out_vector_q;
counter_t i1_d, i1_q;
counter_t i2_d, i2_q;
fixed_point_t rms_value_d, rms_value_q;
assign rms_o = rms_value_q;

assign y_o = out_vector_d;

always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        state_q <= WAITING_FOR_IN;
        rms_vector_q <= '0;
        out_vector_q <= '0;
        i1_q <= '0;
        i2_q <= '0;
        rms_value_q <= '0;
    end else begin
        state_q <= state_d;
        rms_vector_q <= rms_vector_d;
        out_vector_q <= out_vector_d;
        i1_q <= i1_d;
        i2_q <= i2_d;
        rms_value_q <= rms_value_d;
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
initial $readmemh("rtl/luts/rms_sqa_lut.mem", SQUARE_LUT);

fixed_point_t SQRT_LUT [RmsUnaryOperationLutSize];
initial $readmemh("rtl/luts/rms_sqt_lut.mem", SQRT_LUT);

integer i;
logic signed [RmsFixedPointPrecision-2+PARALLEL:0] rolling_sum;
always_comb begin
    state_d = state_q;
    rms_vector_d = rms_vector_q;
    out_vector_d = out_vector_q;
    i1_d = i1_q;
    i2_d = i2_q;
    rms_value_d = rms_value_q;

    i = 'x;
    in_ready_o = 0;
    out_valid_o = 0;
    rolling_sum = 'x;
    div_a = 'x;
    div_b = 'x;

    if (state_q == WAITING_FOR_IN) begin
        in_ready_o = 1;
        if (in_valid_i) begin
            state_d = SQUARING;
            i1_d = 0;
            i2_d = 0;
        end
    end else if (state_q == SQUARING) begin
        rms_vector_d[i1_q] = SQUARE_LUT[ a_i[i1_q] ];

        i1_d++;
        if (i1_d == D) begin
            state_d = AVERAGING;
            i1_d = 0;
        end
    end else if (state_q == AVERAGING) begin
        rolling_sum = 0;
        for (i = 0; i < PARALLEL; i++) begin
            rolling_sum += rms_vector_q[(PARALLEL*i1_q)+i];
        end
        rolling_sum /= PARALLEL;
        rms_vector_d[i1_q] = rolling_sum;

        `ifndef SYNTHESIS
        $display("i1=%d i2=%d", i1_q, i2_q);
        `endif

        i1_d++;
        if (i1_d == levelWidth(i2_q+1)) begin
            i1_d = 0;
            i2_d++;
        end
        if (i2_d == LEVELS) begin
            state_d = DIVIDING;
            rms_value_d = SQRT_LUT[rms_vector_q[0]];
            i1_d = 0;
            i2_d = 0;
        end
    end else if (state_q == DIVIDING) begin
        div_a = a_i[i1_q];
        div_b = rms_value_q;
        out_vector_d[i1_q] = div_y;
        i1_d++;
        if (i1_d == D) begin
            state_d = WAITING_FOR_OUT;
            i1_d = 0;
        end
    end else if (state_q == WAITING_FOR_OUT) begin
        out_valid_o = 1;
        if (out_ready_i) begin
            state_d = WAITING_FOR_IN;
        end
    end else begin
        // `ifndef SYNTHESIS
        // $error("Unknown state");
        // `endif
    end
end

endmodule
