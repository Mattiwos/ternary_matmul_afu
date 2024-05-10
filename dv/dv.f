
dv/dv_pkg.sv
dv/ternary_matmul_tb.sv
dv/rms_tb.sv
dv/matrix_unit_tb.sv
dv/matrix_fifo_tb.sv

--timing
-j 0
-Wall
-Wno-fatal
--assert
--trace-fst
--trace-structs
--main-top-name "-"

// Run with +verilator+rand+reset+2
--x-assign unique
--x-initial unique

-Wno-PINMISSING
-Wno-GENUNNAMED
-Wno-UNUSEDPARAM
