module top(
    input clk,
    input reset
);
    // --- WIRES ---
    wire [31:0] pc_out, pc_next, instr;
    wire [31:0] imm_ext, alu_result, read_data; // read_data is new!
    wire [31:0] srcA, srcB_reg, srcB_mux, result_mux; // result_mux is new!
    wire zero;

    wire reg_write_wire, alu_src_wire, mem_write_wire, result_src_wire;
    wire [2:0] alu_ctrl_wire;

    // --- MUX 1: ALU Source (Immediate vs Register) ---
    assign srcB_mux = (alu_src_wire) ? imm_ext : srcB_reg;

    // --- MUX 2: Result Source (Memory vs ALU) ---
    // If result_src is 1 (Load), save Memory Data. If 0, save ALU answer.
    assign result_mux = (result_src_wire) ? read_data : alu_result;

    // --- MODULES ---
    pc pc_unit( .clk(clk), .rst(reset), .pc_next(pc_next), .pc(pc_out) );
    pc_adder pc_adder_unit( .a(pc_out), .y(pc_next) );
    imem imem_unit( .a(pc_out), .rd(instr) );

    control control_unit(
        .opcode(instr[6:0]), .funct3(instr[14:12]), .funct7(instr[31:25]),
        .reg_write(reg_write_wire),
        .alu_src(alu_src_wire),
        .alu_control(alu_ctrl_wire),
        .mem_write(mem_write_wire),   // NEW
        .result_src(result_src_wire)  // NEW
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