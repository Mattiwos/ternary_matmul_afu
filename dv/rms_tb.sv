
module rms_tb
    import config_pkg::*;
    import dv_pkg::*;
    ;

logic               clk_i;
logic               rst_ni;

vector_t            a;
logic               in_ready;
logic               in_valid;

logic               out_ready;
logic               out_valid;

rms rms (
    .clk_i,
    .rst_ni,

    .a_i(a),
    .in_ready_o(in_ready),
    .in_valid_i(in_valid),

    .out_ready_i(out_ready),
    .out_valid_o(out_valid)
);

initial begin
    clk_i = 0;
    forever begin
        #1;
        clk_i = !clk_i;
    end
end

initial begin
    repeat(1000) @(posedge clk_i);
    $display("Timed out");
    $fatal;
end

// driver
always @(posedge clk_i) if (rst_ni) begin : driver
    // wait until adder is ready for input
    in_valid <= 0;
    while (!in_ready)
        @(posedge clk_i);

    // generate random input
    a <= random_vector();

    // send data
    in_valid <= 1;
    @(posedge clk_i);
    in_valid <= 0;
end

integer fd;

// monitor
integer num_tests = 0;
always @(posedge clk_i) if (rst_ni) begin : monitor
    // wait until adder output is valid
    out_ready <= 1;
    while (!out_valid || !out_ready)
        @(posedge clk_i);
    out_ready <= 0;

    $fdisplay(fd, "Vector Input:");
    fdisplay_vector(fd, a, 1);
    $fdisplay(fd, "RMS Value:");
    $fdisplay(fd, fixed_point2real(rms.rms_o));
    $fdisplay(fd, "Vector Output:");
    fdisplay_vector(fd, rms.y_o, 1);
    $fdisplay(fd, "\n");

    num_tests <= num_tests+1;
end

// Run
initial begin
    $dumpfile( "dump.fst" );
    $dumpvars;
    $display( "Begin simulation." );

    fd = $fopen("rms.txt", "w");

    rst_ni = 0;
    @(negedge clk_i);
    @(negedge clk_i);
    rst_ni = 1;

    repeat(100) @(posedge clk_i);

    $display( "End simulation." );
    $finish();
end

endmodule
