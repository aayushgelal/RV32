module pc(
    input clk,
    input rst,
    input [31:0] pc_next,
    output reg [31:0] pc

);

    always @(posedge clk) begin 
        if (rst) begin
            pc<=32'b0;
        end else begin
            pc<=pc_next;
        end
    end

endmodule