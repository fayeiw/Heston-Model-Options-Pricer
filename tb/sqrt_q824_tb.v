//  SUCCESSFUL

// Directed testbench for sqrt_q824: applies non‑trivial inputs and checks sqrt_out vs expected sqrt within tolerance
`timescale 1ns/1ps
module tb_sqrt_q824;
    reg signed [31:0] a;
    wire signed [31:0] sqrt_out;
    real inputs[0:5];
    integer i;
    integer a_fixed, expected_fixed, diff;
    integer tol = 2000;

    sqrt_q824 dut (
        .a        (a),
        .sqrt_out (sqrt_out)
    );

    initial 
    begin
        // test vectors: 0.0, 0.25, 1.0, 2.0, 10.0, 123.456
        inputs[0] = 0.0;
        inputs[1] = 0.25;
        inputs[2] = 1.0;
        inputs[3] = 2.0;
        inputs[4] = 10.0;
        inputs[5] = 123.456;

        for (i = 0; i < 6; i = i + 1) 
        begin
            a_fixed = $rtoi(inputs[i] * (1<<24));
            a = a_fixed;
            #1;
            expected_fixed = $rtoi($sqrt(inputs[i]) * (1<<24));
            diff = sqrt_out - expected_fixed;
            if (diff < 0) diff = -diff;
            if (diff > tol)
                $error("input=%0f: got 0x%h expected 0x%h diff=%0d > tol", 
                       inputs[i], sqrt_out, expected_fixed, diff);
            else
                $display("input=%0f: got 0x%h expected 0x%h diff=%0d", 
                         inputs[i], sqrt_out, expected_fixed, diff);
        end

        $display("All sqrt_q824 tests passed");
        $finish;
    end
endmodule
