module top_tb;

    reg clk;
    reg reset;

    top uut (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("cpu_test.vcd");
        $dumpvars(0, top_tb);

        clk = 0;
        reset = 1;

        #10;
        reset = 0;

        #500;

        $display("=== Pipelined CPU Test ===");

        $display("--- Independent instructions ---");
        $display("x1  = %0d (expect 5)",   uut.reg_unit.rf[1]);
        $display("x2  = %0d (expect 10)",  uut.reg_unit.rf[2]);
        $display("x3  = %0d (expect 15)",  uut.reg_unit.rf[3]);
        $display("x4  = %0d (expect 20)",  uut.reg_unit.rf[4]);

        $display("--- Dependent (x5 = x1 + 1) ---");
        $display("x5  = %0d (expect 6)",   uut.reg_unit.rf[5]);

        $display("--- Store/Load ---");
        $display("x6  = %0d (expect 5)",   uut.reg_unit.rf[6]);

        $display("--- LUI ---");
        $display("x7  = %0h (expect deadb000)", uut.reg_unit.rf[7]);

        $display("--- AUIPC ---");
        $display("x8  = %0h (expect 102c)",     uut.reg_unit.rf[8]);

        $display("--- JAL ---");
        $display("x9  = %0h (expect 40, return addr)", uut.reg_unit.rf[9]);
        $display("x10 = %0d (expect 0, skipped)",      uut.reg_unit.rf[10]);

        $finish;
    end

endmodule
