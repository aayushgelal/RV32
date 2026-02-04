module alu(
    input [31:0] src1,
    input [31:0] src2,
    input [2:0] alu_control,
    output reg [31:0] result,
    output zero
);

    always @(*) begin
        case (alu_control)
            3'b000: result = src1 + src2;           // ADD
            3'b001: result = src1 - src2;           // SUB
            3'b010: result = src1 & src2;           // AND
            3'b011: result = src1 | src2;           // OR
            3'b100: result = src1 ^ src2;           // XOR
            3'b101: result = (src1 < src2) ? 1 : 0; // SLT (Set Less Than)
            3'b110: result = src1 << src2[4:0];     // SLL (Shift Left)
            3'b111: result = src1 >> src2[4:0];     // SRL (Shift Right)
            
            default: result = 32'b0;
        endcase
    end

    assign zero = (result == 0) ? 1'b1 : 1'b0;

endmodule