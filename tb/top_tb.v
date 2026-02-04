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

        $finish;
    end

endmodule