
# Ternary Matmul Processor

* Install Verilog tools from <https://github.com/YosysHQ/oss-cad-suite-build>

## Todo

* Vector registers should be stored in BRAM and and accessible through this interface:

```systemverilog
input  logic         [NumVectorRegisters-1:0] w_v_en_i;
input  DI_t          [NumVectorRegisters-1:0] w_v_addr_i;
input  fixed_point_t [NumVectorRegisters-1:0] w_v_data_i;

input  DI_t          [NumVectorRegisters-1:0] r_v_addr_i;
output fixed_point_t [NumVectorRegisters-1:0] r_v_data_o;
```

* There shall be no ternary matrix register; it should only be accessible directly from DRAM. The `ternary_matmul` module should request directly from DRAM. (There is no need for a cache because a XC7A100T has 4.9MB of BRAM, which isn't even enough for half of a single 2048&times;2048 ternary matrix).

* The tmi instruction set changes:
  * remove `ldtm` instruction
  * remove `stm` instruction
  * modify `tmatmul` instruction to now take in a DRAM address instead of `tm0`

* `load_store` instructions and `ternary_matmul` instructions now block each other.

* Create a general-purpose DDR arbiter to choose between
  * `load_store` DDR requests and `ternary_matmul` requests
  * `matrix_unit` DDR requests and UART DMA requests

* *`NumVectorRegisters` can likely be increased from 4 to 8 with little negative effect.*

* Modules to be nearly rewritten from scratch:
  * `matrix_unit`
  * `registers` -> `vector_registers`
  * `load_store` -> `vector_load_store`
  * `ternary_matmul`
* Nearly unchanged modules:
  * `rowwise_*`
  * `rms`
* Modules to add:
  * `ddr_arbiter`

## References

* <https://docs.amd.com/v/u/en-US/ds180_7Series_Overview>
