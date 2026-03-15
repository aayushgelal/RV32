module top(
    input clk,
    input reset
);
    // --- WIRES ---
    wire [31:0] pc_out, pc_plus4, pc_next, instr;
    wire [31:0] imm_ext, alu_result, read_data;
    wire [31:0] srcA_reg, srcB_reg, srcB_mux;
    wire [31:0] branch_target;
    wire zero;

    wire reg_write_wire, alu_src_wire, mem_write_wire, branch_wire, jump_wire, jalr_wire;
    wire [1:0] result_src_wire, alu_src1_wire;
    wire [3:0] alu_ctrl_wire;

    // --- MUX 0: ALU Source 1 (Register / PC / Zero) ---
    reg [31:0] srcA;
    always @(*) begin
        case (alu_src1_wire)
            2'b00: srcA = srcA_reg;   // Normal: from register file
            2'b01: srcA = pc_out;     // AUIPC: PC
            2'b10: srcA = 32'b0;      // LUI: zero
            default: srcA = srcA_reg;
        endcase
    end

    // --- MUX 1: ALU Source 2 (Immediate vs Register) ---
    assign srcB_mux = (alu_src_wire) ? imm_ext : srcB_reg;

    // --- MUX 2: Result Source (ALU / Memory / PC+4) ---
    reg [31:0] result_mux;
    always @(*) begin
        case (result_src_wire)
            2'b00: result_mux = alu_result;  // R-type, I-type, LUI, AUIPC
            2'b01: result_mux = read_data;   // Load
            2'b10: result_mux = pc_plus4;    // JAL, JALR
            default: result_mux = alu_result;
        endcase
    end

    // --- BRANCH / JUMP LOGIC ---
    assign branch_target = pc_out + imm_ext;
    wire [31:0] jalr_target;
    assign jalr_target = alu_result & 32'hFFFFFFFE;

    // Branch condition based on funct3
    reg branch_taken;
    always @(*) begin
        branch_taken = 0;
        if (branch_wire) begin
            case (instr[14:12])
                3'b000: branch_taken = zero;             // BEQ
                3'b001: branch_taken = ~zero;            // BNE
                3'b100: branch_taken = alu_result[0];    // BLT
                3'b101: branch_taken = ~alu_result[0];   // BGE
                3'b110: branch_taken = alu_result[0];    // BLTU (same logic, SLTU in ALU)
                3'b111: branch_taken = ~alu_result[0];   // BGEU
                default: branch_taken = 0;
            endcase
        end
    end

    // --- MUX 3: PC Source ---
    assign pc_next = (jalr_wire)                  ? jalr_target :
                     (jump_wire || branch_taken)   ? branch_target :
                                                     pc_plus4;

    // --- MODULES ---
    pc pc_unit( .clk(clk), .rst(reset), .pc_next(pc_next), .pc(pc_out) );
    pc_adder pc_adder_unit( .a(pc_out), .y(pc_plus4) );
    imem imem_unit( .a(pc_out), .rd(instr) );

    control control_unit(
        .opcode(instr[6:0]), .funct3(instr[14:12]), .funct7(instr[31:25]),
        .reg_write(reg_write_wire),
        .alu_src(alu_src_wire),
        .alu_control(alu_ctrl_wire),
        .mem_write(mem_write_wire),
        .result_src(result_src_wire),
        .branch(branch_wire),
        .jump(jump_wire),
        .jalr(jalr_wire),
        .alu_src1(alu_src1_wire)
    );

    regfile reg_unit(
        .clk(clk), .we3(reg_write_wire),
        .a1(instr[19:15]), .a2(instr[24:20]), .a3(instr[11:7]),
        .rd1(srcA_reg), .rd2(srcB_reg),
        .wd3(result_mux)
    );

    imm_gen gen_unit( .instr(instr), .imm_ext(imm_ext) );

    alu alu_unit(
        .src1(srcA), .src2(srcB_mux), .alu_control(alu_ctrl_wire),
        .result(alu_result), .zero(zero)
    );

    // --- DATA MEMORY ---
    dmem dmem_unit(
        .clk(clk),
        .we(mem_write_wire),
        .a(alu_result),
        .wd(srcB_reg),
        .rd(read_data)
    );

endmodule
