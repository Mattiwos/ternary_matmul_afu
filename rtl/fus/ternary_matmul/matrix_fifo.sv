
module matrix_fifo import config_pkg::*; (
    input  logic      clk_i,
    input  logic      rst_ni,

    output logic      full_o,
    input  ddr_data_t data_i,
    input  logic      push_i,

    output logic      valid_o,
    output ternary_t  data_o,
    input  logic      pop_i
);

localparam CellsPerData = (DdrDataWidth / $bits(ternary_t));

ternary_t [CellsPerData-1:0] MEM [MatrixFifoSize];
logic we;

logic [$clog2(MatrixFifoSize):0] hi_head_d, hi_head_q;
logic [$clog2(CellsPerData):0] lo_head_d, lo_head_q;
logic [$clog2(MatrixFifoSize):0] tail_d, tail_q;
logic [$clog2(MatrixFifoSize):0] size_d, size_q;

assign full_o = (size_q == NR_ENTRIES);
assign valid_o = (size_q != 0);
assign data_o = valid_o ? MEM[hi_head_q][lo_head_q] : 'x;

always_comb begin
    hi_head_d = hi_head_q;
    lo_head_d = lo_head_q;
    tail_d = tail_q;
    size_d = size_q;
    we = 1'b0;
    if (pop_i && (size_d != 0)) begin
        if (lo_head_q==(CellsPerData-1)) begin
            size_d--;
            lo_head_d = 0;
            hi_head_d++;
        end else begin
            lo_head_d++;
        end
    end
    if (push_i && (size_d != NR_ENTRIES)) begin
        we = 1'b1;
        size_d++;
        tail_d = (tail_d==(NR_ENTRIES-1)) ? '0 : (tail_d+1);
    end
end

always_ff @(posedge clk_i) begin : update_mem
    if (!rst_ni) begin
        hi_head_q <= '0;
        lo_head_q <= '0;
        tail_q <= '0;
        size_q <= '0;
    end else begin
        hi_head_q <= hi_head_d;
        lo_head_q <= lo_head_d;
        tail_q <= tail_d;
        size_q <= size_d;
        if (we)
            MEM[tail_q] <= data_i;
    end
end

endmodule
