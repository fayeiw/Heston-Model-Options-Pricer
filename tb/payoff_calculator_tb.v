// SUCCESSFUL

// Directed testbench for payoff_calculator: tests reset, call and put payoffs with non-trivial inputs, and hold behavior when en=0
`timescale 1ns/1ps
module tb_payoff_calculator;
    reg         clk, rst, en;
    reg  [31:0] S_T, K;
    reg  [1:0]  option_type;
    wire [31:0] payoff;

    integer errors;

    payoff_calculator dut (
        .clk        (clk),
        .rst        (rst),
        .en         (en),
        .S_T        (S_T),
        .K          (K),
        .option_type(option_type),
        .payoff     (payoff)
    );

    initial 
    begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial 
    begin
        errors = 0;

        // 1) RESET behavior
        rst = 1; en = 0; S_T = 32'd123; K = 32'd45; option_type = 2'b00;
        #10;
        rst = 0; #10;
        if (payoff !== 32'd0) $error("After reset: payoff=%0d expected=0", payoff);

        // 2) Test CALL when S_T > K
        en = 1;
        S_T = 32'd100; K = 32'd 80; option_type = 2'b00; // payoff = 20
        #10;
        if (payoff !== 32'd20) $error("Call payoff wrong: got %0d expected 20", payoff);

        // 3) Test CALL when S_T <= K
        S_T = 32'd 50; K = 32'd 70; option_type = 2'b00; // payoff = 0
        #10;
        if (payoff !== 32'd0) $error("Call (underwater) payoff wrong: got %0d expected 0", payoff);

        // 4) Hold behavior when en=0
        en = 0;
        S_T = 32'd200; K = 32'd100; option_type = 2'b00;
        #10;
        if (payoff !== 32'd0) $error("Hold failed: payoff changed to %0d when en=0", payoff);

        // 5) Test PUT when K > S_T
        en = 1;
        S_T = 32'd 90; K = 32'd120; option_type = 2'b01; // payoff = 30
        #10;
        if (payoff !== 32'd30) $error("Put payoff wrong: got %0d expected 30", payoff);

        // 6) Test PUT when S_T >= K
        S_T = 32'd200; K = 32'd150; option_type = 2'b01; // payoff = 0
        #10;
        if (payoff !== 32'd0) $error("Put (out-of-the-money) payoff wrong: got %0d expected 0", payoff);

        $display("All payoff_calculator tests completed");
        $finish;
    end
endmodule
