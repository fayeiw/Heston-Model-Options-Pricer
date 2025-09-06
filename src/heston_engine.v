module heston_engine(
    input  clk,                       
    input  rst, 
    input  start,

    // Simulation parameters (all Q8.24 fixed-point format)
    input  [31:0] S0,                 // Initial asset price (8.24fp)
    input  [31:0] v0,                 // Initial variance (8.24fp)
    input  [31:0] r,                  // Risk-free interest rate (8.24fp)
    input  [31:0] kappa,              // Mean reversion speed (8.24fp)
    input  [31:0] theta,              // Long-run variance (8.24fp)
    input  [31:0] sigma,              // Volatility of variance (8.24fp)
    input  [31:0] rho,                // Correlation between W1 and W2 (8.24fp)
    input  [31:0] T,                  // Time to maturity (8.24fp)
    input  [31:0] dt,                 // Time step size (8.24fp)
    input  [31:0] K,                  // Strike price (8.24fp)
    input  [31:0] in_seed1, 
    input  [31:0] in_seed2,          

    // Control
    input  [1:0] option_type,         // 00 = Call, 01 = Put

    // Outputs
    output [31:0] option_price,       // Output option price (8.24fp)
    output        done                // High when computation is complete                     
);
    wire signed [31:0] s;
    wire signed [31:0] v;

    reg [31:0] z1_out_reg;
    reg [31:0] z2_out_reg;
    reg [31:0] dw1_reg;
    reg [31:0] dw2_reg;
    reg [31:0] seed1_reg;
    reg [31:0] seed2_reg;
    reg [31:0] Sout_reg;
    reg [31:0] payoff_reg;
    reg [31:0] sum_out_reg;
    reg [31:0] count_out_reg;
    reg [4:0] mc_ctrl_reg;
    reg start_reg;

    wire [31:0] z1_out_wire;
    wire [31:0] z2_out_wire;
    wire [31:0] dw1_wire;
    wire [31:0] dw2_wire;
    wire [31:0] seed1_wire;
    wire [31:0] seed2_wire;
    wire [31:0] Sout_wire;
    wire [31:0] Vout_wire;
    wire [31:0] payoff_wire;
    wire [31:0] sum_out_wire;
    wire [31:0] count_out_wire;
    wire [4:0] mc_ctrl_wire;
    wire start_wire;

    assign s = (done == 1'b1) ? Sout_wire : S0;
    assign v = (done == 1'b1) ? Vout_wire : v0;

    rng_lfsr_32 rng_mod_one (
        .clk(clk),
        .lfsr(in_seed1),
        .rand_q8_24(seed1_wire)
    );

    rng_lfsr_32 rng_mod_two (
        .clk(clk),
        .lfsr(in_seed2),
        .rand_q8_24(seed2_wire)
    );

    path_generator path_gen_mod(
        .clk(clk),
        .rst(rst),
        .en(mc_ctrl_reg[0]),
        .in_seed1(seed1_reg),
        .in_seed2(seed2_reg),
        .z1_out(z1_out_wire),
        .z2_out(z2_out_wire)
    );

    correlated_noise corr_noise_mod(
        .clk(clk),
        .rst(rst),
        .en(mc_ctrl_reg[1]),
        .z1(z1_out_reg),
        .z2(z2_out_reg),
        .rho(rho),
        .dt(dt),
        .dw1(dw1_wire),
        .dw2(dw2_wire)
    );

    sde_solver sde_mod(
        .clk(clk),
        .rst(rst),
        .en(mc_ctrl_reg[2]),
        .S_in(s),     
        .v_in(v),     
        .dW1(dw1_reg),      
        .dW2(dw2_reg),      
        .dt(dt),       
        .r(r),        
        .kappa(kappa),    
        .theta(theta),    
        .sigma(sigma),    
        .S_out(Sout_wire), 
        .v_out(Vout_wire)
    );

    payoff_calculator payoff_mod(
        .clk(clk),
        .rst(rst),
        .en(mc_ctrl_reg[3]),
        .S_T(Sout_reg),
        .K(K),
        .option_type(option_type), 
        .payoff(payoff_wire)
    );

    accumulator accumulator_mod(
        .clk(clk),
        .rst(rst),
        .en(mc_ctrl_reg[4]),
        .valid_in(1'b1),
        .payoff_in(payoff_reg),     
        .sum_out(sum_out_wire),      
        .count_out(count_out_wire),
        .done(start_wire)     
    );

    discount_engine discount_mod(
        .clk(clk),
        .rst(rst),
        .en(start_reg),
        .sum(sum_out_reg),
        .count(count_out_reg),
        .r(r),
        .T(T),
        .price_out(option_price)
    );

    sim_engine_ctrl ctrl(
        .clk(clk),
        .rst(rst),
        .load(start),
        .mc_output_ctrl(mc_ctrl_wire),
        .done(done)
    );

    always @(posedge clk) 
    begin
        if (rst) 
        begin
            z1_out_reg     <= 32'd0;
            z2_out_reg     <= 32'd0;
            dw1_reg        <= 32'd0;
            dw2_reg        <= 32'd0;
            seed1_reg      <= 32'd0;
            seed2_reg      <= 32'd0;
            Sout_reg       <= 32'd0;
            payoff_reg     <= 32'd0;
            sum_out_reg    <= 32'd0;
            count_out_reg  <= 32'd0;
            mc_ctrl_reg    <= 5'd0;
            start_reg      <= 1'b0;
        end 
        else 
        begin
            z1_out_reg     <= z1_out_wire;
            z2_out_reg     <= z2_out_wire;
            dw1_reg        <= dw1_wire;
            dw2_reg        <= dw2_wire;
            seed1_reg      <= seed1_wire;
            seed2_reg      <= seed2_wire;
            Sout_reg       <= Sout_wire;
            payoff_reg     <= payoff_wire;
            sum_out_reg    <= sum_out_wire;
            count_out_reg  <= count_out_wire;
            mc_ctrl_reg    <= mc_ctrl_wire;
            start_reg      <= start_wire;
        end
    end
endmodule