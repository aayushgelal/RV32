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

        #300;

        $display("=== RV32I Complete Test Suite ===");

        $display("--- Setup ---");
        $display("x1  = %0d (expect 5)",   uut.reg_unit.rf[1]);
        $display("x2  = %0d (expect 10)",  uut.reg_unit.rf[2]);
        $display("x3  = %0h (expect ffffffff, -1)", uut.reg_unit.rf[3]);

        $display("--- I-type: XORI, SLTI, SLTIU, SRAI ---");
        $display("x4  = %0d (expect 10, xori 5^15)",        uut.reg_unit.rf[4]);
        $display("x5  = %0d (expect 1,  slti 5<10)",        uut.reg_unit.rf[5]);
        $display("x6  = %0d (expect 0,  slti 5<0 false)",   uut.reg_unit.rf[6]);
        $display("x7  = %0d (expect 1,  sltiu 5<u max)",    uut.reg_unit.rf[7]);
        $display("x8  = %0d (expect 1,  srai 5>>>2)",       uut.reg_unit.rf[8]);
        $display("x9  = %0h (expect ffffffff, srai -1>>>1)", uut.reg_unit.rf[9]);

        $display("--- R-type: SLTU, SRA ---");
        $display("x10 = %0d (expect 1,  sltu 5<u10)",       uut.reg_unit.rf[10]);
        $display("x11 = %0d (expect 0,  sltu 10<u5 false)", uut.reg_unit.rf[11]);
        $display("x12 = %0h (expect ffffffff, sra -1>>>5)",  uut.reg_unit.rf[12]);

        $display("--- BLTU ---");
        $display("x13 = %0d (expect 0,  bltu taken)",       uut.reg_unit.rf[13]);
        $display("x14 = %0d (expect 99, bltu not taken)",   uut.reg_unit.rf[14]);

        $display("--- BGEU ---");
        $display("x15 = %0d (expect 0,  bgeu taken)",       uut.reg_unit.rf[15]);
        $display("x16 = %0d (expect 99, bgeu not taken)",   uut.reg_unit.rf[16]);

        $display("--- LUI ---");
        $display("x20 = %0h (expect deadb000)",             uut.reg_unit.rf[20]);

        $display("--- AUIPC ---");
        $display("x21 = %0h (expect 1064)",                 uut.reg_unit.rf[21]);

        $finish;
    end

endmodule
