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

module altera_error_response_slave
#( 

    parameter
    //----------------
    // Default Slave Parameters
    //----------------
    SUPPORT_CSR             = 1,    // When 0, Avalon interface is tied off. (in _hw.tcl)
    REGISTER_AV_READDATA    = 1,    // When 0, CSR read data output is not registered 
                                    // (Currently used only in simulation to avoid race condition in testing)
    REGISTER_AV_INPUTS      = 0,    // When 1, all Avalon input registers will be registered 
                                    // (this changes the Av timing in _hw.tcl)
    //----------------
    // CSR Settings
    //----------------
    LOG_CSR_DEPTH     = 8,    // Sets the depth of the CSR to be log. (Default : 8 transactions)
    LOG_WRITE_DATA    = 1,    // Disable to save resources
    LOG_WRITE_ADDR    = 1,    // Disable to save resources
    LOG_READ_ADDR     = 1,    // Disable to save resources
    LOG_WRITE_ID      = 1,    // Disable to save resources
    LOG_READ_ID       = 1,    // Disable to save resources
                           
    //-------------------------
    // AXI Slave Interface Parameters
    //-------------------------
    AXI_ID_W    = 8,
    AXI_ADDR_W  = 64, // This should be set to 32/64
    AXI_DATA_W  = 32, // This can be set to 32/64/128 to match required system

    AXI_SIZE_W      = 3,    // Not expected to change. Unless spec change
    AXI_LEN_W       = 4,    // Not expected to change. Unless spec change
    AXI_PROT_W      = 3,    // Not expected to change. Unless spec change
    AXI_BURSTTPE_W  = 2,    // Not expected to change. Unless spec change

    //-------------------------
    // Avalon CSR Slave Interface Parameters
    //-------------------------
    AV_ADDR_W   = 12,   // Not expected to change [Minimum required for decode is 12]
    AV_DATA_W   = 32,    // Not expected to change, as will affect the CSR arrangement.
                        // This might potentially help Fmax if increased
   //
    SYNC_RESET = 0
)
(
    //----------------
    // Global Signals
    //----------------
    input                   aclk,
    input                   aresetn,

    output logic            irq,

    //----------------------------
    // AXI SLAVE INTERFACE
    //----------------------------
    // Write Address Channel
    //----------------
    input [AXI_ID_W-1:0]    awid,
    input [AXI_ADDR_W-1:0]  awaddr,
    input [AXI_LEN_W-1:0]   awlen, 
    input [AXI_SIZE_W-1:0]  awsize,
    input [AXI_BURSTTPE_W-1:0] awburst,
    input [1:0]             awlock,
    input [3:0]             awcache,
    input [AXI_PROT_W-1:0]  awprot,
    input                   awvalid,
    output logic            awready,
    //----------------
    // Write Data Channel
    //----------------
    input [AXI_ID_W-1:0]        wid,
    input [AXI_DATA_W-1:0]      wdata,
    input [(AXI_DATA_W/8)-1:0]  wstrb,
    input                       wlast,
    input                       wvalid,
    output logic                wready,
    //----------------
    // Write Response Channel
    //----------------
    output logic [AXI_ID_W-1:0]  bid,
    output logic [1:0]           bresp,
    output logic                 bvalid,
    input                   bready,
    //----------------
    // Read Address Channel
    //----------------
    input [AXI_ID_W-1:0]    arid,
    input [AXI_ADDR_W-1:0]  araddr,
    input [AXI_LEN_W-1:0]   arlen,
    input [AXI_SIZE_W-1:0]  arsize,
    input [AXI_BURSTTPE_W-1:0] arburst,
    input [1:0]             arlock,
    input [3:0]             arcache,
    input [AXI_PROT_W-1:0]  arprot,
    input                   arvalid,
    output logic            arready,
    //----------------
    // Read Data Channel
    //----------------
    output [AXI_ID_W-1:0]   rid,
    output [AXI_DATA_W-1:0] rdata,
    output [1:0]            rresp,
    output logic            rlast,
    output logic            rvalid,
    input                   rready,

    //----------------------------
    // Avalon CSR Interface
    //----------------------------
    input  [AV_ADDR_W-1:0]       av_address,
    input                        av_write,
    input                        av_read,
    input  [AV_DATA_W-1:0]       av_writedata,
    output logic [AV_DATA_W-1:0] av_readdata

);

//--------------------------------------
// Local parameters [Not directly used in HDL, for clarity in HDL only]
//--------------------------------------

localparam AXI_VERSION      = 3;
localparam READ_LATENCY     = 1;
localparam WRITE_LATENCY    = 1;
localparam READ_ACCEPTANCE  = 1;
localparam WRITE_ACCEPTANCE = 1;
localparam WRITE_INTERLEAVE_DEPTH   = 1;

localparam  LOG_READ_W      = AXI_ADDR_W + AXI_ID_W + AXI_PROT_W + AXI_LEN_W + AXI_SIZE_W + AXI_BURSTTPE_W;
localparam  LOG_WRITE_W     = AXI_DATA_W + LOG_READ_W;

localparam  CSR_AXI_PROT_L  = 0;
localparam  CSR_AXI_PROT_H  = AXI_PROT_W + CSR_AXI_PROT_L - 1;
localparam  CSR_AXI_SIZE_L  = CSR_AXI_PROT_H + 1;
localparam  CSR_AXI_SIZE_H  = AXI_SIZE_W + CSR_AXI_SIZE_L - 1;
localparam  CSR_AXI_LEN_L   = CSR_AXI_SIZE_H + 1;
localparam  CSR_AXI_LEN_H   = AXI_LEN_W + CSR_AXI_LEN_L - 1;
localparam  CSR_AXI_TYPE_L  = CSR_AXI_LEN_H + 1;
localparam  CSR_AXI_TYPE_H  = AXI_BURSTTPE_W + CSR_AXI_TYPE_L - 1;
localparam  CSR_AXI_ID_L    = CSR_AXI_TYPE_H + 1;
localparam  CSR_AXI_ID_H    = AXI_ID_W + CSR_AXI_ID_L - 1;
//localparam  CSR_AXI_ADDR_L  = CSR_AXI_ID_H + 1;
//localparam  CSR_AXI_ADDR_H  = AXI_ADDR_W + CSR_AXI_ADDR_L - 1;
//localparam  CSR_AXI_DATA_L  = CSR_AXI_ADDR_H + 1;
//localparam  CSR_AXI_DATA_H  = AXI_DATA_W + CSR_AXI_DATA_L - 1;

localparam  CSR_AXI_ADDR1_L  = CSR_AXI_ID_H + 1;
localparam  CSR_AXI_ADDR1_H  = (AXI_ADDR_W > 32) ? 32 + CSR_AXI_ADDR1_L - 1 : AXI_ADDR_W + CSR_AXI_ADDR1_L - 1;
localparam  CSR_AXI_ADDR2_L  = (AXI_ADDR_W > 32) ? CSR_AXI_ADDR1_H + 1      : CSR_AXI_ADDR1_H;
localparam  CSR_AXI_ADDR2_H  = (AXI_ADDR_W > 32) ? (AXI_ADDR_W - 32) + CSR_AXI_ADDR2_L - 1 : CSR_AXI_ADDR1_H;

localparam  CSR_AXI_DATA1_L  = CSR_AXI_ADDR2_H + 1;
localparam  CSR_AXI_DATA1_H  = (AXI_DATA_W > 32) ? 32 + CSR_AXI_DATA1_L - 1 : AXI_DATA_W + CSR_AXI_DATA1_L - 1;

localparam  CSR_AXI_DATA2_L  = (AXI_DATA_W > 32) ? CSR_AXI_DATA1_H + 1      : CSR_AXI_DATA1_H;
localparam  CSR_AXI_DATA2_H  = (AXI_DATA_W <= 32) ? CSR_AXI_DATA2_L :
                                    (AXI_DATA_W > 64) ? 32 + CSR_AXI_DATA2_L - 1 : (AXI_DATA_W - 32) + CSR_AXI_DATA2_L - 1;

localparam  CSR_AXI_DATA3_L  = (AXI_DATA_W > 64) ? CSR_AXI_DATA2_H + 1      : CSR_AXI_DATA2_H;
localparam  CSR_AXI_DATA3_H  = (AXI_DATA_W <= 64) ? CSR_AXI_DATA3_L :
                                    (AXI_DATA_W > 96) ? 32 + CSR_AXI_DATA3_L - 1 : (AXI_DATA_W - 64) + CSR_AXI_DATA2_L - 1;

localparam  CSR_AXI_DATA4_L  = (AXI_DATA_W > 96) ? CSR_AXI_DATA3_H + 1      : CSR_AXI_DATA3_H;
localparam  CSR_AXI_DATA4_H  = (AXI_DATA_W <= 96) ? CSR_AXI_DATA4_L :
                                    (AXI_DATA_W > 96) ? 32 + CSR_AXI_DATA4_L - 1 : (AXI_DATA_W - 96) + CSR_AXI_DATA2_L - 1;

// Note : Avalon CSR parameter behaviour is set in _hw.tcl


// --------------------------------
// CSR Enumeration
// --------------------------------
typedef enum bit [3:0] {
        CSR_INTR_STS    = 4'd0,
        CSR_R_INFO      = 4'd1,
        CSR_R_ID        = 4'd2,
        CSR_R_ADDR      = 4'd3,
        CSR_R_ADDR2     = 4'd4,
        CSR_W_INFO      = 4'd5,
        CSR_W_ID        = 4'd6,
        CSR_W_ADDR      = 4'd7,
        CSR_W_ADDR2     = 4'd8,
        CSR_W_WDATA     = 4'd9,
        CSR_W_WDATA2    = 4'd10,
        CSR_W_WDATA3    = 4'd11,
        CSR_W_WDATA4    = 4'd12,
        CSR_UNDEF       = 4'd13
} csr_enum;
csr_enum csr_hit;

// --------------------------------
// Internal Wire definitions
// --------------------------------

// Saved transaction attributes
logic [LOG_READ_W-1 : 0]    log_write_attr;
logic [AXI_DATA_W-1:0]      log_write_data;
logic [LOG_READ_W-1 : 0]    log_read_attr;
logic                       log_write_load;
logic                       log_read_load;

logic [LOG_WRITE_W - 1 : 0] csr_w_saved_attr;
logic [LOG_READ_W  - 1 : 0] csr_r_saved_attr;
logic                       csr_w_valid;
logic                       csr_r_valid;


// Avalon CSR Register logic
logic [31:0]    csr_register[16];
logic           csr_hit_intr_status;
logic           set_w_intr_bit;
logic           set_r_intr_bit;
logic           set_w_intr_overflow_bit;
logic           set_r_intr_overflow_bit;
logic           w_intr_sw_clr;
logic           r_intr_sw_clr;
logic           w_intr_overflow_sw_clr;
logic           r_intr_overflow_sw_clr;
logic           w_intr;
logic           r_intr;
logic           w_intr_nxt;
logic           r_intr_nxt;
logic           w_intr_overflow;
logic           r_intr_overflow;
logic           w_intr_overflow_nxt;
logic           r_intr_overflow_nxt;


// Avalon CSR control logic
logic                   w_cycle;
logic                   r_cycle;
logic [AV_DATA_W-1:0]   av_readdata_reg;
logic [AV_DATA_W-1:0]   av_readdata_wire;

logic av_read_last_r_base;
logic av_read_last_w_base;

// Avalon CSR input staging
logic                   av_write_in;
logic                   av_read_in;
logic [AV_ADDR_W-1:0]   av_address_in;
logic [AV_DATA_W-1:0]   av_writedata_in;

// ------------------------
// AXI Write Response Logic
// ------------------------

altera_error_response_slave_resp_logic 
    #(
        .AXI_ID_W   (AXI_ID_W),
        .AXI_ADDR_W (AXI_ADDR_W),
        .AXI_DATA_W (AXI_DATA_W),
        .READ_RESPONSE (0),
        .SYNC_RESET (SYNC_RESET)
    ) write_channel_resp (
        .clk	    (aclk),
        .resetn	    (aresetn),
        .a_valid    (awvalid),
        .a_ready    (awready),
        .a_id	    (awid),
        .a_addr	    (awaddr),
        .a_prot	    (awprot),
        .a_len      (awlen),
        .a_burst    (awburst),
        .a_size     (awsize),

        .w_valid	(wvalid),
        .w_data     (wdata),
        .w_last	    (wlast),
        .w_ready	(wready),

        .o_valid    (bvalid),
        .o_id	    (bid),
        .o_last     (),
        .o_ready    (bready),
        .o_resp	    (bresp),
        .o_rdata	 (),
        
        .s_attr	    (log_write_attr),
        .s_data     (log_write_data),
        .s_load     (log_write_load)

);

// ------------------------
// AXI Read Response Logic
// ------------------------

altera_error_response_slave_resp_logic
    #(
        .AXI_ID_W   (AXI_ID_W),
        .AXI_ADDR_W (AXI_ADDR_W),
        .AXI_DATA_W (AXI_DATA_W),
        .READ_RESPONSE (1),
        .SYNC_RESET (SYNC_RESET)
    ) read_channel_resp (
        .clk        (aclk),
        .resetn     (aresetn),
        .a_valid    (arvalid),
        .a_ready    (arready),
        .a_id       (arid),
        .a_addr     (araddr),
        .a_prot     (arprot),
        .a_len      (arlen),
        .a_burst    (arburst),
        .a_size     (arsize),

        .w_valid    (1'b1),
        .w_data     ({AXI_DATA_W{1'b0}}),
        .w_last     (1'b1),
        .w_ready    (),

        .o_valid    (rvalid),
        .o_id       (rid),
        .o_last     (rlast),
        .o_ready    (rready),
        .o_resp     (rresp),
        .o_rdata    (rdata),

        .s_attr     (log_read_attr),
        .s_data     (),
        .s_load     (log_read_load)

);

// Generation of internal reset synchronization
   reg internal_sclr;
   generate if (SYNC_RESET == 1) begin : rst_syncronizer
      always @ (posedge aclk) begin
         internal_sclr <= ~aresetn;
      end
   end
   endgenerate
// ------------------------
// Avalon Input Pipeline
// ------------------------
    generate
      if (REGISTER_AV_INPUTS == 1) begin
        if (SYNC_RESET == 0) begin : async_rst0
           always_ff @(posedge aclk or negedge aresetn) begin
             if (!aresetn) begin
               av_writedata_in    <= '0;
               av_address_in      <= '0;
               av_write_in        <= '0;
               av_read_in         <= '0;
             end
             else begin
               av_writedata_in    <= av_writedata;
               av_address_in      <= av_address;
               av_write_in        <= av_write;
               av_read_in         <= av_read;
             end
           end //@always_ff
        end // async_rts0
        else begin : sync_rst0
           always_ff @(posedge aclk ) begin
             if (internal_sclr) begin
               av_writedata_in    <= '0;
               av_address_in      <= '0;
               av_write_in        <= '0;
               av_read_in         <= '0;
             end
             else begin
               av_writedata_in    <= av_writedata;
               av_address_in      <= av_address;
               av_write_in        <= av_write;
               av_read_in         <= av_read;
             end
           end //@always_ff
        end // sync_rst0
      end // register_av_inputs =1
      else begin
        always_comb begin
            av_writedata_in    = av_writedata;
            av_address_in      = av_address;
            av_write_in        = av_write;
            av_read_in         = av_read;
        end
      end
    endgenerate

generate if (SUPPORT_CSR == 1) 
 begin : CSR_CONTROL_LOGIC
// ------------------------
// CSR Update Logic
// ------------------------
altera_error_response_slave_reg_fifo
    # (
        .DEPTH      (LOG_CSR_DEPTH),
        .DATA_W     (LOG_READ_W),
        .SYNC_RESET (SYNC_RESET)
      ) csr_read_log (
            .clk        (aclk),
            .rst_n      (aresetn),
            .load       (log_read_load),
            .unload     (av_read_last_r_base),
            .overflow   (set_r_intr_overflow_bit),
            .data_in    (log_read_attr),
            .not_empty  (set_r_intr_bit),
            .data_out   ({csr_r_saved_attr, csr_r_valid })
);


altera_error_response_slave_reg_fifo
    # (
        .DEPTH      (LOG_CSR_DEPTH),
        .DATA_W     (LOG_WRITE_W),
        .SYNC_RESET (SYNC_RESET) 
      ) csr_write_log (
            .clk        (aclk),
            .rst_n      (aresetn),
            .load       (log_write_load),
            .unload     (av_read_last_w_base),
            .overflow   (set_w_intr_overflow_bit),
            .data_in    ({ log_write_data, log_write_attr }),
            .not_empty  (set_w_intr_bit),
            .data_out   ({ csr_w_saved_attr, csr_w_valid })
);

// ------------------------
// Avalon CSR Logic
// ------------------------

assign w_cycle      = av_write_in;
assign r_cycle      = av_read_in;

 if (SYNC_RESET ==0) begin : async_rst1
   always_ff @(posedge aclk, negedge aresetn)
   begin
       if (!aresetn) 
           av_readdata_reg <= '0;
       else
           av_readdata_reg   <= av_readdata_wire;
   end
 end // async_rst1 
 else begin : sync_rst1 
   always_ff @(posedge aclk)
   begin
       if (internal_sclr) 
           av_readdata_reg <= '0;
       else
           av_readdata_reg   <= av_readdata_wire;
   end
 end // sync_rst1

assign av_readdata_wire =   { AV_DATA_W{r_cycle} } & (
                            (csr_register[CSR_UNDEF]    & {AV_DATA_W{(csr_hit == CSR_UNDEF )}}) |
                            (csr_register[CSR_W_WDATA4] & {AV_DATA_W{(csr_hit == CSR_W_WDATA4 )}}) |
                            (csr_register[CSR_W_WDATA3] & {AV_DATA_W{(csr_hit == CSR_W_WDATA3 )}}) |
                            (csr_register[CSR_W_WDATA2] & {AV_DATA_W{(csr_hit == CSR_W_WDATA2 )}}) |
                            (csr_register[CSR_W_WDATA]  & {AV_DATA_W{(csr_hit == CSR_W_WDATA )}}) |
                            (csr_register[CSR_W_ADDR2]  & {AV_DATA_W{(csr_hit == CSR_W_ADDR2 )}}) |
                            (csr_register[CSR_W_ADDR]   & {AV_DATA_W{(csr_hit == CSR_W_ADDR )}}) |
                            (csr_register[CSR_W_INFO]   & {AV_DATA_W{(csr_hit == CSR_W_INFO )}}) |
                            (csr_register[CSR_W_ID]     & {AV_DATA_W{(csr_hit == CSR_W_ID )}}) |
                            (csr_register[CSR_R_ADDR2]  & {AV_DATA_W{(csr_hit == CSR_R_ADDR2 )}}) |
                            (csr_register[CSR_R_ADDR]   & {AV_DATA_W{(csr_hit == CSR_R_ADDR )}}) |
                            (csr_register[CSR_R_ID]     & {AV_DATA_W{(csr_hit == CSR_R_ID )}}) |
                            (csr_register[CSR_R_INFO]   & {AV_DATA_W{(csr_hit == CSR_R_INFO )}}) |
                            (csr_register[CSR_INTR_STS] & {AV_DATA_W{(csr_hit == CSR_INTR_STS )}})
                        );

assign av_readdata = (REGISTER_AV_READDATA == 1) ? av_readdata_reg : av_readdata_wire;

// --------------
// CSR address decode
// --------------

always_comb begin

    csr_hit[3:0] = CSR_UNDEF;
    
    if (av_address_in[AV_ADDR_W-1:0] == 12'h000) csr_hit = CSR_INTR_STS;      
    if (av_address_in[AV_ADDR_W-1:0] == 12'h100) csr_hit = CSR_R_INFO;     
    if (av_address_in[AV_ADDR_W-1:0] == 12'h104) csr_hit = CSR_R_ID;       
    if (av_address_in[AV_ADDR_W-1:0] == 12'h108) csr_hit = CSR_R_ADDR;     
    if (av_address_in[AV_ADDR_W-1:0] == 12'h10C) csr_hit = CSR_R_ADDR2;    

    if (av_address_in[AV_ADDR_W-1:0] == 12'h190) csr_hit = CSR_W_INFO;     
    if (av_address_in[AV_ADDR_W-1:0] == 12'h194) csr_hit = CSR_W_ID;       
    if (av_address_in[AV_ADDR_W-1:0] == 12'h198) csr_hit = CSR_W_ADDR;     
    if (av_address_in[AV_ADDR_W-1:0] == 12'h19C) csr_hit = CSR_W_ADDR2;    
    if (av_address_in[AV_ADDR_W-1:0] == 12'h1A0) csr_hit = CSR_W_WDATA;    
    if (av_address_in[AV_ADDR_W-1:0] == 12'h1A4) csr_hit = CSR_W_WDATA2;   
    if (av_address_in[AV_ADDR_W-1:0] == 12'h1A8) csr_hit = CSR_W_WDATA3;   
    if (av_address_in[AV_ADDR_W-1:0] == 12'h1AC) csr_hit = CSR_W_WDATA4;   

end

assign r_intr_overflow_sw_clr   = av_writedata_in[3] & w_cycle & (csr_hit == CSR_INTR_STS);
assign w_intr_overflow_sw_clr   = av_writedata_in[2] & w_cycle & (csr_hit == CSR_INTR_STS);
assign r_intr_sw_clr            = av_writedata_in[1] & w_cycle & (csr_hit == CSR_INTR_STS);
assign w_intr_sw_clr            = av_writedata_in[0] & w_cycle & (csr_hit == CSR_INTR_STS);

assign av_read_last_r_base  = r_cycle & (csr_hit == CSR_R_ADDR2);
assign av_read_last_w_base  = r_cycle & 
                              ((AXI_DATA_W == 32 ) ? (csr_hit == CSR_W_WDATA) :
                               (AXI_DATA_W == 64 ) ? (csr_hit == CSR_W_WDATA2):
                                                     (csr_hit == CSR_W_WDATA4)
                              );
// ------------------
// INTR Bit 
// ------------------

// All interrupt bits are "set" priority.
assign r_intr_nxt = (set_r_intr_bit | ~set_r_intr_bit & log_read_load ) | r_intr & ~r_intr_sw_clr;
assign w_intr_nxt = (set_w_intr_bit | ~set_w_intr_bit & log_write_load) | w_intr & ~w_intr_sw_clr;

assign r_intr_overflow_nxt = set_r_intr_overflow_bit | r_intr_overflow & ~r_intr_overflow_sw_clr;
assign w_intr_overflow_nxt = set_w_intr_overflow_bit | w_intr_overflow & ~w_intr_overflow_sw_clr;

if (SYNC_RESET == 0) begin : async_rst2
   always_ff @(posedge aclk, negedge aresetn)
   begin
       if (!aresetn) begin
           r_intr              <= '0;
           w_intr              <= '0;
           r_intr_overflow     <= '0;
           w_intr_overflow     <= '0;
           irq                 <= '0;
       end
       else begin
           r_intr              <= r_intr_nxt;
           w_intr              <= w_intr_nxt;
           r_intr_overflow     <= r_intr_overflow_nxt;
           w_intr_overflow     <= w_intr_overflow_nxt;
           irq                 <= r_intr_nxt | w_intr_nxt | r_intr_overflow_nxt | w_intr_overflow_nxt; 
       end
   end
end // async_rst2
else begin : sync_rst2   
   always_ff @(posedge aclk)
   begin
       if (internal_sclr) begin
           r_intr              <= '0;
           w_intr              <= '0;
           r_intr_overflow     <= '0;
           w_intr_overflow     <= '0;
           irq                 <= '0;
       end
       else begin
           r_intr              <= r_intr_nxt;
           w_intr              <= w_intr_nxt;
           r_intr_overflow     <= r_intr_overflow_nxt;
           w_intr_overflow     <= w_intr_overflow_nxt;
           irq                 <= r_intr_nxt | w_intr_nxt | r_intr_overflow_nxt | w_intr_overflow_nxt; 
       end
   end
end // sync_rst2
// ------------------------
// CSR Assignments
// ------------------------

assign csr_register [CSR_INTR_STS] = { {(32 - 4){1'b0} } , r_intr_overflow, w_intr_overflow, r_intr , w_intr };

assign csr_register [CSR_R_INFO] = { {(32 - AXI_PROT_W - AXI_LEN_W - AXI_BURSTTPE_W - AXI_SIZE_W - 1) {1'b0}} ,
                                        csr_r_saved_attr [ CSR_AXI_TYPE_H : CSR_AXI_TYPE_L] ,
                                        csr_r_saved_attr [ CSR_AXI_LEN_H  : CSR_AXI_LEN_L ] ,
                                        csr_r_saved_attr [ CSR_AXI_SIZE_H : CSR_AXI_SIZE_L] ,
                                        csr_r_saved_attr [ CSR_AXI_PROT_H : CSR_AXI_PROT_L] ,
                                        csr_r_valid
                                    };

assign csr_register[CSR_R_ID]    = (LOG_READ_ID==1)? 
                                        { {(32 - AXI_ID_W){1'b0} } , csr_r_saved_attr[CSR_AXI_ID_H:CSR_AXI_ID_L] } : '0;

assign csr_register[CSR_R_ADDR]  = (LOG_READ_ADDR==1)?
//                                        (AXI_ADDR_W == 32) ?
//                                            csr_r_saved_attr [CSR_AXI_ADDR1_H + 31 : CSR_AXI_ADDR_L] //:
                                       { {(32 - (CSR_AXI_ADDR1_H - CSR_AXI_ADDR1_L + 1)){1'b0} } , csr_r_saved_attr [CSR_AXI_ADDR1_H : CSR_AXI_ADDR1_L] } :
                                        '0;

assign csr_register[CSR_R_ADDR2] = (AXI_ADDR_W > 32) & (LOG_READ_ADDR==1) ?
//                                        (AXI_ADDR_W == 64) ?
//                                            csr_r_saved_attr [CSR_AXI_ADDR2_ + 63 : CSR_AXI_ADDR_L + 32] :
//                                      { {(32 - AXI_ADDR_W){1'b0} } , csr_r_saved_attr [CSR_AXI_ADDR_H + AXI_ADDR_W : CSR_AXI_ADDR_L + 32]} :
                                       { {(32 - (CSR_AXI_ADDR2_H - CSR_AXI_ADDR2_L + 1)){1'b0} } , csr_r_saved_attr [CSR_AXI_ADDR2_H : CSR_AXI_ADDR2_L] } :
                                        '0;

assign csr_register[CSR_W_INFO] = {   {(32 - AXI_PROT_W - AXI_LEN_W - AXI_BURSTTPE_W - AXI_SIZE_W - 1) {1'b0}} ,
                                        csr_w_saved_attr [ CSR_AXI_TYPE_H : CSR_AXI_TYPE_L] ,
                                        csr_w_saved_attr [ CSR_AXI_LEN_H  : CSR_AXI_LEN_L ] ,
                                        csr_w_saved_attr [ CSR_AXI_SIZE_H : CSR_AXI_SIZE_L] ,
                                        csr_w_saved_attr [ CSR_AXI_PROT_H : CSR_AXI_PROT_L] ,
                                        csr_w_valid
                                    };

assign csr_register[CSR_W_ID]  = (LOG_WRITE_ID==1)? 
                                        { {(32 - AXI_ID_W){1'b0} } , csr_w_saved_attr[CSR_AXI_ID_H:CSR_AXI_ID_L] } : '0;

assign csr_register[CSR_W_ADDR]  = (LOG_WRITE_ADDR==1)?
//                                        (AXI_ADDR_W == 32) ?
//                                            csr_w_saved_attr [CSR_AXI_ADDR_L + 31 : CSR_AXI_ADDR_L] :
//                                            { {(32 - AXI_ADDR_W){1'b0} } , csr_w_saved_attr [CSR_AXI_ADDR_L + AXI_ADDR_W : CSR_AXI_ADDR_L] } :
                                       { {(32 - (CSR_AXI_ADDR1_H - CSR_AXI_ADDR1_L + 1)){1'b0} } , csr_w_saved_attr [CSR_AXI_ADDR1_H : CSR_AXI_ADDR1_L] } :

                                        '0;

assign csr_register[CSR_W_ADDR2] = (AXI_ADDR_W > 32) & (LOG_WRITE_ADDR==1) ?
//                                        (AXI_ADDR_W == 64) ?
//                                            csr_w_saved_attr [CSR_AXI_ADDR_L + 63 : CSR_AXI_ADDR_L + 32] :
//                                            { {(64 - AXI_ADDR_W){1'b0} } , csr_w_saved_attr [CSR_AXI_ADDR_L + AXI_ADDR_W : CSR_AXI_ADDR_L + 32]} :
                                       { {(32 - (CSR_AXI_ADDR2_H - CSR_AXI_ADDR2_L + 1)){1'b0} } , csr_w_saved_attr [CSR_AXI_ADDR2_H : CSR_AXI_ADDR2_L] } :
                                        '0;

assign csr_register[CSR_W_WDATA]   = (LOG_WRITE_DATA==1)? 
                                       { {(32 - (CSR_AXI_DATA1_H - CSR_AXI_DATA1_L + 1)){1'b0} } , csr_w_saved_attr [CSR_AXI_DATA1_H : CSR_AXI_DATA1_L] } :                                       '0;
//                                            csr_w_saved_attr [CSR_AXI_DATA_L + 31 : CSR_AXI_DATA_L ] : '0;
assign csr_register[CSR_W_WDATA2]  = (LOG_WRITE_DATA==1) & (AXI_DATA_W > 32) ? 
//                                            csr_w_saved_attr [CSR_AXI_DATA_L + 63  : CSR_AXI_DATA_L + 32 ] : '0;
                                       { {(32 - (CSR_AXI_DATA2_H - CSR_AXI_DATA2_L + 1)){1'b0} } , csr_w_saved_attr [CSR_AXI_DATA2_H : CSR_AXI_DATA2_L] } :                                       '0;

assign csr_register[CSR_W_WDATA3]  = (LOG_WRITE_DATA==1) & (AXI_DATA_W > 64) ? 
//                                            csr_w_saved_attr [CSR_AXI_DATA_L + 95  : CSR_AXI_DATA_L + 64 ] : '0;
                                       { {(32 - (CSR_AXI_DATA3_H - CSR_AXI_DATA3_L + 1)){1'b0} } , csr_w_saved_attr [CSR_AXI_DATA3_H : CSR_AXI_DATA3_L] } :                                       '0;

assign csr_register[CSR_W_WDATA4]  = (LOG_WRITE_DATA==1) & (AXI_DATA_W > 96) ? 
//                                            csr_w_saved_attr [CSR_AXI_DATA_L + 127 : CSR_AXI_DATA_L + 96 ] : '0;
                                       { {(32 - (CSR_AXI_DATA4_H - CSR_AXI_DATA4_L + 1)){1'b0} } , csr_w_saved_attr [CSR_AXI_DATA4_H : CSR_AXI_DATA4_L] } :                                       '0;


assign csr_register[CSR_UNDEF] = '0;

 end : CSR_CONTROL_LOGIC

else 
 begin : NO_CSR_LOGIC

assign irq                  = 1'b0;
assign av_readdata          = '0;

 end : NO_CSR_LOGIC
endgenerate

//--------------------------------------
// Assertions
//--------------------------------------
// synthesis translate_off
`define altera_error_response_slave_assert_clk(arg) \
    assert property (@(posedge clk) disable iff (!rst_n) arg)

// synthesis translate_on

endmodule : altera_error_response_slave

