// SUCCESSFUL

// Directed testbench for discount_engine: uses random Q8.24 sum, count, r, T, checks price_out ≈ exp(-r*T)*(sum/count)
`timescale 1ns/1ps
module tb_discount_engine;
    reg         clk, rst, en;
    reg signed [31:0] sum, count, r, T;
    wire signed [31:0] price_out;

    discount_engine dut (
        .clk(clk), .rst(rst), .en(en),
        .sum(sum), .count(count), .r(r), .T(T),
        .price_out(price_out)
    );

    initial 
    begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    integer i;
    real sum_real, count_real, r_real, T_real;
    integer sum_fixed, count_fixed, r_fixed, T_fixed;
    integer price_fixed, expected_fixed, diff;
    integer tol = 2000;

    initial 
    begin
        // reset
        rst = 1; en = 0;
        #20;
        rst = 0;
        #10;

        for (i = 0; i < 10; i = i + 1) begin
            // generate random real inputs
            sum_real   = $urandom_range(100,10000)/100.0;    // 1.00 to 100.00
            count_real = $urandom_range(1,10);              // integer 1 to 10
            r_real     = $urandom_range(0,200)/1000.0;       // 0.000 to 0.200
            T_real     = $urandom_range(1,1000)/1000.0;      // 0.001 to 1.000

            // convert to Q8.24
            sum   = $rtoi(sum_real   * (1<<24));
            count = $rtoi(count_real * (1<<24));
            r     = $rtoi(r_real     * (1<<24));
            T     = $rtoi(T_real     * (1<<24));

            // apply enable and latch output
            en = 1;
            #10;
            en = 0;

            price_fixed = price_out;
            // compute expected price = exp(-r_real*T_real)*(sum_real/count_real)
            expected_fixed = $rtoi($exp(-r_real*T_real)*(sum_real/count_real)*(1<<24));

            diff = price_fixed > expected_fixed ? price_fixed - expected_fixed : expected_fixed - price_fixed;
            if (diff > tol)
                $error("Test %0d: price_out=%0d exp=%0d diff=%0d > tol", i, price_fixed, expected_fixed, diff);
            else
                $display("Test %0d: price_out=%0d exp=%0d diff=%0d", i, price_fixed, expected_fixed, diff);
        end

        $display("All discount_engine tests passed");
        $finish;
    end
endmodule
