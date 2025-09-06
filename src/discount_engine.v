// module discount_engine (
//     input signed [31:0] sum,
//     input signed [31:0] count,
//     input signed [31:0] r,
//     input signed [31:0] T,
//     output signed [31:0] price_out
// );
//     wire signed [31:0] minus_r_mult_t;
//     wire signed [63:0] minus_r_mult_t_full;
//     wire signed [31:0] exp_term;
//     wire signed [31:0] div;
//     wire signed [63:0] price_out_full;

//     exp_taylor_q824 exp_inst(
//         .x(minus_r_mult_t), 
//         .exp_out(exp_term)
//     );

//     div_q824 div_inst(
//         .numerator(sum), 
//         .denominator(count), 
//         .quotient(div)
//     );

//     assign minus_r_mult_t_full = - (r * T);
//     assign minus_r_mult_t = minus_r_mult_t_full >>> 24;
//     assign price_out_full = exp_term * div;
//     assign price_out = price_out_full >>> 24;

// endmodule

//============================CLOCKED==========================//
module discount_engine (
    input clk,
    input rst,
    input en,
    input signed [31:0] sum,
    input signed [31:0] count,
    input signed [31:0] r,
    input signed [31:0] T,
    output reg signed [31:0] price_out
);

    wire signed [63:0] minus_r_mult_t_full;
    reg signed [31:0] minus_r_mult_t;
    wire signed [31:0] exp_term;
    wire signed [31:0] div;
    wire signed [63:0] price_out_full;

    exp_taylor_q824 exp_inst (
        .x_q824(minus_r_mult_t), 
        .y_q824(exp_term)
    );

    div_q824 div_inst (
        .a(sum), 
        .b(count), 
        .q(div)
    );

    always @(posedge clk) 
    begin
        if (rst) 
        begin
            price_out <= 32'sb0;
        end 
        else
        begin
            if (en)  
            begin
                price_out <= price_out_full >>> 24;
            end
        end
    end

    assign minus_r_mult_t_full = - (r * T);
    assign minus_r_mult_t = minus_r_mult_t_full >>> 24;
    assign price_out_full = exp_term * div;

endmodule
