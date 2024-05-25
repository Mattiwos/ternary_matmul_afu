
start_gui

create_project matrix_unit matrix_unit -part xc7a100tcsg324-1

add_files -norecurse {
 ../../rtl/luts/rms_sqa_lut.memh
 ../../rtl/luts/exp_lut.memh
 ../../rtl/luts/rms_sqt_lut.memh
 ../../rtl/luts/sig_lut.memh
 ../../tmi/process.memb
}
set_property file_type {Memory File} [get_files -all]
set_property include_dirs ../.. [get_filesets sources_1]

add_files -norecurse {
 ../../rtl/config_pkg.sv
 ../../rtl/vector_registers.sv
 ../../rtl/fus/vector_load_store.sv
 ../../rtl/fus/rowwise_add.sv
 ../../rtl/fus/rowwise_sub.sv
 ../../rtl/fus/rowwise_mul.sv
 ../../rtl/fus/rowwise_div.sv
 ../../rtl/fus/rowwise_exp.sv
 ../../rtl/fus/rowwise_sig.sv
 ../../rtl/fus/rowwise_operation.sv
 ../../rtl/fus/ternary_matmul/matrix_fifo.sv
 ../../rtl/fus/ternary_matmul/ternary_matmul.sv
 ../../rtl/fus/rms.sv
 ../../rtl/matrix_unit.sv
}

add_files -fileset sim_1 -norecurse {
 ../../dv/dv_pkg.sv
 ../../dv/matrix_unit_tb.sv
}
set_property top matrix_unit_tb [get_filesets sim_1]

add_files -fileset constrs_1 -norecurse {
 ../../synth/vivado.xdc
}

set nproc [exec nproc]

set_property STEPS.SYNTH_DESIGN.ARGS.DIRECTIVE PerformanceOptimized [get_runs synth_1]

launch_runs synth_1 -jobs $nproc
wait_on_run synth_1

launch_simulation -mode post-synthesis -type functional
restart

open_saif dump.saif
log_saif [get_object /matrix_unit_tb/matrix_unit/*]
run 400ms
close_saif

read_saif {matrix_unit/matrix_unit.sim/sim_1/synth/func/xsim/dump.saif}
report_power -name {power_1}
