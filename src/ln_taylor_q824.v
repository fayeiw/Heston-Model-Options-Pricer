module ln_taylor_q824 (
    input  wire signed [31:0] x,         // Q8.24 input: x in (-1, 1]
    output wire signed [31:0] ln1p_out   // Q8.24 output: ln(1+x)
);

    // 1/k in Q8.24
    localparam signed [31:0] INV_2 = 32'sd8388608;   // 1/2
    localparam signed [31:0] INV_3 = 32'sd5592405;   // 1/3
    localparam signed [31:0] INV_4 = 32'sd4194304;   // 1/4
    localparam signed [31:0] INV_5 = 32'sd3355443;   // 1/5
    localparam signed [31:0] INV_6 = 32'sd2796203;   // 1/6
    localparam signed [31:0] INV_7 = 32'sd2396745;   // 1/7

    // Step 1: x^2 = (x * x) >> 24
    wire signed [63:0] x2_full = x * x;
    wire signed [31:0] x2      = x2_full[55:24];

    // Step 2: x^3 = (x^2 * x) >> 24
    wire signed [63:0] x3_full = x2 * x;
    wire signed [31:0] x3      = x3_full[55:24];

    // Step 3: x^4 = (x^3 * x) >> 24
    wire signed [63:0] x4_full = x3 * x;
    wire signed [31:0] x4      = x4_full[55:24];

    // Step 4: x^5 = (x^4 * x) >> 24
    wire signed [63:0] x5_full = x4 * x;
    wire signed [31:0] x5      = x5_full[55:24];

    // Step 5: x^6 = (x^5 * x) >> 24
    wire signed [63:0] x6_full = x5 * x;
    wire signed [31:0] x6      = x6_full[55:24];

    // Step 6: x^7 = (x^6 * x) >> 24
    wire signed [63:0] x7_full = x6 * x;
    wire signed [31:0] x7      = x7_full[55:24];

    // Scale by reciprocals
    wire signed [63:0] t2_full = x2 * INV_2;  wire signed [31:0] t2 = t2_full[55:24];
    wire signed [63:0] t3_full = x3 * INV_3;  wire signed [31:0] t3 = t3_full[55:24];
    wire signed [63:0] t4_full = x4 * INV_4;  wire signed [31:0] t4 = t4_full[55:24];
    wire signed [63:0] t5_full = x5 * INV_5;  wire signed [31:0] t5 = t5_full[55:24];
    wire signed [63:0] t6_full = x6 * INV_6;  wire signed [31:0] t6 = t6_full[55:24];
    wire signed [63:0] t7_full = x7 * INV_7;  wire signed [31:0] t7 = t7_full[55:24];

    // Final sum: x - x^2/2 + x^3/3 - x^4/4 + x^5/5 - x^6/6 + x^7/7
    wire signed [31:0] s1 = x    - t2;
    wire signed [31:0] s2 = s1   + t3;
    wire signed [31:0] s3 = s2   - t4;
    wire signed [31:0] s4 = s3   + t5;
    wire signed [31:0] s5 = s4   - t6;
    wire signed [31:0] s6 = s5   + t7;

    assign ln1p_out = s6;

endmodule
