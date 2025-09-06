module correlated_noise (
    input clk,
    input rst,
    input en,
    input signed [31:0] z1, // Q8.24
    input signed [31:0] z2, // Q8.24
    input signed [31:0] rho,
    input [31:0] dt,
    output reg signed [31:0] dw1,
    output reg signed [31:0] dw2
);
    localparam ONE = 32'd16777216;

    wire signed [63:0] dw1_int_prev;
    wire signed [63:0] dw2_int_prev;
    wire signed [31:0] one_minus_rho_sq;
    wire signed [63:0] rho_sq_prev;
    wire signed [31:0] rho_sq;
    wire signed [31:0] dw1_int;
    wire signed [31:0] dw2_int;
    wire signed [63:0] dw2_int_a_prev;
    wire signed [31:0] dw2_int_a;
    wire signed [63:0] dw2_int_b_prev; 
    wire signed [31:0] dw2_int_b;
    wire signed [63:0] dw2_int_c_prev;
    wire signed [31:0] dw2_int_c;

    wire signed [31:0] sqrt_term_x;
    wire signed [31:0] sqrt_term_y;


    sqrt_q824 sqrt_inst_x(
        .a(dt),
        .sqrt_out(sqrt_term_x)
    );

    sqrt_q824 sqrt_inst_y(
        .a(one_minus_rho_sq),
        .sqrt_out(sqrt_term_y)
    );

    assign rho_sq_prev = rho * rho;
    assign rho_sq = rho_sq_prev >> 24;
    assign one_minus_rho_sq = ONE - rho_sq;
    assign dw1_int_prev = z1 * sqrt_term_x;
    assign dw1_int = dw1_int_prev >> 24;
    assign dw2_int_a_prev = (rho * dw1_int);
    assign dw2_int_a =  dw2_int_a_prev >> 24;
    assign dw2_int_b_prev = sqrt_term_y * z2; 
    assign dw2_int_b = dw2_int_b_prev >> 24;
    assign dw2_int_c_prev = dw2_int_b * sqrt_term_x;
    assign dw2_int_c = dw2_int_c_prev >> 24;
    assign dw2_int = dw2_int_a + dw2_int_c;

    always @ (posedge clk)
    begin
        if (rst)
        begin
            dw1 <= 32'sb0;
            dw2 <= 32'sb0;
        end
        else if (en)
        begin
            dw1 <= dw1_int;
            dw2 <= dw2_int;
        end
    end
endmodule
