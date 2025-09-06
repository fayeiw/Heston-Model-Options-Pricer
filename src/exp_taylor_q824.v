module exp_taylor_q824 (
    input  signed [31:0] x_q824, 
    output reg   signed [31:0] y_q824
);
    // Q8.24 constants
    localparam signed [31:0] ONE_Q24   = 32'sd16777216; // 1.0 * 2^24
    localparam signed [31:0] INV1_Q24  = 32'sd16777216; // 1/1
    localparam signed [31:0] INV2_Q24  = 32'sd8388608;  // 1/2
    localparam signed [31:0] INV3_Q24  = 32'sd5592405;  // 1/3
    localparam signed [31:0] INV4_Q24  = 32'sd4194304;  // 1/4
    localparam signed [31:0] INV5_Q24  = 32'sd3355443;  // 1/5
    localparam signed [31:0] INV6_Q24  = 32'sd2796203;  // 1/6
    localparam signed [31:0] INV7_Q24  = 32'sd2396745;  // 1/7
    localparam signed [31:0] INV8_Q24  = 32'sd2097152;  // 1/8
    localparam signed [31:0] INV9_Q24  = 32'sd1864135;  // 1/9
    localparam signed [31:0] INV10_Q24 = 32'sd1677722;  // 1/10

    reg signed [31:0] sum_r;
    reg signed [31:0] term_r;

    function signed [31:0] qmul_q824;
        input signed [31:0] a;
        input signed [31:0] b;
        reg   signed [63:0] prod;
        reg   signed [63:0] bias;
    begin
        prod = a * b;
        bias = prod[63] ? -64'sd8388608 : 64'sd8388608; 
        qmul_q824 = (prod + bias) >>> 24;
    end
    endfunction

    function signed [31:0] qsaturate_exp;
        input signed [31:0] v;
        reg   signed [31:0] QMAX;
        begin
            QMAX = 32'sh7FFFFFFF;
            if (v < 0)           qsaturate_exp = 32'sd0;
            else if (v > QMAX)   qsaturate_exp = QMAX;
            else                 qsaturate_exp = v;
        end
    endfunction

    always @ (*) 
    begin
        sum_r  = ONE_Q24;     
        term_r = x_q824;      
        sum_r  = sum_r + term_r;

        term_r = qmul_q824(qmul_q824(term_r, x_q824), INV2_Q24);
        sum_r  = sum_r + term_r;

        term_r = qmul_q824(qmul_q824(term_r, x_q824), INV3_Q24);
        sum_r  = sum_r + term_r;

        term_r = qmul_q824(qmul_q824(term_r, x_q824), INV4_Q24);
        sum_r  = sum_r + term_r;

        term_r = qmul_q824(qmul_q824(term_r, x_q824), INV5_Q24);
        sum_r  = sum_r + term_r;

        term_r = qmul_q824(qmul_q824(term_r, x_q824), INV6_Q24);
        sum_r  = sum_r + term_r;

        term_r = qmul_q824(qmul_q824(term_r, x_q824), INV7_Q24);
        sum_r  = sum_r + term_r;

        term_r = qmul_q824(qmul_q824(term_r, x_q824), INV8_Q24);
        sum_r  = sum_r + term_r;

        term_r = qmul_q824(qmul_q824(term_r, x_q824), INV9_Q24);
        sum_r  = sum_r + term_r;

        term_r = qmul_q824(qmul_q824(term_r, x_q824), INV10_Q24);
        sum_r  = sum_r + term_r;

        y_q824 = qsaturate_exp(sum_r);
    end
endmodule
