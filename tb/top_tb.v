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
        #100;

        // 5. Print register values to verify
        $display("=== Register File State ===");
        $display("x1  = %0d (expect 5)",  uut.reg_unit.rf[1]);
        $display("x2  = %0d (expect 10)", uut.reg_unit.rf[2]);
        $display("x5  = %0d (expect 20)", uut.reg_unit.rf[5]);
        $display("x6  = %0d (expect 5)",  uut.reg_unit.rf[6]);
        $display("x7  = %0d (expect 5)",  uut.reg_unit.rf[7]);
        $display("x8  = %0d (expect 10)", uut.reg_unit.rf[8]);

        $finish;
    end

endmodule