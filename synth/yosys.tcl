
yosys -import

read_verilog synth/build/rtl.sv2v.v

prep
opt -full
stat
write_verilog -noexpr -noattr -simple-lhs synth/build/synth.v
