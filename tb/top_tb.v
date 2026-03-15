module top_tb;

    reg clk;
    reg reset;

    // Instantiate the Full CPU (Top Module)
    top uut (
        .clk(clk),
        .reset(reset)
    );

    // 1. Clock Generation (Flip every 5ns)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("cpu_test.vcd");
        $dumpvars(0, top_tb);
        
      
        // 2. Initialize
        clk = 0;
        reset = 1; // Hold reset button

        // 3. Release Reset
        #10;
        reset = 0; // Let the CPU run!

        // 4. Run for a few cycles
        #300;

        // 5. Print register values to verify
        $display("=== Register File State ===");
        $display("x1  = %0d (expect 5)",   uut.reg_unit.rf[1]);
        $display("x2  = %0d (expect 5)",   uut.reg_unit.rf[2]);
        $display("x3  = %0d (expect 10)",  uut.reg_unit.rf[3]);
        $display("--- Branch Taken Tests ---");
        $display("x4  = %0d (expect 0,  BEQ taken)",    uut.reg_unit.rf[4]);
        $display("x6  = %0d (expect 0,  BNE taken)",    uut.reg_unit.rf[6]);
        $display("x28 = %0d (expect 0,  BLT taken)",    uut.reg_unit.rf[28]);
        $display("x30 = %0d (expect 0,  BGE taken)",    uut.reg_unit.rf[30]);
        $display("--- Branch Not-Taken Tests ---");
        $display("x5  = %0d (expect 99, BEQ not taken)", uut.reg_unit.rf[5]);
        $display("x7  = %0d (expect 99, BNE not taken)", uut.reg_unit.rf[7]);
        $display("x29 = %0d (expect 99, BLT not taken)", uut.reg_unit.rf[29]);
        $display("x31 = %0d (expect 99, BGE not taken)", uut.reg_unit.rf[31]);

        $finish;
    end

endmodule