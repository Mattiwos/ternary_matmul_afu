
RTL := $(shell python3 misc/convert_filelist.py Makefile rtl/rtl.f)
# TOP := ternary_matmul_tb
# TOP := rms_tb
TOP := matrix_unit_tb

YOSYS_DATDIR := $(shell yosys-config --datdir)

.PHONY: lint sim synth gls nexys_4_ddr_gls clean

all: clean sim gls

lint: mems
	verilator -f rtl/rtl.f --lint-only --top matrix_unit lint.vlt -Wall

sim: mems
	verilator --Mdir $@_dir -f rtl/rtl.f -f dv/dv.f --binary --top ${TOP}
	./$@_dir/V${TOP} +verilator+rand+reset+2

gls: synth/build/synth.v mems
	verilator -I${YOSYS_DATDIR} --Mdir $@_dir -f synth/gls.f -f dv/dv.f --binary --top ${TOP}
	./$@_dir/V${TOP} +verilator+rand+reset+2

mems: rtl/luts/exp_lut.memh rtl/luts/sig_lut.memh tmi/process.memb

rtl/luts/exp_lut.memh rtl/luts/sig_lut.memh: rtl/luts/generate_luts.py
	cd rtl/luts && python3 generate_luts.py

tmi/process.memb: tmi/assemble.py tmi/process.tmi tmi/sim.py
	python3 tmi/assemble.py tmi/process.tmi $@

synth/build/rtl.sv2v.v: ${RTL} misc/convert_filelist.py Makefile rtl/rtl.f
	mkdir -p synth/build
	sv2v ${RTL} -w $@ -DSYNTHESIS

synth/build/synth.v: synth/build/rtl.sv2v.v synth/yosys.tcl mems
	rm -rf slpp_all
	mkdir -p synth/build
	yosys -p 'tcl synth/yosys.tcl synth/build/rtl.sv2v.v' -l synth/build/yosys.log

xc7: synth/build/xc7.v

synth/build/xc7.v: synth/build/rtl.sv2v.v synth/yosys-xc7.tcl mems
	rm -rf slpp_all
	mkdir -p synth/build
	yosys -p 'tcl synth/yosys-xc7.tcl synth/build/rtl.sv2v.v' -l synth/build/yosys-xc7.log

clean:
	rm -rf \
	 synth/build \
	 obj_dir gls_dir sim_dir dump.fst \
	 rtl/luts/*.memh \
	 tmi/*.memb
