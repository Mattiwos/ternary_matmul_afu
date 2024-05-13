
module matrix_unit import config_pkg::*; (
    input  logic         clk_i,
    input  logic         rst_ni,

    output logic         ready_o,
    input  logic         start_i,

    output ddr_address_t ddr_address_o,
    output logic         ddr_w_en_o,
    output ddr_data_t    ddr_w_data_o,
    input  logic         ddr_w_done_i,
    output logic         ddr_r_en_o,
    input  ddr_data_t    ddr_r_data_i,
    input  logic         ddr_r_valid_i
);

enum logic [1:0] {
    WAITING_FOR_IN = 1,
    WORKING = 2
} state_d, state_q;

logic [$bits(instruction_t)-1:0] IMEM [NumInstructions];
initial $readmemb("tmi/process.memb", IMEM);
instruction_t instruction;

logic busy, stall;

pc_t pc_d, pc_q;
always_comb begin
    pc_d = pc_q;
    ready_o = 0;
    state_d = state_q;

    instruction = 'x;
    instruction.fu = NOP;

    if (state_q == WAITING_FOR_IN) begin
        ready_o = 1;
        if (start_i) begin
            pc_d = 0;
            state_d = WORKING;
            instruction = IMEM[pc_d];
        end
    end else if (state_q == WORKING) begin
        if (pc_q < NumInstructions-1) begin
            pc_d++;
            instruction = IMEM[pc_d];
        end else if (!busy) begin
            state_d = WAITING_FOR_IN;
        end
    end
end

logic                  loadstore_in_ready;
logic                  loadstore_in_valid_d, loadstore_in_valid_q;
load_store_operation_t loadstore_operation_d, loadstore_operation_q;
ddr_address_t          loadstore_memory_address_d, loadstore_memory_address_q;

DI_t                   loadstore_vector_addr;
fixed_point_t          loadstore_vector_r_data;
fixed_point_t          loadstore_vector_w_data;
logic                  loadstore_vector_w_en;

ddr_address_t          loadstore_ddr_address;
logic                  loadstore_ddr_w_en;
ddr_data_t             loadstore_ddr_w_data;
logic                  loadstore_ddr_w_done;
logic                  loadstore_ddr_r_en;
ddr_data_t             loadstore_ddr_r_data;
logic                  loadstore_ddr_r_valid;

vector_load_store vector_load_store (
    .clk_i,
    .rst_ni,

    .in_ready_o(loadstore_in_ready),
    .in_valid_i(loadstore_in_valid_q),
    .vector_operation_i(loadstore_operation_q),
    .vector_memory_address_i(loadstore_memory_address_q),

    .vector_addr_o(loadstore_vector_addr),
    .vector_r_data_i(loadstore_vector_r_data),
    .vector_w_data_o(loadstore_vector_w_data),
    .vector_w_en_o(loadstore_vector_w_en),

    .ddr_address_o(loadstore_ddr_address),
    .ddr_w_en_o(loadstore_ddr_w_en),
    .ddr_w_data_o(loadstore_ddr_w_data),
    .ddr_w_done_i(loadstore_ddr_w_done),
    .ddr_r_en_o(loadstore_ddr_r_en),
    .ddr_r_data_i(loadstore_ddr_r_data),
    .ddr_r_valid_i(loadstore_ddr_r_valid)
);

logic         rowwise_operation_in_ready;
logic         rowwise_operation_in_valid_d, rowwise_operation_in_valid_q;
operation_t   rowwise_operation_operation_d, rowwise_operation_operation_q;

DI_t          rowwise_operation_vector_addr;
logic         rowwise_operation_vector_w_en;
fixed_point_t rowwise_operation_vector_w_data;
fixed_point_t rowwise_operation_vector1_r_data;
fixed_point_t rowwise_operation_vector2_r_data;

rowwise_operation rowwise_operation (
    .clk_i,
    .rst_ni,

    .in_ready_o(rowwise_operation_in_ready),
    .in_valid_i(rowwise_operation_in_valid_q),
    .vector_operation_i(rowwise_operation_operation_q),

    .vector_addr_o(rowwise_operation_vector_addr),
    .vector_w_en_o(rowwise_operation_vector_w_en),
    .vector_w_data_o(rowwise_operation_vector_w_data),
    .vector1_r_data_i(rowwise_operation_vector1_r_data),
    .vector2_r_data_i(rowwise_operation_vector2_r_data)
);

logic         tmatmul_in_ready;
logic         tmatmul_in_valid_d, tmatmul_in_valid_q;
ddr_address_t tmatmul_memory_address_d, tmatmul_memory_address_q;

DI_t          tmatmul_vector_addr;
logic         tmatmul_vector_w_en;
fixed_point_t tmatmul_vector_w_data;
fixed_point_t tmatmul_vector_r_data;

ddr_address_t tmatmul_ddr_address;
logic         tmatmul_ddr_r_en;
ddr_data_t    tmatmul_ddr_r_data;
logic         tmatmul_ddr_r_valid;

ternary_matmul ternary_matmul (
    .clk_i,
    .rst_ni,

    .in_ready_o(tmatmul_in_ready),
    .in_valid_i(tmatmul_in_valid_q),
    .maxtrix_memory_address_i(tmatmul_memory_address_q),

    .vector_addr_o(tmatmul_vector_addr),
    .vector_w_en_o(tmatmul_vector_w_en),
    .vector_w_data_o(tmatmul_vector_w_data),
    .vector_r_data_i(tmatmul_vector_r_data),

    .ddr_address_o(tmatmul_ddr_address),
    .ddr_r_en_o(tmatmul_ddr_r_en),
    .ddr_r_data_i(tmatmul_ddr_r_data),
    .ddr_r_valid_i(tmatmul_ddr_r_valid)
);

logic         rms_in_ready;
logic         rms_in_start_d, rms_in_start_q;

DI_t          rms_vector_addr;
logic         rms_vector_w_en;
fixed_point_t rms_vector_w_data;
fixed_point_t rms_vector_r_data;

rms rms (
    .clk_i,
    .rst_ni,

    .in_ready_o(rms_in_ready),
    .in_start_i(rms_in_start_q),

    .vector_addr_o(rms_vector_addr),
    .vector_w_en_o(rms_vector_w_en),
    .vector_w_data_o(rms_vector_w_data),
    .vector_r_data_i(rms_vector_r_data)
);

logic         [NumVectorRegisters-1:0] registers_w_en;
DI_t          [NumVectorRegisters-1:0] registers_w_addr;
fixed_point_t [NumVectorRegisters-1:0] registers_w_data;
DI_t          [NumVectorRegisters-1:0] registers_r_addr;
fixed_point_t [NumVectorRegisters-1:0] registers_r_data;

v_addr_t reg_loadstore_x_d, reg_loadstore_x_q;

v_addr_t reg_rowwise_a_d, reg_rowwise_a_q;
v_addr_t reg_rowwise_b_d, reg_rowwise_b_q;
v_addr_t reg_rowwise_y_d, reg_rowwise_y_q;

v_addr_t reg_tmatmul_a_d, reg_tmatmul_a_q;
v_addr_t reg_tmatmul_y_d, reg_tmatmul_y_q;

v_addr_t reg_norm_x_d, reg_norm_x_q;

vector_registers vector_registers (
    .clk_i,

    .vector_w_en_i(registers_w_en),
    .vector_w_addr_i(registers_w_addr),
    .vector_w_data_i(registers_w_data),
    .vector_r_addr_i(registers_r_addr),
    .vector_r_data_o(registers_r_data)
);

wire loadstore_busy         = (!loadstore_in_ready         || loadstore_in_valid_q);
wire rowwise_operation_busy = (!rowwise_operation_in_ready || rowwise_operation_in_valid_q);
wire tmatmul_busy           = (!tmatmul_in_ready           || tmatmul_in_valid_q);
wire rms_busy               = (!rms_in_ready               || rms_in_start_q);

assign busy = (loadstore_busy || rowwise_operation_busy || tmatmul_busy || rms_busy || stall);

always_comb begin
    registers_w_en = '0;
    registers_w_addr = '0;
    registers_w_data = '0;
    registers_r_addr = '0;

    loadstore_vector_r_data = '0;
    rowwise_operation_vector1_r_data = '0;
    rowwise_operation_vector2_r_data = '0;
    tmatmul_vector_r_data = '0;
    rms_vector_r_data = '0;
    if (loadstore_busy) begin
        registers_w_en[reg_loadstore_x_q] |= loadstore_vector_w_en;
        registers_w_addr[reg_loadstore_x_q] |= loadstore_vector_addr;
        registers_w_data[reg_loadstore_x_q] |= loadstore_vector_w_data;
        registers_r_addr[reg_loadstore_x_q] |= loadstore_vector_addr;
        loadstore_vector_r_data |= registers_r_data[reg_loadstore_x_q];
    end
    if (rowwise_operation_busy) begin
        registers_r_addr[reg_rowwise_a_q] |= rowwise_operation_vector_addr;
        rowwise_operation_vector1_r_data |= registers_r_data[reg_rowwise_a_q];

        registers_r_addr[reg_rowwise_b_q] |= rowwise_operation_vector_addr;
        rowwise_operation_vector2_r_data |= registers_r_data[reg_rowwise_b_q];

        registers_w_en[reg_rowwise_y_q] |= rowwise_operation_vector_w_en;
        registers_w_addr[reg_rowwise_y_q] |= rowwise_operation_vector_addr;
        registers_w_data[reg_rowwise_y_q] |= rowwise_operation_vector_w_data;
    end
    if (tmatmul_busy) begin
        registers_r_addr[reg_tmatmul_a_q] |= tmatmul_vector_addr;
        tmatmul_vector_r_data |= registers_r_data[reg_tmatmul_a_q];

        registers_w_en[reg_tmatmul_y_q] |= tmatmul_vector_w_en;
        registers_w_addr[reg_tmatmul_y_q] |= tmatmul_vector_addr;
        registers_w_data[reg_tmatmul_y_q] |= tmatmul_vector_w_data;
    end
    if (rms_busy) begin
        registers_w_en[reg_norm_x_q] |= rms_vector_w_en;
        registers_w_addr[reg_norm_x_q] |= rms_vector_addr;
        registers_w_data[reg_norm_x_q] |= rms_vector_w_data;
        registers_r_addr[reg_norm_x_q] |= rms_vector_addr;
        rms_vector_r_data |= registers_r_data[reg_norm_x_q];
    end
end

logic [NumVectorRegisters-1:0] reg_busy;
always_comb begin
    reg_busy = '0;
    if (loadstore_busy) begin
        reg_busy[reg_loadstore_x_q] |= 1;
    end
    if (rowwise_operation_busy) begin
        reg_busy[reg_rowwise_a_q] |= 1;
        reg_busy[reg_rowwise_b_q] |= 1;
        reg_busy[reg_rowwise_y_q] |= 1;
    end
    if (tmatmul_busy) begin
        reg_busy[reg_tmatmul_a_q] |= 1;
        reg_busy[reg_tmatmul_y_q] |= 1;
    end
    if (rms_busy) begin
        reg_busy[reg_norm_x_q] |= 1;
    end
end

always_comb begin
    stall = 0;
    // check if FU is busy
    unique case (instruction.fu)
        // TMATMUL and LOAD_STORE block each other due to DDR accesses
        LOAD_STORE:        stall |= (loadstore_busy | tmatmul_busy);
        ROWWISE_OPERATION: stall |= rowwise_operation_busy;
        TMATMUL:           stall |= (tmatmul_busy | loadstore_busy);
        RMS:               stall |= rms_busy;
        default: ;
    endcase
    // check if vector registers are in use
    unique case (instruction.fu)
        LOAD_STORE: unique case (instruction.loadstore_operation)
            LDV: begin
                stall |= reg_busy[instruction.v_y];
            end SV: begin
                stall |= reg_busy[instruction.v_a];
            end default: ;
        endcase ROWWISE_OPERATION: unique case (instruction.operation)
            ADD, SUB, MUL, DIV: begin
                stall |= reg_busy[instruction.v_a];
                stall |= reg_busy[instruction.v_b];
                stall |= reg_busy[instruction.v_y];
            end EXP, SIG: begin
                stall |= reg_busy[instruction.v_a];
                stall |= reg_busy[instruction.v_y];
            end
        endcase TMATMUL: begin
                stall |= reg_busy[instruction.v_a];
                stall |= reg_busy[instruction.v_y];
        end RMS: begin
                stall |= reg_busy[instruction.v_a];
        end default: ;
    endcase
end

always_comb begin
    loadstore_operation_d = loadstore_operation_q;
    loadstore_memory_address_d = loadstore_memory_address_q;
    loadstore_in_valid_d = 0;
    reg_loadstore_x_d = reg_loadstore_x_q;

    rowwise_operation_operation_d = rowwise_operation_operation_q;
    rowwise_operation_in_valid_d = 0;
    reg_rowwise_a_d = reg_rowwise_a_q;
    reg_rowwise_b_d = reg_rowwise_b_q;
    reg_rowwise_y_d = reg_rowwise_y_q;

    tmatmul_in_valid_d = 0;
    tmatmul_memory_address_d = tmatmul_memory_address_q;
    reg_tmatmul_a_d = reg_tmatmul_a_q;
    reg_tmatmul_y_d = reg_tmatmul_y_q;

    rms_in_start_d = 0;
    reg_norm_x_d = reg_norm_x_q;

    unique case (instruction.fu)
        LOAD_STORE: begin
            loadstore_in_valid_d = 1;
            loadstore_operation_d = instruction.loadstore_operation;
            loadstore_memory_address_d = instruction.ddr_address;
            unique case (instruction.loadstore_operation)
                LDV: begin
                    reg_loadstore_x_d = instruction.v_y;
                end SV: begin
                    reg_loadstore_x_d = instruction.v_a;
                end default: ;
            endcase
        end ROWWISE_OPERATION: begin
            rowwise_operation_in_valid_d = 1;
            rowwise_operation_operation_d = instruction.operation;
            unique case (instruction.operation)
                ADD, SUB, MUL, DIV: begin
                    reg_rowwise_a_d = instruction.v_a;
                    reg_rowwise_b_d = instruction.v_b;
                    reg_rowwise_y_d = instruction.v_y;
                end EXP, SIG: begin
                    reg_rowwise_a_d = instruction.v_a;
                    reg_rowwise_b_d = instruction.v_a;
                    reg_rowwise_y_d = instruction.v_y;
                end default: ;
            endcase
        end TMATMUL: begin
            tmatmul_in_valid_d = 1;
            tmatmul_memory_address_d = instruction.ddr_address;
            reg_tmatmul_a_d = instruction.v_a;
            reg_tmatmul_y_d = instruction.v_y;
        end RMS: begin
            rms_in_start_d = 1;
            reg_norm_x_d = instruction.v_y;
        end default: ;
    endcase
end

always_comb begin
    ddr_address_o = loadstore_ddr_address | tmatmul_ddr_address;
    ddr_w_en_o = loadstore_ddr_w_en;
    ddr_w_data_o = loadstore_ddr_w_data;
    ddr_r_en_o = loadstore_ddr_r_en | tmatmul_ddr_r_en;

    loadstore_ddr_w_done = ddr_w_done_i;
    loadstore_ddr_r_data = ddr_r_data_i;
    loadstore_ddr_r_valid = ddr_r_valid_i;

    tmatmul_ddr_r_data = ddr_r_data_i;
    tmatmul_ddr_r_valid = ddr_r_valid_i;
end

always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        state_q <= WAITING_FOR_IN;
        pc_q <= 0;
    end else if (!stall) begin
        state_q <= state_d;
        pc_q <= pc_d;
    end
end
always_ff @(posedge clk_i) begin
    if (!stall) begin
        loadstore_operation_q <= loadstore_operation_d;
        loadstore_memory_address_q <= loadstore_memory_address_d;
        reg_loadstore_x_q <= reg_loadstore_x_d;

        rowwise_operation_operation_q <= rowwise_operation_operation_d;
        reg_rowwise_a_q <= reg_rowwise_a_d;
        reg_rowwise_b_q <= reg_rowwise_b_d;
        reg_rowwise_y_q <= reg_rowwise_y_d;

        tmatmul_memory_address_q <= tmatmul_memory_address_d;
        reg_tmatmul_a_q <= reg_tmatmul_a_d;
        reg_tmatmul_y_q <= reg_tmatmul_y_d;

        reg_norm_x_q <= reg_norm_x_d;
    end
end
always_ff @(posedge clk_i) begin
    if (stall || !rst_ni) begin
        loadstore_in_valid_q <= 0;
        rowwise_operation_in_valid_q <= 0;
        tmatmul_in_valid_q <= 0;
        rms_in_start_q <= 0;
    end else begin
        loadstore_in_valid_q <= loadstore_in_valid_d;
        rowwise_operation_in_valid_q <= rowwise_operation_in_valid_d;
        tmatmul_in_valid_q <= tmatmul_in_valid_d;
        rms_in_start_q <= rms_in_start_d;
    end
end

endmodule
