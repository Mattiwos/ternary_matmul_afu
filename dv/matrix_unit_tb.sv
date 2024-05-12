
module matrix_unit_tb
    import config_pkg::*;
    import dv_pkg::*;
    ;

logic      clk_i;
logic      rst_ni;

logic      start_i;

logic      ddr_w_done_i;
ddr_data_t ddr_r_data_i;
logic      ddr_r_valid_i;

matrix_unit matrix_unit (
    .clk_i,
    .rst_ni,

    .start_i,

    .ddr_w_done_i,
    .ddr_r_data_i,
    .ddr_r_valid_i
);

initial begin
    clk_i = 0;
    forever begin
        #1;
        clk_i = !clk_i;
    end
end

initial begin
    repeat(D * D * NumInstructions) @(posedge clk_i);
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

ddr_data_t ddr_data [D*D];
always @(posedge clk_i) begin
    ddr_w_done_i <= 0;
    if (matrix_unit.ddr_w_en_o) begin
        ddr_address_t ddr_address = matrix_unit.ddr_address_o;
        ddr_data_t ddr_w_data = matrix_unit.ddr_w_data_o;
        repeat(2) @(posedge clk_i);
        ddr_data[ddr_address] <= ddr_w_data;
        ddr_w_done_i <= 1;
    end
end
always @(posedge clk_i) begin
    ddr_r_data_i <= 'x;
    ddr_r_valid_i <= 0;
    if (matrix_unit.ddr_r_en_o) begin
        ddr_address_t ddr_address = matrix_unit.ddr_address_o;
        repeat(2) @(posedge clk_i);
        ddr_r_data_i <= ddr_data[ddr_address];
        ddr_r_valid_i <= 1;
    end
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
