module sin_taylor_q824 (
    input  wire signed [31:0] x,       // Q8.24 input
    output wire signed [31:0] sin_out  // Q8.24 output
);

    localparam signed [31:0] INV_3FACT = 32'sd2796203;   
    localparam signed [31:0] INV_5FACT = 32'sd139810;    
    localparam signed [31:0] INV_7FACT = 32'sd3329; 

    // Step 1: x^2 = (x * x) >> 24
    wire signed [63:0] x2_full = x * x;
    wire signed [31:0] x2 = x2_full[55:24];

    // Step 2: x^3 = (x2 * x) >> 24
    wire signed [63:0] x3_full = x2 * x;
    wire signed [31:0] x3 = x3_full[55:24];

    // Step 3: x^5 = x3 * x2 >> 24
    wire signed [63:0] x5_full = x3 * x2;
    wire signed [31:0] x5 = x5_full[55:24];

    // Step 4: x^7 = x5 * x2 >> 24
    wire signed [63:0] x7_full = x5 * x2;
    wire signed [31:0] x7 = x7_full[55:24];


    // Compute scaled terms
    wire signed [63:0] term3_full = x3 * INV_3FACT;
    wire signed [31:0] term3 = term3_full[55:24];

    wire signed [63:0] term5_full = x5 * INV_5FACT;
    wire signed [31:0] term5 = term5_full[55:24];

    wire signed [63:0] term7_full = x7 * INV_7FACT;
    wire signed [31:0] term7 = term7_full[55:24];


    // Final sum: sin(x) ≈ x - x^3/6 + x^5/120 - x^7/5040
    wire signed [31:0] tmp1 = x - term3;
    wire signed [31:0] tmp2 = tmp1 + term5;
    wire signed [31:0] tmp3 = tmp2 - term7;

    assign sin_out = tmp3;
endmodule
