// ***************************************************************************
// Copyright (c) 2017, Intel Corporation
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
// * Neither the name of Intel Corporation nor the names of its contributors
// may be used to endorse or promote products derived from this software
// without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// ***************************************************************************

import ccip_if_pkg::*;
import ccip_avmm_pkg::*;
`include "platform_if.vh"

module afu #(
  parameter NUM_LOCAL_MEM_BANKS =               1
)
(
  input	                                        pClk,
  input                                         uClk_usr,
  input	                                        reset,
        
`ifdef PLATFORM_PROVIDES_LOCAL_MEMORY
  // Local memory interface
  avalon_mem_if.to_fiu                          local_mem[NUM_LOCAL_MEM_BANKS],
`endif
        
  // FIU to AFU ports, cp2af_mmio_c0rx is the c0rx MMIO command traffic
	input	 t_if_ccip_Rx                           cp2af_sRxPort,
	input	 t_if_ccip_c0_Rx                        cp2af_mmio_c0rx,
	output t_if_ccip_Tx	                          af2cp_sTxPort
);

  // Avalon-MM write to CCIP signals
  logic                                         requestor_avmm_wr_waitrequest;
  logic [CCIP_AVMM_REQUESTOR_DATA_WIDTH-1:0]	  requestor_avmm_wr_writedata;
  logic [CCIP_AVMM_REQUESTOR_WR_ADDR_WIDTH-2:0] requestor_avmm_wr_address;            // not using write fence capabilities of the adapter so MSB will be tied low to inhibit write fences
  logic                                         requestor_avmm_wr_write;
  logic [CCIP_AVMM_REQUESTOR_BURST_WIDTH-1:0]	  requestor_avmm_wr_burstcount;
  logic [1:0]                                   requestor_avmm_wr_response;
  logic                                         requestor_avmm_wr_writeresponsevalid;

  // Avalon-MM read to CCIP signals
  logic                                         requestor_avmm_rd_waitrequest;
  logic [CCIP_AVMM_REQUESTOR_DATA_WIDTH-1:0]    requestor_avmm_rd_readdata;
  logic                                         requestor_avmm_rd_readdatavalid;
  logic [CCIP_AVMM_REQUESTOR_RD_ADDR_WIDTH-1:0] requestor_avmm_rd_address;
  logic                                         requestor_avmm_rd_read;
  logic [CCIP_AVMM_REQUESTOR_BURST_WIDTH-1:0]	  requestor_avmm_rd_burstcount;

  // CCIP MMIO to Avalon-MM read and write signals
  logic                                         mmio_avmm_waitrequest;
  logic [CCIP_AVMM_MMIO_DATA_WIDTH-1:0]	        mmio_avmm_readdata;
  logic                                         mmio_avmm_readdatavalid;
  logic [CCIP_AVMM_MMIO_DATA_WIDTH-1:0]	        mmio_avmm_writedata;
  logic [CCIP_AVMM_MMIO_ADDR_WIDTH-1:0]         mmio_avmm_address;
  logic                                         mmio_avmm_write;
  logic                                         mmio_avmm_read;
  logic [(CCIP_AVMM_MMIO_DATA_WIDTH/8)-1:0]     mmio_avmm_byteenable;


  // DMA test system that includes DMA BBB and interfaces to host and FPGA memory
  mu_afu_system_wrapper #(
    .NUM_LOCAL_MEM_BANKS           (NUM_LOCAL_MEM_BANKS)
  ) system_wrapper 
  (
    .primary_clk(pClk),
    .user_clk(uClk_usr), // Programmable from OPAE
    .reset(reset),

    // contains wiring to the two banks of SDRAM (two 32-bit address spaces)
`ifdef PLATFORM_PROVIDES_LOCAL_MEMORY
    .local_mem                     (local_mem),
`endif  

    // wiring of the CCIP to Avalon-MM read/write adapter (18-bit address space)
    .avmm_mmio_waitrequest         (mmio_avmm_waitrequest),
    .avmm_mmio_readdata            (mmio_avmm_readdata),
    .avmm_mmio_readdatavalid       (mmio_avmm_readdatavalid),
    .avmm_mmio_burstcount          (1'b1),                            // MMIO accesses are always single beat
    .avmm_mmio_writedata           (mmio_avmm_writedata),
    .avmm_mmio_address             (mmio_avmm_address),
    .avmm_mmio_write               (mmio_avmm_write),
    .avmm_mmio_read                (mmio_avmm_read),
    .avmm_mmio_byteenable          (mmio_avmm_byteenable),            // byte enables will be 8'b1111_1111, 8'b0000_1111, or 8'b1111_0000

    // wiring of the Avalon-MM write to CCIP adapter (48-bit address space)
    .host_write_waitrequest        (requestor_avmm_wr_waitrequest),
    .host_write_burstcount         (requestor_avmm_wr_burstcount),
    .host_write_writedata          (requestor_avmm_wr_writedata),
    .host_write_address            (requestor_avmm_wr_address),
    .host_write_write              (requestor_avmm_wr_write),
    .host_write_response           (requestor_avmm_wr_response),
    .host_write_writeresponsevalid (requestor_avmm_wr_writeresponsevalid),
    .host_write_byteenable         (),                                // adapter assumes all byte enables are asserted

    // wiring of the Avalon-MM read to CCIP adapter (48-bit address space)
    .host_read_waitrequest         (requestor_avmm_rd_waitrequest),
    .host_read_readdata            (requestor_avmm_rd_readdata),
    .host_read_readdatavalid       (requestor_avmm_rd_readdatavalid),
    .host_read_burstcount          (requestor_avmm_rd_burstcount),
    .host_read_address             (requestor_avmm_rd_address),
    .host_read_read                (requestor_avmm_rd_read),
    .host_read_byteenable          ()                                 // adapter assumes all byte enables are asserted
  );


  // Avalon-MM read to CCIP adapter
  avmm_ccip_host_rd #
  (
  ) avmm_ccip_host_rd_inst
  (
    .clk                (pClk),
    .reset              (reset),
    	
    .avmm_waitrequest   (requestor_avmm_rd_waitrequest),
    .avmm_readdata      (requestor_avmm_rd_readdata),
    .avmm_readdatavalid (requestor_avmm_rd_readdatavalid),
    .avmm_address       (requestor_avmm_rd_address),
    .avmm_read          (requestor_avmm_rd_read),
    .avmm_burstcount    (requestor_avmm_rd_burstcount),
    	
    .c0TxAlmFull        (cp2af_sRxPort.c0TxAlmFull),
    .c0rx               (cp2af_sRxPort.c0),                  // this port only recieves readdata, MMIO commands have already been stripped out
    .c0tx               (af2cp_sTxPort.c0)
  );


  // Avalon-MM write/IRQ to CCIP adapter
  avmm_ccip_host_wr #
  (
    .ENABLE_INTR              (1)
  ) avmm_ccip_host_wr_inst 
  (
    .clk                      (pClk),
    .reset                    (reset),

    .irq                      (4'b0000),                              // DMA doesn't implement interrupts

    .avmm_waitrequest         (requestor_avmm_wr_waitrequest),
    .avmm_writedata           (requestor_avmm_wr_writedata),
    .avmm_address             ({1'b0, requestor_avmm_wr_address}),    // tieing MSB to 0 to inhibit write fences
    .avmm_write               (requestor_avmm_wr_write),
    .avmm_burstcount          (requestor_avmm_wr_burstcount),
    .avmm_write_response      (requestor_avmm_wr_response),
    .avmm_write_responsevalid (requestor_avmm_wr_writeresponsevalid),
    	
    .c1TxAlmFull              (cp2af_sRxPort.c1TxAlmFull),
    .c1rx                     (cp2af_sRxPort.c1),
    .c1tx                     (af2cp_sTxPort.c1)
  );


  // CCIP MMIO to Avalon-MM read/write adapter
  ccip_avmm_mmio  #
  (
    .TID_FIFO_MLAB_ENABLE (1),
    .CMD_FIFO_MLAB_ENABLE (1)
  ) ccip_avmm_mmio_inst 
  (
    .clk                  (pClk),
    .reset                (reset),

    .avmm_waitrequest     (mmio_avmm_waitrequest),
    .avmm_readdata        (mmio_avmm_readdata),
    .avmm_readdatavalid   (mmio_avmm_readdatavalid),
    .avmm_writedata       (mmio_avmm_writedata),
    .avmm_address         (mmio_avmm_address),
    .avmm_write           (mmio_avmm_write),
    .avmm_read            (mmio_avmm_read),
    .avmm_byteenable      (mmio_avmm_byteenable),

    .c0rx                 (cp2af_mmio_c0rx),            // this port only recieves MMIO commands, readdata has already been stripped out 
    .c2tx                 (af2cp_sTxPort.c2)
  );
	
endmodule

