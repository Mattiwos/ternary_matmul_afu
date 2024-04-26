
module matrix_unit import config_pkg::*; (
    input  logic         clk_i,
    input  logic         rst_ni,

    output logic         ready_o,
    input  logic         start_i,

    output ddr_address_t ddr_w_address_o,
    output logic         ddr_w_en_o,
    output ddr_data_t    ddr_w_data_o,

    output ddr_address_t ddr_r_address_o,
    output logic         ddr_r_en_o,
    input  ddr_data_t    ddr_r_data_i
);

enum logic [1:0] {
    WAITING_FOR_IN,
    WORKING
} state_d, state_q;

logic [$bits(instruction_t)-1:0] IMEM [NumInstructions];
initial $readmemb("tmi/process.memb", IMEM);
instruction_t instruction;

logic busy;

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

v_addr_t reg_loadstore_x_d, reg_loadstore_x_q;

v_addr_t reg_rowwise_a_d, reg_rowwise_a_q;
v_addr_t reg_rowwise_b_d, reg_rowwise_b_q;
v_addr_t reg_rowwise_y_d, reg_rowwise_y_q;

v_addr_t reg_tmatmul_a_d, reg_tmatmul_a_q;
v_addr_t reg_tmatmul_y_d, reg_tmatmul_y_q;

v_addr_t reg_norm_x_d, reg_norm_x_q;

load_store_operation_t load_store_operation_d, load_store_operation_q;
ddr_address_t          load_store_ddr_address_d, load_store_ddr_address_q;
vector_t               load_store_vector_i;
vector_t               load_store_vector_o;
logic                  load_store_vector_wen;
logic                  load_store_in_ready;
logic                  load_store_in_valid_d, load_store_in_valid_q;

load_store load_store (
    .clk_i,
    .rst_ni,

    .operation_i(load_store_operation_q),
    .ddr_address_i(load_store_ddr_address_q),
    .vector_i(load_store_vector_i),
    .vector_o(load_store_vector_o),
    .vector_wen_o(load_store_vector_wen),
    .matrix_i(registers_r_tm_data),
    .matrix_o(registers_w_tm_data),
    .matrix_wen_o(registers_w_tm_en),
    .in_ready_o(load_store_in_ready),
    .in_valid_i(load_store_in_valid_q),

    .ddr_w_address_o,
    .ddr_w_en_o,
    .ddr_w_data_o,

    .ddr_r_address_o,
    .ddr_r_en_o,
    .ddr_r_data_i
);

vector_t    rowwise_operation_a;
vector_t    rowwise_operation_b;
operation_t rowwise_operation_operation_d, rowwise_operation_operation_q;
logic       rowwise_operation_in_ready;
logic       rowwise_operation_in_valid_d, rowwise_operation_in_valid_q;

vector_t    rowwise_operation_new_result;
vector_t    rowwise_operation_old_result;

rowwise_operation rowwise_operation (
    .clk_i,
    .rst_ni,

    .a_i(rowwise_operation_a),
    .b_i(rowwise_operation_b),
    .operation_i(rowwise_operation_operation_q),
    .in_ready_o(rowwise_operation_in_ready),
    .in_valid_i(rowwise_operation_in_valid_q),

    .new_result_o(rowwise_operation_new_result),
    .old_result_i(rowwise_operation_old_result)
);

vector_t         ternary_matmul_vector;
logic            ternary_matmul_in_ready;
logic            ternary_matmul_in_valid_d, ternary_matmul_in_valid_q;

vector_t         ternary_matmul_result;
logic            ternary_matmul_out_valid;

ternary_matmul ternary_matmul (
    .clk_i,
    .rst_ni,

    .vector_i(ternary_matmul_vector),
    .matrix_i(registers_r_tm_data),
    .in_ready_o(ternary_matmul_in_ready),
    .in_valid_i(ternary_matmul_in_valid_q),

    .result_o(ternary_matmul_result),
    .out_valid_o(ternary_matmul_out_valid)
);

logic    rms_in_ready;
logic    rms_in_valid_d, rms_in_valid_q;
vector_t rms_a;

logic    rms_out_valid;
vector_t rms_result;

rms rms (
    .clk_i,
    .rst_ni,

    .in_ready_o(rms_in_ready),
    .in_valid_i(rms_in_valid_q),
    .a_i(rms_a),

    .out_valid_o(rms_out_valid),
    .result_o(rms_result)
);

logic [NumVectorRegisters-1:0]    registers_w_v_en;
vector_t [NumVectorRegisters-1:0] registers_w_v_data;
vector_t [NumVectorRegisters-1:0] registers_r_v_data;

logic                             registers_w_tm_en;
ternary_matrix_t                  registers_w_tm_data;
ternary_matrix_t                  registers_r_tm_data;

registers registers (
    .clk_i,

    .w_v_en_i(registers_w_v_en),
    .w_v_data_i(registers_w_v_data),
    .r_v_data_o(registers_r_v_data),

    .w_tm_en_i(registers_w_tm_en),
    .w_tm_data_i(registers_w_tm_data),
    .r_tm_data_o(registers_r_tm_data)
);

wire load_store_busy        = (!load_store_in_ready        || load_store_in_valid_q);
wire rowwise_operation_busy = (!rowwise_operation_in_ready || rowwise_operation_in_valid_q);
wire ternary_matmul_busy    = (!ternary_matmul_in_ready    || ternary_matmul_in_valid_q);
wire rms_busy               = (!rms_in_ready               || rms_in_valid_q);

assign busy = load_store_busy || rowwise_operation_busy || ternary_matmul_busy || rms_busy || stall;

logic stall;
always_comb begin
    stall = 0;
    // check if FU is busy
    unique case (instruction.fu)
        LOAD_STORE:        stall |= load_store_busy;
        ROWWISE_OPERATION: stall |= rowwise_operation_busy;
        TMATMUL:           stall |= ternary_matmul_busy;
        RMS:               stall |= rms_busy;
        default: ;
    endcase
    // check if vector registers are in use
    unique case (instruction.fu)
        LOAD_STORE: unique case (instruction.load_store_operation)
            LDV: begin
                stall |= (rowwise_operation_busy) && (
                          (instruction.v_y == reg_rowwise_a_q)
                       || (instruction.v_y == reg_rowwise_b_q)
                       || (instruction.v_y == reg_rowwise_y_q));
                stall |= (ternary_matmul_busy) && (
                          (instruction.v_y == reg_tmatmul_a_q)
                       || (instruction.v_y == reg_tmatmul_y_q));
                stall |= (rms_busy) && (instruction.v_y == reg_norm_x_q);
            end SV: begin
                stall |= (rowwise_operation_busy) && (
                          (instruction.v_a == reg_rowwise_a_q)
                       || (instruction.v_a == reg_rowwise_b_q)
                       || (instruction.v_a == reg_rowwise_y_q));
                stall |= (ternary_matmul_busy) && (
                          (instruction.v_a == reg_tmatmul_a_q)
                       || (instruction.v_a == reg_tmatmul_y_q));
                stall |= (rms_busy) && (instruction.v_a == reg_norm_x_q);
            end default: ;
        endcase ROWWISE_OPERATION: unique case (instruction.operation)
            ADD, SUB, MUL, DIV: begin
                stall |= (load_store_busy) && (
                          (instruction.v_a == reg_loadstore_x_q)
                       || (instruction.v_b == reg_loadstore_x_q)
                       || (instruction.v_y == reg_loadstore_x_q));
                stall |= (ternary_matmul_busy) && (
                          (instruction.v_a == reg_tmatmul_a_q)
                       || (instruction.v_a == reg_tmatmul_y_q)
                       || (instruction.v_b == reg_tmatmul_a_q)
                       || (instruction.v_b == reg_tmatmul_y_q)
                       || (instruction.v_y == reg_tmatmul_a_q)
                       || (instruction.v_y == reg_tmatmul_y_q));
                stall |= (rms_busy) && (
                          (instruction.v_a == reg_norm_x_q)
                       || (instruction.v_b == reg_norm_x_q)
                       || (instruction.v_y == reg_norm_x_q));
            end EXP, SIG: begin
                stall |= (load_store_busy) && (
                          (instruction.v_a == reg_loadstore_x_q)
                       || (instruction.v_y == reg_loadstore_x_q));
                stall |= (ternary_matmul_busy) && (
                          (instruction.v_a == reg_tmatmul_a_q)
                       || (instruction.v_a == reg_tmatmul_y_q)
                       || (instruction.v_y == reg_tmatmul_a_q)
                       || (instruction.v_y == reg_tmatmul_y_q));
                stall |= (rms_busy) && (
                          (instruction.v_a == reg_norm_x_q)
                       || (instruction.v_y == reg_norm_x_q));
            end
        endcase TMATMUL: begin
            stall |= (load_store_busy) && (
                      (instruction.v_a == reg_loadstore_x_q)
                   || (instruction.v_y == reg_loadstore_x_q));
            stall |= (rowwise_operation_busy) && (
                      (instruction.v_a == reg_rowwise_a_q)
                   || (instruction.v_y == reg_rowwise_a_q)
                   || (instruction.v_a == reg_rowwise_b_q)
                   || (instruction.v_y == reg_rowwise_b_q)
                   || (instruction.v_a == reg_rowwise_y_q)
                   || (instruction.v_y == reg_rowwise_y_q));
            stall |= (rms_busy) && (
                      (instruction.v_a == reg_norm_x_q)
                   || (instruction.v_y == reg_norm_x_q));
        end RMS: begin
            stall |= (load_store_busy) && (instruction.v_a == reg_loadstore_x_q);
            stall |= (rowwise_operation_busy) && (
                      (instruction.v_a == reg_rowwise_a_q)
                   || (instruction.v_a == reg_rowwise_b_q)
                   || (instruction.v_a == reg_rowwise_y_q));
            stall |= (ternary_matmul_busy) && (
                      (instruction.v_a == reg_tmatmul_a_q)
                   || (instruction.v_a == reg_tmatmul_y_q));
        end default: ;
        endcase
    // check if matrix registers are in use
    if (instruction.fu == LOAD_STORE && (instruction.load_store_operation inside {LDTM, STM}))
        stall |= (ternary_matmul_busy);
    if (instruction.fu == TMATMUL)
        stall |= (load_store_busy && (load_store_operation_q inside {LDTM, STM}));
end

assign load_store_vector_i = registers_r_v_data[reg_loadstore_x_q];

assign rowwise_operation_a = registers_r_v_data[reg_rowwise_a_q];
assign rowwise_operation_b = registers_r_v_data[reg_rowwise_b_q];
assign rowwise_operation_old_result = registers_r_v_data[reg_rowwise_y_q];

assign ternary_matmul_vector = registers_r_v_data[reg_tmatmul_a_d];

assign rms_a = registers_r_v_data[reg_norm_x_q];

always_comb begin
    registers_w_v_data = registers_r_v_data;
    registers_w_v_en = '0;

    if (load_store_vector_wen) begin
        registers_w_v_en[reg_loadstore_x_q] |= 1;
        registers_w_v_data[reg_loadstore_x_q] |= load_store_vector_o;
    end
    if (!rowwise_operation_in_ready) begin
        registers_w_v_en[reg_rowwise_y_q] |= 1;
        registers_w_v_data[reg_rowwise_y_q] |= rowwise_operation_new_result;
    end
    if (ternary_matmul_out_valid) begin
        registers_w_v_en[reg_tmatmul_y_q] |= 1;
        registers_w_v_data[reg_tmatmul_y_q] |= ternary_matmul_result;
    end
    if (rms_out_valid) begin
        registers_w_v_en[reg_norm_x_q] |= 1;
        registers_w_v_data[reg_norm_x_q] |= rms_result;
    end
end

always_comb begin
    load_store_operation_d = load_store_operation_q;
    load_store_ddr_address_d = load_store_ddr_address_q;
    load_store_in_valid_d = 0;
    reg_loadstore_x_d = reg_loadstore_x_q;

    rowwise_operation_operation_d = rowwise_operation_operation_q;
    rowwise_operation_in_valid_d = 0;
    reg_rowwise_a_d = reg_rowwise_a_q;
    reg_rowwise_b_d = reg_rowwise_b_q;
    reg_rowwise_y_d = reg_rowwise_y_q;

    ternary_matmul_in_valid_d = 0;
    reg_tmatmul_a_d = reg_tmatmul_a_q;
    reg_tmatmul_y_d = reg_tmatmul_y_q;

    rms_in_valid_d = 0;
    reg_norm_x_d = reg_norm_x_q;

    unique case (instruction.fu)
        LOAD_STORE: begin
            load_store_in_valid_d = 1;
            load_store_operation_d = instruction.load_store_operation;
            load_store_ddr_address_d = instruction.ddr_address;
            unique case (instruction.load_store_operation)
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
            ternary_matmul_in_valid_d = 1;
            reg_tmatmul_a_d = instruction.v_a;
            reg_tmatmul_y_d = instruction.v_y;
        end RMS: begin
            rms_in_valid_d = 1;
            reg_norm_x_d = instruction.v_y;
        end default: ;
    endcase
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
        load_store_operation_q <= load_store_operation_d;
        load_store_ddr_address_q <= load_store_ddr_address_d;
        reg_loadstore_x_q <= reg_loadstore_x_d;

        rowwise_operation_operation_q <= rowwise_operation_operation_d;
        reg_rowwise_a_q <= reg_rowwise_a_d;
        reg_rowwise_b_q <= reg_rowwise_b_d;
        reg_rowwise_y_q <= reg_rowwise_y_d;

        reg_tmatmul_a_q <= reg_tmatmul_a_d;
        reg_tmatmul_y_q <= reg_tmatmul_y_d;

        reg_norm_x_q <= reg_norm_x_d;
    end
end
always_ff @(posedge clk_i) begin
    if (stall || !rst_ni) begin
        load_store_in_valid_q <= 0;
        rowwise_operation_in_valid_q <= 0;
        ternary_matmul_in_valid_q <= 0;
        rms_in_valid_q <= 0;
    end else begin
        load_store_in_valid_q <= load_store_in_valid_d;
        rowwise_operation_in_valid_q <= rowwise_operation_in_valid_d;
        ternary_matmul_in_valid_q <= ternary_matmul_in_valid_d;
        rms_in_valid_q <= rms_in_valid_d;
    end
end


endmodule
