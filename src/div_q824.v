// module div_q824 (
//     input  wire signed [31:0] numerator,   
//     input  wire signed [31:0] denominator, 
//     output wire signed [31:0] quotient     
// );
//     localparam signed [31:0] ONE = 32'd16777216; 


//     wire signed [31:0] r0 = ONE;

//     // r1 = r0 * (2 - d * r0)
//     wire signed [63:0] d_mul_r0 = denominator * r0;
//     wire signed [31:0] d_mul_r0_q824 = d_mul_r0 >>> 24;

//     wire signed [31:0] two_minus_d_r0 = (2 * ONE - d_mul_r0_q824);
//     wire signed [63:0] r1_long = r0 * two_minus_d_r0;
//     wire signed [31:0] r1 = r1_long >>> 24; 

//     // quotient = a * r1
//     wire signed [63:0] num_mul_r1 = numerator * r1;
//     assign quotient = num_mul_r1 >>> 24;

// endmodule
// Approximate unsigned division: q ≈ num / den
// 16-bit example, 1 Newton step, no LUTs.
// Latency is purely combinational here; pipeline the multiplies for timing.
// Approximate unsigned division num/den using one Newton-Raphson step.
// 16-bit example, no LUTs. Combinational; pipeline multiplies if needed.
// Signed Q8.24 division: q = a / b  (fixed-point)
// Exact reference implementation using 64-bit intermediate.
// q = ((int64)a << 24) / (int32)b, with saturation for b==0 and overflow.
// Signed Q8.24 divider: q = a / b
// Reference (exact) implementation using 64-bit intermediate and '/'.
// Verilog-2001 compatible (no logic/longint/always_comb/etc.).
// Signed Q8.24 divide via restoring long division (no '/')
// q = a / b  where a,b,q are Q8.24 fixed-point
// Implements: q = ((int64)a << 24) / (int64)b with saturation.
// Verilog-2001 compatible.
module div_q824 (
    input  [31:0] a,  // Q8.24
    input  [31:0] b,  // Q8.24
    output [31:0] q   // Q8.24
);
    // Output reg
    reg [31:0] q_r;
    assign q = q_r;

    // Sign-extended operands
    reg [63:0] a64, b64;

    // Absolute values (unsigned)
    reg [63:0] a_abs, b_abs;

    // Scaled unsigned numerator and unsigned denominator
    reg [63:0] num_u, den_u;

    // Unsigned quotient (64b to catch overflow before saturating)
    reg [63:0] quo_u;

    // Result sign and helper
    reg        res_neg;
    reg [31:0] mag32;  // magnitude for negative result path

    // 64-bit unsigned restoring long division (combinational)
    function [63:0] udiv64;
        input [63:0] num;
        input [63:0] den;
        reg   [63:0] q;
        reg   [63:0] r;
        integer i;
        begin
            q = 64'd0;
            r = 64'd0;
            // From MSB to LSB
            for (i = 63; i >= 0; i = i - 1) begin
                r = {r[62:0], num[i]};
                if (r >= den) begin
                    r = r - den;
                    q[i] = 1'b1;
                end else begin
                    q[i] = 1'b0;
                end
            end
            udiv64 = q;
        end
    endfunction

    always @* begin
        // defaults
        q_r    = 32'd0;
        a64    = {{32{a[31]}}, a};
        b64    = {{32{b[31]}}, b};
        res_neg = a64[63] ^ b64[63];

        if (b == 32'd0) begin
            // divide-by-zero -> saturate by sign of a
            q_r = a[31] ? 32'h8000_0000 : 32'h7FFF_FFFF;
        end else begin
            // absolute values
            a_abs = a64[63] ? ((~a64) + 64'd1) : a64;
            b_abs = b64[63] ? ((~b64) + 64'd1) : b64;

            // scale numerator by 2^24 for Q8.24
            num_u = a_abs << 24;
            den_u = b_abs; // denominator stays as-is

            // unsigned long division
            quo_u = udiv64(num_u, den_u);

            // apply sign + saturate to 32-bit signed
            if (!res_neg) begin
                // positive
                if (quo_u > 64'd2147483647) q_r = 32'h7FFF_FFFF;
                else                         q_r = quo_u[31:0];
            end else begin
                // negative
                if (quo_u >= 64'd2147483648) begin
                    q_r = 32'h8000_0000;
                end else begin
                    mag32 = quo_u[31:0];     // <= 0x7FFF_FFFF here
                    q_r   = (~mag32) + 32'd1; // two's complement negate
                end
            end
        end
    end
endmodule
