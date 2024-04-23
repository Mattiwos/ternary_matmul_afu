
RTL := $(shell python3 misc/convert_filelist.py Makefile rtl/rtl.f)
TOP := ternary_matmul_tb
# TOP := rowwise_operation_tb

YOSYS_DATDIR := $(shell yosys-config --datdir)

.PHONY: lint sim synth gls nexys_4_ddr_gls clean

all: clean sim gls

lint: rtl/luts/exp_lut.mem
	verilator -f rtl/rtl.f --lint-only --top ternary_matmul

sim: rtl/luts/exp_lut.mem
	verilator --Mdir $@_dir -f rtl/rtl.f -f dv/dv.f --binary --top ${TOP}
	./$@_dir/V${TOP} +verilator+rand+reset+2

gls: synth/build/synth.v rtl/luts/exp_lut.mem
	verilator -I${YOSYS_DATDIR} --Mdir $@_dir -f synth/gls.f -f dv/dv.f --binary --top ${TOP}
	./$@_dir/V${TOP} +verilator+rand+reset+2

rtl/luts/exp_lut.mem: rtl/luts/generate_luts.py
	cd rtl/luts && python3 generate_luts.py

synth/build/rtl.sv2v.v: ${RTL} misc/convert_filelist.py Makefile rtl/rtl.f
	mkdir -p synth/build
	sv2v ${RTL} -w $@

synth/build/synth.v: synth/build/rtl.sv2v.v synth/yosys.tcl rtl/luts/exp_lut.mem
	rm -rf slpp_all
	mkdir -p synth/build
	yosys -p 'tcl synth/yosys.tcl synth/build/rtl.sv2v.v' -l synth/build/yosys.log

clean:
	rm -rf \
	 synth/build \
	 obj_dir gls_dir sim_dir dump.fst \
	 rtl/luts/exp_lut.mem
