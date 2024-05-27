import ccip_if_pkg::*;
import ccip_avmm_pkg::*;

`include "platform_if.vh"

module mu_afu_system_wrapper import config_pkg::*; #
(
  parameter NUM_LOCAL_MEM_BANKS =                 1
) 
(
  input primary_clk,
  input user_clk,
  input	reset,

`ifdef PLATFORM_PROVIDES_LOCAL_MEMORY
  // Local memory interface
  avalon_mem_if.to_fiu                            local_mem[NUM_LOCAL_MEM_BANKS],
`endif

  output                                          avmm_mmio_waitrequest,
  output [CCIP_AVMM_MMIO_DATA_WIDTH-1:0]          avmm_mmio_readdata,
  output                                          avmm_mmio_readdatavalid,
  input                                           avmm_mmio_burstcount,
  input  [CCIP_AVMM_MMIO_DATA_WIDTH-1:0]          avmm_mmio_writedata,
  input  [CCIP_AVMM_MMIO_ADDR_WIDTH-1:0]          avmm_mmio_address,
  input                                           avmm_mmio_write,
  input                                           avmm_mmio_read,
  input  [(CCIP_AVMM_MMIO_DATA_WIDTH/8)-1:0]      avmm_mmio_byteenable,

  input                                           host_write_waitrequest,
  output [CCIP_AVMM_REQUESTOR_BURST_WIDTH-1:0]    host_write_burstcount,
  output [CCIP_AVMM_REQUESTOR_DATA_WIDTH-1:0]     host_write_writedata,
  output [CCIP_AVMM_REQUESTOR_WR_ADDR_WIDTH-2:0]  host_write_address,      // not using the extra 49th bit for write fences
  output                                          host_write_write,
  input  [1:0]                                    host_write_response,
  input                                           host_write_writeresponsevalid,
  output [(CCIP_AVMM_REQUESTOR_DATA_WIDTH/8)-1:0] host_write_byteenable,

  input                                           host_read_waitrequest,
  input  [CCIP_AVMM_REQUESTOR_DATA_WIDTH-1:0]     host_read_readdata,
  input                                           host_read_readdatavalid,
  output [CCIP_AVMM_REQUESTOR_BURST_WIDTH-1:0]    host_read_burstcount,
  output [CCIP_AVMM_REQUESTOR_RD_ADDR_WIDTH-1:0]  host_read_address,
  output                                          host_read_read,
  output [(CCIP_AVMM_REQUESTOR_DATA_WIDTH/8)-1:0] host_read_byteenable
);

// Block below is for the DDR4 interface
`ifdef PLATFORM_PROVIDES_LOCAL_MEMORY

  // memory map offset for byte address, used to align port concatination
  logic [5:0] mm_byte_offset [NUM_LOCAL_MEM_BANKS];

  // DMA will send out bursts of 4 (max) to the memory controllers
  genvar n;
  generate
    for (n = 0; n < NUM_LOCAL_MEM_BANKS; n = n + 1)
    begin : mem_burstcount
      assign local_mem[n].burstcount[6:3] = '0;
 	  end
  endgenerate

`endif

  logic dma_clk_clk;
  logic mu_clk_clk;
  logic host_reset_reset;

  assign host_reset_reset = reset;
  assign dma_clk_clk = primary_clk;
  assign mu_clk_clk = user_clk;

  // Signals are implicitly connected to see the system module definition see:
  //  afu/pd/mu_afu_system/mu_afu_system/synth/mu_afu_system.v
  mu_afu_system u0 (
  `ifdef PLATFORM_PROVIDES_LOCAL_MEMORY
    .ddr4a_host_dma_waitrequest       (local_mem[0].waitrequest),
    .ddr4a_host_dma_readdata          (local_mem[0].readdata),
    .ddr4a_host_dma_readdatavalid     (local_mem[0].readdatavalid),
    .ddr4a_host_dma_burstcount        (local_mem[0].burstcount[2:0]),
    .ddr4a_host_dma_writedata         (local_mem[0].writedata),
    .ddr4a_host_dma_address           ({local_mem[0].address,mm_byte_offset[0]}),
    .ddr4a_host_dma_write             (local_mem[0].write),
    .ddr4a_host_dma_read              (local_mem[0].read),
    .ddr4a_host_dma_byteenable        (local_mem[0].byteenable),
    .ddr4a_host_dma_debugaccess       (),
  `endif
    .*
  );

endmodule

