CXX = g++
ifndef VERBOSE
   CXXFLAGS += -w
endif
LDFLAGS ?=
FPGA_DMA_DEBUG ?= 0
CXXFLAGS += -D FPGA_DMA_DEBUG=$(FPGA_DMA_DEBUG)  -g -O2 -fPIC -shared -D EMU_MODE=0 -Wall -Wno-unknown-pragmas -I$(TBB_HOME)/include -fpermissive -std=c++11
CXXFLAGS += -DFPGA_DMA_MAX_BLOCKS=256 -DFPGA_DMA_BLOCK_SIZE=64

ifdef prefix
CXXFLAGS += -I$(prefix)/include
LDFLAGS += -L$(prefix)/lib -L$(prefix)/lib64 
endif

LDFLAGS += -luuid
LDFLAGS += -lsafestr
LDFLAGS += -lrt
LDFLAGS += -ltbb
LDFLAGS += -L$(TBB_HOME)/lib/intel64_lin/gcc4.7/
ifneq ($(TBB_LIB),)
LDFLAGS += -L$(TBB_LIB)
endif

ifeq ($(USE_ASE),1)
   LDFLAGS += -lopae-c-ase
   CXXFLAGS += -DUSE_ASE
   CFLAGS += -DUSE_ASE
else
   LDFLAGS += -ljson-c
   LDFLAGS += -lopae-c
   LDFLAGS += -lhwloc
endif

LDFLAGS += -pthread
LDFLAGS += -lm

SRCS=$(wildcard *.cpp)
OBJS=$(SRCS:.cpp=.o)

ifndef VERBOSE
.SILENT: all
endif

all: $(OBJS) mu_c_lib

fpga_dma.a: fpga_dma.so fpga_dma.o
	ar rcs $@ $^

mu_c_lib: mu_c_lib.so $(OBJS) fpga_dma.a
	$(CXX) -c -o $@ $^ $(LDFLAGS)

%.so: %.o ; $(LINK.c) $(LDFLAGS) -shared $^ -o $@

clean:
	$(RM) mu_c_lib *.o *.so *.a *.dat *.log

.PHONY:all clean
