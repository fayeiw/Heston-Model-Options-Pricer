module path_generator (
    input clk,
    input rst,
    input en,
    input signed [31:0] seed1,            
    input signed [31:0] seed2,
    output signed [31:0] z1_out,        // correlated Q8.24 FP number
    output signed [31:0] z2_out         // correlated Q8.24 FP number
);
    localparam NEG_TWO = 32'hFE000000;
    localparam TWO_PI  = 32'h6487ED5;

    wire signed [63:0] mag_sq_prev;
    reg  signed [31:0] mag_squared;
    wire signed [63:0] angle_prev;
    reg  signed [31:0] angle;
    wire signed [63:0] z1_prev;
    reg  signed [31:0] z1;
    wire signed [63:0] z2_prev;
    reg  signed [31:0] z2;

    wire [31:0] sqrt_term;
    wire signed [31:0] ln_term;
    wire signed [31:0] cos_term;
    wire signed [31:0] sin_term;

    // rng_lfsr_32 rng_mod_one (
    //     .clk(clk),
    //     .en(en),
    //     .lfsr(in_seed1),
    //     .rand_q8_24(seed1)
    // );

    // rng_lfsr_32 rng_mod_two (
    //     .clk(clk),
    //     .rst(rst),
    //     .en(en),
    //     .lfsr(in_seed2),
    //     .rand_q8_24(seed2)
    // );

    sqrt_q824 sqrt_mod (
        .x(mag_squared),
        .sqrt_out(sqrt_term)
    );

    ln_taylor_q824 ln_mod (
        .x(seed1),
        .ln1p_out(ln_term)
    );

    cos_taylor_q824 cos_mod (
        .x(angle),
        .cos_out(cos_term)
    );

    sin_taylor_q824 sin_mod (
        .x(angle),
        .sin_out(sin_term)
    );

    assign mag_sq_prev = NEG_TWO * ln_term;
    assign angle_prev  = (TWO_PI * seed2);
    assign z1_prev = sqrt_term * cos_term;
    assign z2_prev = sqrt_term * sin_term;
    
    assign z1_out = z1;
    assign z2_out = z2;

    always @ (posedge clk)
    begin
        if (rst)
        begin
            mag_squared <= 32'sb0;
            angle       <= 32'sb0;
            z1          <= 32'sb0;
            z2          <= 32'sb0;
        end
        else if (en)
        begin
            mag_squared <= mag_sq_prev >> 24;
            angle       <= angle_prev >> 24;
            z1          <= z1_prev >> 24;
            z2          <= z2_prev >> 24;
        end
    end

endmodule