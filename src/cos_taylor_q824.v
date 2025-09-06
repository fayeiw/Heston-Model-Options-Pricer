module cos_taylor_q824 (
    input  wire signed [31:0] x,       
    output wire signed [31:0] cos_out  
);
    // Constants in Q8.24 format
    localparam signed [31:0] ONE_Q824   = 32'sd16777216;  
    localparam signed [31:0] INV_2FACT  = 32'sd8388608;   
    localparam signed [31:0] INV_4FACT  = 32'sd699051;
    localparam signed [31:0] INV_6FACT  = 32'sd23302;   

    // Step 1: x^2 = (x * x) >> 24
    wire signed [63:0] x2_full = x * x;
    wire signed [31:0] x2 = x2_full[55:24];

    // Step 2: x^4 = (x2 * x2) >> 24
    wire signed [63:0] x4_full = x2 * x2;
    wire signed [31:0] x4 = x4_full[55:24];

    // Step 3: x^6 = (x4 * x2) >> 24
    wire signed [63:0] x6_full = x4 * x2;
    wire signed [31:0] x6 = x6_full[55:24];


    // Compute scaled terms
    wire signed [63:0] term2_full = x2 * INV_2FACT;
    wire signed [31:0] term2 = term2_full[55:24];

    wire signed [63:0] term4_full = x4 * INV_4FACT;
    wire signed [31:0] term4 = term4_full[55:24];

    wire signed [63:0] term6_full = x6 * INV_6FACT;
    wire signed [31:0] term6 = term6_full[55:24];


    // Final sum: cos(x) ≈ 1 - x^2/2 + x^4/24 - x^6/720
    wire signed [31:0] tmp1 = ONE_Q824 - term2;
    wire signed [31:0] tmp2 = tmp1 + term4;
    wire signed [31:0] tmp3 = tmp2 - term6;

    assign cos_out = tmp3;

endmodule
