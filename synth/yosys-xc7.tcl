
yosys -import

read_verilog synth/build/rtl.sv2v.v

synth_xilinx -top rms -family xc7
write_verilog -noexpr -noattr -simple-lhs synth/build/xc7.v
