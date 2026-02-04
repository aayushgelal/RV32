module top(
    input clk,
    input reset
);
    // --- 1. WIRE DECLARATIONS ---
    wire [31:0] pc_out;
    wire [31:0] pc_next;
    wire [31:0] instr;
    wire [31:0] imm_ext;
    wire [31:0] alu_result;
    wire zero;
    wire [2:0] alu_ctrl_wire;
    
    // FIX: These must be 32 bits wide!
    wire [31:0] srcA;       
    wire [31:0] srcB_reg;   
    
    // NEW WIRE: The output of the "Switch" (Mux) that goes into the ALU
    wire [31:0] srcB_mux;   

    // --- 2. THE MUX (The Switch) ---
    // For "addi", we want the Immediate (imm_ext).
    // For now, we HARDCODE this to 1 (Select Immediate). 
    // Later, the Control Unit will flip this switch automatically.
    assign srcB_mux = (1'b1) ? imm_ext : srcB_reg; 


    // --- 3. MODULE INSTANTIATIONS ---

    pc pc_unit(
        .clk(clk),
        .rst(reset),
        .pc_next(pc_next),
        .pc(pc_out)
    );
    
    // Don't forget the PC Adder! Without this, PC never changes.
    pc_adder pc_adder_unit(
        .a(pc_out),
        .y(pc_next)
    );

    imem imem_unit(
        .a(pc_out),
        .rd(instr)
    );

    control control_unit(
        .opcode(instr[6:0]),
        .funct3(instr[14:12]),   // <--- Connect bits 14-12
        .funct7(instr[31:25]),   // <--- Connect bits 31-25
        .reg_write(reg_write_wire),
        .alu_src(alu_src_wire),
        .alu_control(alu_ctrl_wire)
    );
    
    regfile reg_unit(
        .clk(clk),
        .we3(1'b1),        // Hardcoded: Always write
        .a1(instr[19:15]), // Source 1
        .a2(instr[24:20]), // Source 2
        .a3(instr[11:7]),  // Destination (Write)
        .rd1(srcA),        // Output 1
        .wd3(alu_result),  // Loopback data
        .rd2(srcB_reg)     // Output 2
    );

    imm_gen gen_unit(
        .instr(instr),     // You forgot to connect the input!
        .imm_ext(imm_ext)
    );

    alu alu_unit(
        .src1(srcA),        // Fixed name (was src1)
        .src2(srcB_mux),    // Connected to the MUX output
        .alu_control(alu_ctrl_wire), // Hardcoded: 000 = ADD (for now)
        .result(alu_result),
        .zero(zero)
    );

endmodule