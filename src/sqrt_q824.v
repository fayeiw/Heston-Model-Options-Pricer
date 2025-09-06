module sqrt_q824 (
    input  wire signed [31:0] a,        // Q8.24
    output wire signed [31:0] sqrt_out  // Q8.24
);

    wire a_nonpos = (a <= 32'sd0);
    wire signed [31:0] y0_raw = a >>> 1;
    wire signed [31:0] y0     = (y0_raw == 32'sd0) ? 32'sd1 : y0_raw;

    function automatic [31:0] nz_divisor;
        input signed [31:0] y;
        begin
            nz_divisor = (y == 32'sd0) ? 32'sd1 : y;
        end
    endfunction

    wire signed [31:0] div0_q;
    div_q824 div0 (.a(a), .b(nz_divisor(y0)), .q(div0_q));
    wire signed [31:0] y1 = (y0 + div0_q + 32'sd1) >>> 1;  

    wire signed [31:0] div1_q;
    div_q824 div1 (.a(a), .b(nz_divisor(y1)), .q(div1_q));
    wire signed [31:0] y2 = (y1 + div1_q + 32'sd1) >>> 1;

    wire signed [31:0] div2_q;
    div_q824 div2 (.a(a), .b(nz_divisor(y2)), .q(div2_q));
    wire signed [31:0] y3 = (y2 + div2_q + 32'sd1) >>> 1;

    wire signed [31:0] div3_q;
    div_q824 div3 (.a(a), .b(nz_divisor(y3)), .q(div3_q));
    wire signed [31:0] y4 = (y3 + div3_q + 32'sd1) >>> 1;

    wire signed [31:0] div4_q;
    div_q824 div4 (.a(a), .b(nz_divisor(y4)), .q(div4_q));
    wire signed [31:0] y5 = (y4 + div4_q + 32'sd1) >>> 1;

    wire signed [31:0] div5_q;
    div_q824 div5 (.a(a), .b(nz_divisor(y5)), .q(div5_q));
    wire signed [31:0] y6 = (y5 + div5_q + 32'sd1) >>> 1;

    assign sqrt_out = a_nonpos ? 32'sd0 : y6;
endmodule
