module control(
    input [6:0] opcode,
    input [2:0] funct3,     
    input [6:0] funct7,    
    output reg reg_write,
    output reg alu_src,
    output reg [2:0] alu_control,
    output reg mem_write,
    output reg [1:0] result_src,
    output reg branch,
    output reg jump,
    output reg jalr
);

    always @(*) begin
        reg_write = 0;
        alu_src = 0;
        alu_control = 3'b000;
        mem_write = 0;
        result_src = 2'b00;
        branch = 0;
        jump = 0;
        jalr = 0;

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

            // LOAD (lw) -> Read from Memory, Write to Register
            7'b0000011: begin
                reg_write = 1;      // Yes, we save the result
                alu_src = 1;        // Address = Reg + Immediate
                mem_write = 0;      // Read Only
                result_src = 2'b01; // <--- KEY: Save Data from Memory, NOT ALU
                alu_control = 3'b000; // ADD (to calculate address)
            end
            
            //store

            // B-type (BEQ, BNE, BLT, BGE)
            7'b1100011: begin
                branch = 1;
                reg_write = 0;
                alu_src = 0;        // Compare two registers
                mem_write = 0;
                result_src = 0;
                case (funct3)
                    3'b000, 3'b001: alu_control = 3'b001; // BEQ/BNE: SUB
                    3'b100, 3'b101: alu_control = 3'b101; // BLT/BGE: SLT
                    default:        alu_control = 3'b001;
                endcase
            end

            7'b0100011: begin
                reg_write = 0;
                alu_src = 1;        // Address = Reg + Immediate
                mem_write = 1;      // <--- KEY: Write ENABLED
                result_src = 2'b00; // Doesn't matter (reg_write is 0)
                alu_control = 3'b000; // ADD (to calculate address)
            end

            // JAL (Jump and Link)
            7'b1101111: begin
                reg_write = 1;
                jump = 1;
                result_src = 2'b10; // Write PC+4 to rd
            end

            // JALR (Jump and Link Register)
            7'b1100111: begin
                reg_write = 1;
                jalr = 1;
                alu_src = 1;          // rs1 + immediate
                alu_control = 3'b000; // ADD
                result_src = 2'b10;   // Write PC+4 to rd
            end

        endcase
    end
endmodule