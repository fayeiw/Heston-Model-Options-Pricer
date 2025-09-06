// SUCCESSFUL

// Directed testbench for div_q824:
// Applies numerator/denominator pairs, converts to Q8.24, and checks quotient within tolerance.
// Prints values as HEX (decimal) for easy visualization.
`timescale 1ns/1ps
module tb_div_q824;

    // Q8.24 fixed-point I/O to DUT
    reg  signed [31:0] numerator, denominator;
    wire signed [31:0] quotient;

    // Stimulus
    integer i;
    real nums[0:4], dens[0:4];

    // Fixed-point helpers
    integer num_fixed, den_fixed, expected_fixed, diff;
    integer tol = 100; // tolerance in Q8.24 LSBs (~100 / 2^24 ~= 5.96e-6)

    // For pretty printing
    real SCALE;
    real num_dec, den_dec, q_dec, exp_dec;

    // DUT under test (adjust port names/types if yours differ)
    div_q824 dut (
        .a   (numerator),
        .b    (denominator),
        .q    (quotient)
    );

    initial begin
        SCALE = 16777216.0; // 2^24 as a real

        // Non-trivial test vectors (include signs)
        nums[0] =  1.0;   dens[0] =  2.0;
        nums[1] =  3.5;   dens[1] =  1.25;
        nums[2] = -2.0;   dens[2] =  0.5;
        nums[3] =  0.5;   dens[3] = -4.0;
        nums[4] = -1.5;   dens[4] = -3.0;

        $display("---- div_q824 directed tests ----");

        for (i = 0; i < 5; i = i + 1) begin
            // Convert to Q8.24
            num_fixed = $rtoi(nums[i] * (1 << 24));
            den_fixed = $rtoi(dens[i] * (1 << 24));

            numerator   = num_fixed;
            denominator = den_fixed;

            // Let combinational DUT settle (adjust if your DUT is pipelined)
            #1;

            // Expected (software) result in Q8.24; skip divide-by-zero
            if (dens[i] == 0.0) begin
                $display("Test %0d: SKIPPED (denominator is zero)", i);
                continue;
            end
            expected_fixed = $rtoi((nums[i] / dens[i]) * (1 << 24));

            // Compute absolute diff in LSBs
            diff = quotient - expected_fixed;
            if (diff < 0) diff = -diff;

            // Pretty-print decimals from Q8.24
            num_dec = $itor(numerator)   / SCALE;
            den_dec = $itor(denominator) / SCALE;
            q_dec   = $itor(quotient)    / SCALE;
            exp_dec = $itor(expected_fixed) / SCALE;

            // Show inputs first
            $display("Inputs  : numerator=%h (%.6f)  denominator=%h (%.6f)",
                     numerator, num_dec, denominator, den_dec);

            // Show output vs expected as HEX (decimal)
            if (diff > tol) begin
                $error("Test %0d: %f / %f -> got %h (%.6f), expected %h (%.6f), diff=%0d > tol",
                       i, nums[i], dens[i], quotient, q_dec, expected_fixed, exp_dec, diff);
            end else begin
                $display("Test %0d: %f / %f -> got %h (%.6f), expected %h (%.6f), diff=%0d",
                         i, nums[i], dens[i], quotient, q_dec, expected_fixed, exp_dec, diff);
            end

            $display("");
        end

        $display("All div_q824 tests completed.");
        $finish;
    end
endmodule
