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
        $display("=== JAL / JALR Tests ===");
        $display("--- TEST 1: JAL forward ---");
        $display("x9  = %0d (expect 12, return addr 0x0C)",  uut.reg_unit.rf[9]);
        $display("x3  = %0d (expect 0,  JAL skipped x3=1)",  uut.reg_unit.rf[3]);
        $display("--- TEST 2: JALR ---");
        $display("x4  = %0d (expect 40, target addr 0x28)",  uut.reg_unit.rf[4]);
        $display("x5  = %0d (expect 36, return addr 0x24)",  uut.reg_unit.rf[5]);
        $display("x6  = %0d (expect 0,  JALR skipped x6=1)", uut.reg_unit.rf[6]);
        $display("--- TEST 3: Function call (JAL+JALR return) ---");
        $display("x7  = %0d (expect 99, returned from function)", uut.reg_unit.rf[7]);
        $display("x8  = %0d (expect 20, function body ran)",      uut.reg_unit.rf[8]);

        $finish;
    end

endmodule