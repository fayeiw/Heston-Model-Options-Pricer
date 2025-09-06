// SUCCESSFUL
`
timescale 1ns/1ps

module tb_rng_lfsr_32;

    // -------------------
    // DUT I/O
    // -------------------
    reg         clk;
    reg         en;
    reg         reset;
    reg  [31:0] seed;
    wire [31:0] rand_q8_24;

    // -------------------
    // TB variables
    // -------------------
    reg  [31:0] expected;
    reg         feedback;
    integer     cycle;

    // -------------------
    // Instantiate DUT
    // -------------------
    rng_lfsr_32 dut (
        .clk       (clk),
        .reset     (reset),
        .en        (en),
        .lfsr      (seed),
        .rand_q8_24(rand_q8_24)
    );

    // -------------------
    // Clock generation
    // -------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // -------------------
    // Test Procedure
    // -------------------
    initial begin
        en    = 1'b1;
        reset = 1'b1;
        seed  = $random;// initial seed
        $display("%h", seed);
        expected = seed;  // expected starts as seed
        cycle = 0;

        @(posedge clk);  // load seed into DUT
        reset = 1'b0;

        // run for 20 cycles
        for (cycle = 0; cycle < 20; cycle = cycle + 1) begin
            @(posedge clk);
            #0.1;
            // check DUT output matches expected
            if (rand_q8_24 !== expected) begin
                $error("Cycle %0d FAILED: got=0x%08h expected=0x%08h",
                        cycle, rand_q8_24, expected);
            end else begin
                $display("Cycle %0d PASSED: 0x%08h", cycle, rand_q8_24);
            end

            // compute next expected value for next cycle
            feedback = expected[23] ^ expected[17] ^ expected[5] ^ expected[0];
            expected = {8'b0, expected[22:0], feedback};
        end

        $display("All cycles completed");
        $finish;
    end

endmodule
