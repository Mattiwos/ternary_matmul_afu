
module rms_tb
    import config_pkg::*;
    import dv_pkg::*;
    ;

logic         clk_i;
logic         rst_ni;
logic         in_start_i;
fixed_point_t vector_r_data_i;

rms rms (
    .clk_i,
    .rst_ni,
    .in_start_i,
    .vector_r_data_i
);

vector_t a;
always_ff @(posedge clk_i) begin
    if (rms.vector_w_en_o)
        a[rms.vector_w_addr_o] <= rms.vector_w_data_o;
end
assign vector_r_data_i = a[rms.vector_r_addr_o];

initial begin
    clk_i = 0;
    forever begin
        #1;
        clk_i = !clk_i;
    end
end

initial begin
    repeat(5 * D*D) @(posedge clk_i);
    $display("Timed out");
    $fatal;
end

integer fd;

// driver
always @(posedge clk_i) if (rst_ni) begin : driver
    // wait until ready to start
    in_start_i <= 0;
    while (!rms.in_ready_o)
        @(posedge clk_i);

    // print previous result
    $fdisplay(fd, "RMS Value:");
    $fdisplay(fd, fixed_point2real(rms.rms_value_q));
    $fdisplay(fd, "Vector Output:");
    fdisplay_vector(fd, a, 1);
    $fdisplay(fd, "\n");

    // generate random input
    a = random_vector();
    $fdisplay(fd, "Vector Input:");
    fdisplay_vector(fd, a, 1);

    // send data
    in_start_i <= 1;
    @(posedge clk_i);
    in_start_i <= 0;
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

    repeat(5) @(posedge in_start_i);

    $display( "End simulation." );
    $finish();
end

endmodule
