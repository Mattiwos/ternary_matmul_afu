
module matrix_fifo_tb
    import config_pkg::*;
    import dv_pkg::*;
    ;

logic      clk_i;
logic      rst_ni;

ddr_data_t data_i;
logic      push_i;
logic      pop_i;

localparam CellsPerData = (DdrDataWidth / $bits(ternary_t));

matrix_fifo matrix_fifo (
    .clk_i,
    .rst_ni,
    .data_i,
    .push_i,
    .pop_i
);

initial begin
    clk_i = 0;
    forever begin
        #1;
        clk_i = !clk_i;
    end
end

task automatic push();
    push_i = 1;
    data_i = $urandom();
    if (matrix_fifo.full_o)
        $display("Full, but trying to push %b", data_i);
    else
        $display("Pushing %b", data_i);
    @(negedge clk_i);
    #0;
    push_i = 0;
endtask

task automatic pop();
    pop_i = 1;
    if (matrix_fifo.valid_o)
        $display("Popped %b", matrix_fifo.data_o);
    else
        $display("Empty, but tried to pop %b", matrix_fifo.data_o);
    @(negedge clk_i);
    pop_i = 0;
endtask

task automatic poppush();
    pop_i = 1;
    push_i = 1;
    data_i = $urandom();
    if (matrix_fifo.valid_o)
        $display("Popped %b", matrix_fifo.data_o);
    else
        $display("Empty, but tried to pop %b", matrix_fifo.data_o);
    if (matrix_fifo.full_o)
        $display("Full, but trying to push %b", data_i);
    else
        $display("Pushing %b", data_i);
    @(negedge clk_i);
    pop_i = 0;
    push_i = 0;
endtask

// Run
initial begin
    $dumpfile( "dump.fst" );
    $dumpvars;
    $display( "Begin simulation." );

    rst_ni = 0;
    @(negedge clk_i);
    @(negedge clk_i);
    rst_ni = 1;

    repeat(2) push();
    repeat(2*CellsPerData) pop();

    $finish;
end

endmodule
