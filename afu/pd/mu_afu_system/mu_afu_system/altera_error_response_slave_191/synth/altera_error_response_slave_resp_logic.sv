// (C) 2001-2019 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// -----------------------------------------
// Merlin AXI Default Slave
//
//      This is a default slave responsible for terminating all transactions it receives with DECERR
//      It has 2 channels, one is AXI, which accepts cycles, and another one is Avalon, which is for CSR access only.
//      When CSR interface is used, there will be an irq generated whenever a transaction is routed to the default slave's AXI interface.
//      The interrupt status can be read through the Avalon CSR interface.
// 
// Author       : kevtan
// Project      : Qsys 13.0
// Insertion    : Manually inserted by designer.
//
// -----------------------------------------

`timescale 1 ns / 1 ns

module altera_error_response_slave_resp_logic #(
    parameter 
        AXI_ID_W    = 8,
        AXI_ADDR_W  = 32,
        AXI_DATA_W  = 32,
        AXI_SIZE_W  = 3,    // Not expected to change. Unless spec change
        AXI_LEN_W   = 4,    // Not expected to change. Unless spec change
        AXI_PROT_W  = 3,    // Not expected to change. Unless spec change
        AXI_TYPE_W  = 2,    // Not expected to change. Unless spec change
        S_ATTR_W    = AXI_ID_W + AXI_ADDR_W + AXI_SIZE_W + AXI_LEN_W + AXI_PROT_W + AXI_TYPE_W,
        READ_RESPONSE   = 0,    // Response logic is for read or write
        PIPELINE_LOAD   = 0,    // Pipelines critical path to memory load
        SYNC_RESET      = 0
)(
    input   clk,
    input   resetn,

    // Used for both read/writes

    // Command Channel
    input                   a_valid,
    output logic            a_ready,
    input  [AXI_ID_W-1:0]   a_id,
    input  [AXI_ADDR_W-1:0] a_addr,
    input  [AXI_PROT_W-1:0] a_prot,
    input  [AXI_LEN_W-1:0]  a_len,
    input  [AXI_SIZE_W-1:0] a_size,
    input  [AXI_TYPE_W-1:0] a_burst,

    // Data channel
    input                   w_valid,
    input  [AXI_DATA_W-1:0] w_data,
    input                   w_last,
    output  logic           w_ready,

    // Response
    output logic                o_valid,
    output logic                o_last,
    output logic [AXI_ID_W-1:0] o_id,
    input                       o_ready,

    // Fixed output responses
    output logic [1:0]              o_resp,
    output logic [AXI_DATA_W-1:0]   o_rdata,

    // To CSR Update Logic
    output logic  [S_ATTR_W-1:0]    s_attr,
    output logic  [AXI_DATA_W-1:0]  s_data,
    output logic                    s_load

);

// ------------------------
// State Definitions
// ------------------------
typedef enum bit [1:0] {
    S_IDLE  = 2'b00,
    S_WDATA = 2'b01,   // This state is entered when address is accepted, but address is pending.
    S_WADDR = 2'b10,   // This state is entered when address is accepted, but address is pending.
    S_RESP  = 2'b11   // This is the state where the slave is returning response
} resp_state;
resp_state state, next_state;

// AXI Response Type
typedef enum bit [1:0]
{
    OKAY    = 2'b00,
    EXOKAY  = 2'b01,
    SLVERR  = 2'b10,
    DECERR  = 2'b11
} AxiResponseType;

// --------------------------------
// Internal Wire definitions
// --------------------------------

// Flags
logic         data_flag;
logic         addr_flag;
logic  [4:0]  read_length;
logic         data_flag_nxt;
logic         addr_flag_nxt;
logic [4:0]   read_length_nxt;

// Outputs
logic    a_ready_nxt;
logic    w_ready_nxt;
logic    o_valid_nxt;
logic    o_last_nxt;
logic    s_load_reg;

// State Machine wires
logic    arc_IDLE_WDATA;
logic    arc_IDLE_WADDR;
logic    arc_IDLE_RESP;
logic    arc_WDATA_RESP;
logic    arc_WADDR_RESP;
logic    arc_RESP_IDLE;


// ------------------------
// AXI Response Logic
// ------------------------

// Flags used to track address and data phases
assign data_flag_nxt    = data_flag ? ~ (arc_RESP_IDLE & (state == S_RESP)) : w_valid & w_ready;
assign addr_flag_nxt    = addr_flag ? ~ (arc_RESP_IDLE & (state == S_RESP)) : a_valid & a_ready;

assign read_length_nxt  = addr_flag ?
                          ( ( (state == S_RESP) & o_ready )  ? read_length - 4'b1 : read_length ) : 
                            (READ_RESPONSE == 1) ? a_len[3:0] : 4'h0;

// Arc transition assignments for FSM
assign arc_IDLE_WDATA   = (state == S_IDLE) & addr_flag_nxt & a_valid & ~arc_IDLE_RESP;
assign arc_IDLE_WADDR   = (READ_RESPONSE == 1)? 1'b0 : (state == S_IDLE) & data_flag_nxt &  w_last &  w_valid & ~arc_IDLE_RESP;
assign arc_IDLE_RESP    = (state == S_IDLE) & a_valid & (w_valid & w_last) & a_ready;
assign arc_RESP_IDLE    = (state == S_RESP) & (read_length == 0) & o_ready;

assign arc_WDATA_RESP   = w_valid & w_last;
assign arc_WADDR_RESP   = a_valid;

// FSM transition logic //
always_comb begin : state_transition

    // FSM Default State
    next_state = S_IDLE;

    case (state)

        S_IDLE : begin
            next_state = S_IDLE;
            if (arc_IDLE_WDATA) next_state = S_WDATA;
            if (arc_IDLE_WADDR) next_state = S_WADDR;
            if (arc_IDLE_RESP)  next_state = S_RESP;
        end

        S_WDATA : begin
            next_state = S_WDATA;
            if (arc_WDATA_RESP) next_state = S_RESP;
        end

        S_WADDR : begin
            next_state = S_WADDR;
            if (arc_WADDR_RESP) next_state = S_RESP;
        end

        S_RESP : begin
            next_state = S_RESP;
            if (arc_RESP_IDLE)  next_state = S_IDLE;
        end

    endcase

end : state_transition

// Generation of internal reset synchronization
   reg internal_sclr;
   generate if (SYNC_RESET == 1) begin : rst_syncronizer
      always @ (posedge clk) begin
         internal_sclr <= ~resetn;
      end
   end
   endgenerate

 generate
 if (SYNC_RESET == 0) begin:async_rst0
   always_ff @(posedge clk, negedge resetn)
   begin
       if (!resetn)
        begin
           addr_flag   <= '0;
           data_flag   <= '0;
           read_length <= '0;
           state       <= S_IDLE;
           a_ready     <= '0;
           w_ready     <= '0;
           o_last      <= '0;
           o_valid     <= '0;
           s_load_reg  <= '0;
           s_attr      <= '0;
        end
       else
        begin
   
           addr_flag   <= addr_flag_nxt;
           data_flag   <= data_flag_nxt;
           read_length <= read_length_nxt;
           state       <= next_state;
           a_ready     <= a_ready_nxt;
           w_ready     <= w_ready_nxt;
           o_last      <= o_last_nxt;
           o_valid     <= o_valid_nxt;
           s_load_reg  <= arc_RESP_IDLE;
   
           if (~addr_flag) begin
               s_attr  <= { a_addr, a_id , a_burst, a_len, a_size, a_prot };
           end
        end
   end
 end : async_rst0
 else begin : sync_rst0  
   
   always_ff @(posedge clk)
   begin
       if (internal_sclr)
        begin
           addr_flag   <= '0;
           data_flag   <= '0;
           read_length <= '0;
           state       <= S_IDLE;
           a_ready     <= '0;
           w_ready     <= '0;
           o_last      <= '0;
           o_valid     <= '0;
           s_load_reg  <= '0;
           s_attr      <= '0;
        end
       else
        begin
   
           addr_flag   <= addr_flag_nxt;
           data_flag   <= data_flag_nxt;
           read_length <= read_length_nxt;
           state       <= next_state;
           a_ready     <= a_ready_nxt;
           w_ready     <= w_ready_nxt;
           o_last      <= o_last_nxt;
           o_valid     <= o_valid_nxt;
           s_load_reg  <= arc_RESP_IDLE;
   
           if (~addr_flag) begin
               s_attr  <= { a_addr, a_id , a_burst, a_len, a_size, a_prot };
           end
        end
   end
 end: sync_rst0
 endgenerate

 always @ (posedge clk) begin
   if (~data_flag) begin
       s_data  <= w_data;
   end
 end

// Making this combinatorial, so that the registers become valid next clock after response is accepted.
// This should not have too much impact on timing, although this fans out to quite a huge memory.
// (Revisit if this become critical path) [Note: flopping this complicates validation timing a bit]
assign s_load   = (PIPELINE_LOAD==1)? s_load_reg : arc_RESP_IDLE;    


// -----------------
// Output assignments
// -----------------

// Address ready is asserted whenever we are still waiting for completion of address phase
assign a_ready_nxt  = (next_state == S_IDLE) | (next_state == S_WADDR);
assign w_ready_nxt  = (next_state == S_IDLE) | (next_state == S_WDATA);

assign o_last_nxt   = (next_state == S_RESP) & (read_length_nxt == 0);
assign o_valid_nxt  = (next_state == S_RESP);

assign o_resp   = DECERR;

  genvar i;
  generate
    for (i = 0; i < AXI_DATA_W; i = i + 32) begin : assign_read_data
        assign o_rdata[i+31:i] = 32'hFFFFFFFF;
    end
  endgenerate

// ID being latch during address receive phase can be used as return ID
assign o_id = s_attr [AXI_PROT_W + AXI_SIZE_W + AXI_LEN_W + AXI_TYPE_W + AXI_ID_W - 1 : AXI_PROT_W + AXI_SIZE_W + AXI_LEN_W + AXI_TYPE_W]; 

//--------------------------------------
// Assertions
//--------------------------------------
// synthesis translate_off

ERROR_exclusive_arc_IDLE_ANY:
    assert property (
        @(posedge clk) disable iff (!resetn) 
            ~( (arc_IDLE_RESP & arc_IDLE_WDATA) | (arc_IDLE_RESP & arc_IDLE_WADDR) | (arc_IDLE_WADDR & arc_IDLE_WDATA ) ) 
    );

ERROR_last_without_valid : 
    assert property (
        @(posedge clk) disable iff (!resetn)
            ~( READ_RESPONSE & o_last & !o_valid) 
    );


// synthesis translate_on


endmodule : altera_error_response_slave_resp_logic

