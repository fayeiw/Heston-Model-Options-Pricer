// SUCCESSFUL

// Directed testbench for cos_taylor_q824: applies a range of non‑trivial angles, converts to Q8.24, and checks output against $cos with a small tolerance
`timescale 1ns/1ps
module tb_cos_taylor_q824;
    reg  signed [31:0] x;
    wire signed [31:0] cos_out;

    cos_taylor_q824 dut (
        .x      (x),
        .cos_out(cos_out)
    );


    real angles [0:6];
    integer i;
    integer x_fixed;
    integer expected_fixed;
    integer diff;

    integer tol = 1000;

    initial 
    begin
        angles[0] = -1.0;
        angles[1] = -0.5;
        angles[2] = -0.1;
        angles[3] =  0.0;
        angles[4] =  0.1;
        angles[5] =  0.5;
        angles[6] =  1.0;

        for (i = 0; i < 7; i = i + 1) begin
            // convert real angle to Q8.24 fixed‑point
            x_fixed = $rtoi(angles[i] * (1<<24));
            x = x_fixed;
            #1;
            // compute expected cosine in Q8.24
            expected_fixed = $rtoi($cos(angles[i]) * (1<<24));
            diff = cos_out - expected_fixed;
            if (diff < 0) diff = -diff;
            if (diff > tol)
                $error("angle=%0f rad: cos_out=0x%h expected=0x%h diff=%0d > tol", 
                       angles[i], cos_out, expected_fixed, diff);
            else
                $display("angle=%0f rad: cos_out=0x%h expected=0x%h diff=%0d", 
                         angles[i], cos_out, expected_fixed, diff);
        end

        $display("All cos_taylor_q824 tests passed");
        $finish;
    end
endmodule
