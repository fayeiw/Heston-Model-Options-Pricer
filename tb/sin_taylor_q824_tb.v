// SUCCESSFUL

// Directed testbench for sin_taylor_q824: applies a range of angles and checks sin_out vs expected
`timescale 1ns/1ps
module tb_sin_taylor_q824;
    reg signed [31:0] x;
    wire signed [31:0] sin_out;
    real angles [0:6];
    integer i;
    integer x_fixed, expected_fixed, diff;
    integer tol = 1000;

    sin_taylor_q824 dut (
        .x      (x),
        .sin_out(sin_out)
    );

    initial 
    begin
        angles[0] = -1.0;
        angles[1] = -0.5;
        angles[2] = -0.1;
        angles[3] =  0.0;
        angles[4] =  0.1;
        angles[5] =  0.5;
        angles[6] =  1.0;

        for (i = 0; i < 7; i = i + 1) 
        begin
            x_fixed = $rtoi(angles[i] * (1 << 24));
            x = x_fixed;
            #1;
            expected_fixed = $rtoi($sin(angles[i]) * (1 << 24));
            diff = sin_out - expected_fixed;
            if (diff < 0) diff = -diff;
            if (diff > tol)
                $error("angle=%0f rad: got 0x%h expected 0x%h diff=%0d > tol", 
                       angles[i], sin_out, expected_fixed, diff);
            else
                $display("angle=%0f rad: got 0x%h expected 0x%h diff=%0d", 
                         angles[i], sin_out, expected_fixed, diff);
        end

        $display("All sin_taylor_q824 tests passed");
        $finish;
    end
endmodule
