// SUCCESSFUL

`timescale 1ns/1ps

module tb_exp_taylor_q824;
    reg  signed [31:0] x_q824;   // Q8.24 input
    wire signed [31:0] y_q824;   // Q8.24 output
    integer tol = 2000;          

    integer x_fixed, expected_fixed, diff;
    integer fails;
    real    xr, yr, yexp;

    exp_taylor_q824 dut (
        .x_q824 (x_q824),
        .y_q824 (y_q824)
    );

    task run_case;
        input real xin; 
        x_fixed = $rtoi(xin * (1.0 * (1<<24)));
        x_q824  = x_fixed;
        #1;
        yexp            = $exp(xin);
        expected_fixed  = $rtoi(yexp * (1.0 * (1<<24)));
        diff = y_q824 - expected_fixed;
        if (diff < 0) diff = -diff;
        xr = xin;
        yr = $itor(y_q824) / (1.0 * (1<<24));
        if (diff > tol) 
        begin
            $display("FAIL: x=%0f -> y=0x%h (%.7f), exp=0x%h (%.7f), diff=%0d (> tol=%0d)",
                     xr, y_q824, yr, expected_fixed, yexp, diff, tol);
            fails = fails + 1;
        end 
        else 
        begin
            $display("PASS: x=%0f -> y=0x%h (%.7f), exp=0x%h (%.7f), diff=%0d",
                     xr, y_q824, yr, expected_fixed, yexp, diff);
        end
    endtask

    initial 
    begin
        fails = 0;
        run_case(-1.0);
        run_case(-0.5);
        run_case( 0.0);
        run_case( 0.5);
        run_case( 1.0);
        run_case( 2.0);
        run_case( 7.0);   
        run_case(-2.0);   

        if (fails == 0) begin
            $display("All exp_taylor_q824 tests PASSED");
        end else begin
            $display("%0d tests FAILED", fails);
        end
        $finish;
    end

endmodule
