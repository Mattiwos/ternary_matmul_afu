
module matrix_unit_tb
    import config_pkg::*;
    import dv_pkg::*;
    ;

logic         clk_i;
logic         rst_ni;

logic         start_i;

ddr_data_t    ddr_r_data_i;

matrix_unit matrix_unit (
    .clk_i,
    .rst_ni,

    .start_i,

    .ddr_r_data_i
);

initial begin
    clk_i = 0;
    forever begin
        #1;
        clk_i = !clk_i;
    end
end

initial begin
    repeat(D * NumInstructions * 2) @(posedge clk_i);
    $display("Timed out");
    $fatal;
end

// driver
always @(posedge clk_i) if (rst_ni) begin : driver
    // wait until adder is ready for input
    start_i <= 0;
    while (!matrix_unit.ready_o)
        @(posedge clk_i);

    // send data
    start_i <= 1;
    @(posedge clk_i);
    start_i <= 0;
end

always @(posedge clk_i) if (rst_ni) begin
    if (matrix_unit.ddr_r_en_o)
        ddr_r_data_i <= random_ddr_data();
end

// monitor
always @(posedge clk_i) if (rst_ni) begin : monitor

    // wait until process is complete
    while (!matrix_unit.ready_o || !start_i)
        @(posedge clk_i);
    @(posedge clk_i);
    while (!matrix_unit.ready_o)
        @(posedge clk_i);

    $display( "End simulation." );
    $finish;
end

// Run
initial begin
    $dumpfile( "dump.fst" );
    $dumpvars;
    $display( "Begin simulation." );

    rst_ni = 0;
    @(negedge clk_i);
    @(negedge clk_i);
    rst_ni = 1;
    start_i = 1;
    @(negedge clk_i);
    start_i = 0;

end

endmodule
