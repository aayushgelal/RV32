module imm_gen(
    input [31:0] instr,
    output [31:0] imm_ext

);


assign imm_ext = {{20{instr[31]}}, instr[31:20]};

endmodule