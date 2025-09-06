// SUCCESSFUL

/ Directed testbench for accumulator: tests reset, accumulation, disable clear, and done flag at count==32
`timescale 1ns/1ps
module tb_accumulator;
    reg         clk, rst, en, valid_in;
    reg  [31:0] payoff_in;
    wire [31:0] sum_out, count_out;
    wire        done;
    integer     i;
    reg  [31:0] expected_sum, expected_count;

    accumulator dut (
        .clk       (clk),
        .rst       (rst),
        .en        (en),
        .valid_in  (valid_in),
        .payoff_in (payoff_in),
        .sum_out   (sum_out),
        .count_out (count_out),
        .done      (done)
    );

    initial 
    begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial 
    begin
        // Reset and initial values
        rst            = 1;
        en             = 0;
        valid_in       = 0;
        payoff_in      = 32'b0;
        expected_sum   = 32'b0;
        expected_count = 32'b0;
        #10 rst = 0;
        #10 en  = 1;

        // Apply 5 valid samples: payoffs 1.0,2.0,3.0,4.0,5.0 in Q8.24 (0x01000000 increments)
        for (i = 0; i < 5; i = i + 1) 
        begin
            payoff_in      = 32'h01000000 * (i + 1);
            valid_in       = 1;
            expected_sum   = expected_sum + payoff_in;
            expected_count = expected_count + 1;
            #10;
            if (sum_out   !== expected_sum)   $error("Cycle %0d: sum_out=%h expected=%h",   i, sum_out,   expected_sum);
            if (count_out !== expected_count) $error("Cycle %0d: count_out=%h expected=%h", i, count_out, expected_count);
            if (done)                         $error("Cycle %0d: done asserted too early", i);
        end

        // Disable accumulation: sum and count should clear to zero
        en       = 0;
        valid_in = 1;
        payoff_in = 32'hDEADBEEF;
        #10;
        if (sum_out   !== 32'b0) $error("sum not cleared when en=0");
        if (count_out !== 32'b0) $error("count not cleared when en=0");

        // Test done flag: reset then apply 32 valid cycles, done should assert at count==32
        rst            = 1; #10; rst = 0;
        en             = 1;
        valid_in       = 1;
        payoff_in      = 32'h00000001;
        expected_sum   = 32'b0;
        expected_count = 32'b0;
        for (i = 0; i < 32; i = i + 1) begin
            expected_sum   = expected_sum + payoff_in;
            expected_count = expected_count + 1;
            #10;
        end
        if (!done) $error("done not asserted at count==32");

        $display("All accumulator tests passed");
        $finish;
    end
endmodule
