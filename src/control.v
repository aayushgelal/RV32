module control(
    input [6:0] opcode,
    input [2:0] funct3,     
    input [6:0] funct7,    
    output reg reg_write,
    output reg alu_src,
    output reg [2:0] alu_control
);

    always @(*) begin
        reg_write = 0;
        alu_src = 0;
        alu_control = 3'b000;

        case (opcode)
            7'b0110011: begin
                reg_write = 1;
                alu_src = 0; 

                case (funct3)
                    3'b000: begin 
                        if (funct7[5]) alu_control = 3'b001; // SUB
                        else           alu_control = 3'b000; // ADD
                    end
                    
                    3'b001: alu_control = 3'b100; // SLL (Shift Left) - Corresponds to 0x1
                    3'b010: alu_control = 3'b101; // SLT (Set Less Than) - Corresponds to 0x2
                    3'b100: alu_control = 3'b110; // XOR
                    3'b101: alu_control = 3'b111; // SRL (Shift Right) - Corresponds to 0x5
                    3'b110: alu_control = 3'b011; // OR 
                    3'b111: alu_control = 3'b010; // AND
                endcase
            end

            
            7'b0010011: begin
                reg_write = 1;
                alu_src = 1; 
                
                case (funct3)
                    3'b000: alu_control = 3'b000; // ADDI
                    3'b110: alu_control = 3'b010; // ORI
                    3'b111: alu_control = 3'b011; // ANDI
                    3'b001: alu_control = 3'b110; // SLLI (Use your SLL code)
                    3'b101: alu_control = 3'b111; // SRLI (Use your SRL code)
                    default: alu_control = 3'b000;
                endcase
            end
        endcase
    end
endmodule