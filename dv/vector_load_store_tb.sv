
module vector_load_store_tb
    import config_pkg::*;
    import dv_pkg::*;
    ;

logic                  clk_i;
logic                  rst_ni;

logic                  in_valid_i;

load_store_operation_t vector_operation_i;
ddr_address_t          vector_memory_address_i;

fixed_point_t          vector_r_data_i;

logic                  ddr_w_done_i;
ddr_data_t             ddr_r_data_i;
logic                  ddr_r_valid_i;

vector_load_store vector_load_store (
    .clk_i,
    .rst_ni,

    .in_valid_i,

    .vector_operation_i,
    .vector_memory_address_i,

    .vector_r_data_i,

    .ddr_w_done_i,
    .ddr_r_data_i,
    .ddr_r_valid_i
);

ddr_data_t ddr_data [D];
always @(posedge clk_i) begin
    ddr_w_done_i <= 0;
    if (vector_load_store.ddr_w_en_o) begin
        ddr_address_t ddr_address = vector_load_store.ddr_address_o;
        ddr_data_t ddr_w_data = vector_load_store.ddr_w_data_o;
        repeat(2) @(posedge clk_i);
        ddr_data[ddr_address] <= ddr_w_data;
        ddr_w_done_i <= 1;
    end
end
always @(posedge clk_i) begin
    ddr_r_data_i <= 'x;
    ddr_r_valid_i <= 0;
    if (vector_load_store.ddr_r_en_o) begin
        ddr_address_t ddr_address = vector_load_store.ddr_address_o;
        repeat(2) @(posedge clk_i);
        ddr_r_data_i <= ddr_data[ddr_address];
        ddr_r_valid_i <= 1;
    end
end

vector_t a;
always_ff @(posedge clk_i) begin
    if (vector_load_store.vector_w_en_o)
        a[vector_load_store.vector_addr_o] <= vector_load_store.vector_w_data_o;
end
assign vector_r_data_i = a[vector_load_store.vector_addr_o];

initial begin
    clk_i = 0;
    forever begin
        #1;
        clk_i = !clk_i;
    end
end

initial begin
    repeat(5 * 8 * D) @(posedge clk_i);
    $display("Timed out");
    $fatal;
end

int num_tests = 0;

// driver
always @(posedge clk_i) if (rst_ni) begin : driver
    // wait until ready to start
    in_valid_i <= 0;
    while (!vector_load_store.in_ready_o)
        @(posedge clk_i);

    @(posedge clk_i);

    if (num_tests%2) begin
        // generate random store
        a <= random_vector();
        vector_operation_i <= SV;
        vector_memory_address_i <= 0;
        $display("Starting SV (a -> ddr)");
    end else begin
        // generate random store
        ddr_data <= random_vector();
        vector_operation_i <= LDV;
        vector_memory_address_i <= 0;
        $display("Starting LDV (a <- ddr)");
    end
    num_tests <= num_tests+1;

    // send data
    in_valid_i <= 1;
    @(posedge clk_i);
    in_valid_i <= 0;
end

// monitor
always @(posedge vector_load_store.in_ready_o) if (rst_ni) begin : monitor
    for (int i = 0; i < D; i++) begin
        assert (a[i] == ddr_data[i])
        else   $display("Vectors don't match: a[%0d]=%0h, ddr[%0d]=%0h", i, a[i], i, ddr_data[i]);
    end
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

    repeat(6) @(posedge in_valid_i);

    $display( "End simulation." );
    $finish();
end

endmodule
