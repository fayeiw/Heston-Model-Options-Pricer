module sde_solver (
    input clk,
    input rst,
    input en,
    input signed [31:0] S_in,     // Stock price S(t) in Q8.24
    input signed [31:0] v_in,     // Variance v(t) in Q8.24
    input signed [31:0] dW1,      // Wiener increment 1 in Q8.24
    input signed [31:0] dW2,      // Wiener increment 2 in Q8.24
    input signed [31:0] dt,       // Timestep in Q8.24
    input signed [31:0] r,        // Risk-free rate in Q8.24
    input signed [31:0] kappa,    // Mean reversion speed in Q8.24
    input signed [31:0] theta,    // Long-term variance in Q8.24
    input signed [31:0] sigma,    // Volatility of variance in Q8.24
    output reg signed [31:0] S_out, // Updated stock price
    output reg signed [31:0] v_out  // Updated variance
);


    wire signed [63:0] ds_rS_prev;
    wire signed [31:0] ds_rS;
    wire signed [63:0] ds_rSdt_prev;
    wire signed [31:0] ds_rSdt;
    wire signed [63:0] ds_sqrtS_prev;
    wire signed [31:0] ds_sqrtS;
    wire signed [63:0] ds_sqrtS_dW1_prev;
    wire signed [31:0] ds_sqrtS_dW1;
    wire signed [31:0] ds;

    wire signed [31:0] v_diff;
    wire signed [63:0] dv_kappa_prev;
    wire signed [31:0] dv_kappa;
    wire signed [63:0] dv_drift_prev;
    wire signed [31:0] dv_drift;
    wire signed [63:0] dv_sigma_sqrt_prev;
    wire signed [31:0] dv_sigma_sqrt;
    wire signed [63:0] dv_sigma_sqrt_dW2_prev;
    wire signed [31:0] dv_sigma_sqrt_dW2;
    wire signed [31:0] dv;

    wire signed [31:0] sqrt_term;


    sqrt_q824 sqrt_inst_x (
        .a(v_in),          
        .sqrt_out(sqrt_term)    
    );

    assign ds_rS_prev        = r * S_in;
    assign ds_rS             = ds_rS_prev >>> 24;
    assign ds_rSdt_prev      = ds_rS * dt;
    assign ds_rSdt           = ds_rSdt_prev >>> 24;
    assign ds_sqrtS_prev     = sqrt_term * S_in;
    assign ds_sqrtS          = ds_sqrtS_prev >>> 24;
    assign ds_sqrtS_dW1_prev = ds_sqrtS * dW1;
    assign ds_sqrtS_dW1      = ds_sqrtS_dW1_prev >>> 24;
    assign ds = ds_rSdt + ds_sqrtS_dW1;

    assign v_diff                 = theta - v_in;
    assign dv_kappa_prev          = kappa * v_diff;
    assign dv_kappa               = dv_kappa_prev >>> 24;
    assign dv_drift_prev          = dv_kappa * dt;
    assign dv_drift               = dv_drift_prev >>> 24;
    assign dv_sigma_sqrt_prev     = sigma * sqrt_term;
    assign dv_sigma_sqrt          = dv_sigma_sqrt_prev >>> 24;
    assign dv_sigma_sqrt_dW2_prev = dv_sigma_sqrt * dW2;
    assign dv_sigma_sqrt_dW2      = dv_sigma_sqrt_dW2_prev >>> 24;
    assign dv = dv_drift + dv_sigma_sqrt_dW2;

    always @(posedge clk) 
    begin
        if (rst) 
        begin
            v_out <= 0;
            S_out <= 0;
        end 
        else
        begin
            if (en)
            begin
                v_out <= v_in + dv;
                S_out <= S_in + ds;
            end
        end 
    end
endmodule
