module top(
    input clk,
    input reset
);
    // --- WIRES ---
    wire [31:0] pc_out, pc_plus4, pc_next, instr;
    wire [31:0] imm_ext, alu_result, read_data;
    wire [31:0] srcA, srcB_reg, srcB_mux, result_mux;
    wire [31:0] branch_target;
    wire zero;

    wire reg_write_wire, alu_src_wire, mem_write_wire, result_src_wire, branch_wire;
    wire [2:0] alu_ctrl_wire;

    // --- MUX 1: ALU Source (Immediate vs Register) ---
    assign srcB_mux = (alu_src_wire) ? imm_ext : srcB_reg;

    // --- MUX 2: Result Source (Memory vs ALU) ---
    assign result_mux = (result_src_wire) ? read_data : alu_result;

    // --- BRANCH LOGIC ---
    assign branch_target = pc_out + imm_ext;

    // Branch condition based on funct3
    reg pc_src;
    always @(*) begin
        pc_src = 0;
        if (branch_wire) begin
            case (instr[14:12])
                3'b000: pc_src = zero;             // BEQ: taken if equal
                3'b001: pc_src = ~zero;            // BNE: taken if not equal
                3'b100: pc_src = alu_result[0];    // BLT: taken if src1 < src2
                3'b101: pc_src = ~alu_result[0];   // BGE: taken if src1 >= src2
                default: pc_src = 0;
            endcase
        end
    end

    // --- MUX 3: PC Source (PC+4 vs Branch Target) ---
    assign pc_next = (pc_src) ? branch_target : pc_plus4;

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
        .branch(branch_wire)
    );

    regfile reg_unit(
        .clk(clk), .we3(reg_write_wire),
        .a1(instr[19:15]), .a2(instr[24:20]), .a3(instr[11:7]),
        .rd1(srcA), .rd2(srcB_reg),
        .wd3(result_mux) // <--- CONNECTED TO RESULT MUX (Not just ALU anymore!)
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
        .a(alu_result),      // Address comes from ALU
        .wd(srcB_reg),       // Data to save comes from RegFile (Read Data 2)
        .rd(read_data)       // Read Data goes to Result Mux
    );

endmodule