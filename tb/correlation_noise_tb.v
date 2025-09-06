// SUCCESSFUL

`timescale 1ns/1ps
module tb_correlated_noise;

  reg clk;
  reg rst, en;
  reg  signed [31:0] z1, z2, rho;
  reg         [31:0] dt;
  wire signed [31:0] dw1, dw2;

  localparam signed [31:0] ONE_Q824 = 32'h0100_0000;

  correlated_noise dut (
    .clk(clk), .rst(rst), .en(en),
    .z1(z1), .z2(z2), .rho(rho), .dt(dt),
    .dw1(dw1), .dw2(dw2)
  );

  wire signed [31:0] sqrt_dt_q;
  sqrt_q824 ref_sqrt_dt (.a(dt), .sqrt_out(sqrt_dt_q));

  wire signed [63:0] rho_sq_wide;
  wire        [31:0] rho_sq_q;
  wire        [31:0] one_minus_rho_sq_q;
  assign rho_sq_wide       = $signed(rho) * $signed(rho);
  assign rho_sq_q          = rho_sq_wide[55:24];
  assign one_minus_rho_sq_q= ONE_Q824 - rho_sq_q;

  wire signed [31:0] sqrt_1m_rho2_q;
  sqrt_q824 ref_sqrt_y (.a(one_minus_rho_sq_q), .sqrt_out(sqrt_1m_rho2_q));

  function automatic signed [31:0] exp_dw1(
      input signed [31:0] z1_q, input signed [31:0] sqrt_dt);
    reg signed [63:0] p;
    begin
      p = $signed(z1_q) * $signed(sqrt_dt);
      exp_dw1 = p[55:24];
    end
  endfunction

  function automatic signed [31:0] exp_dw2(
      input signed [31:0] rho_q,
      input signed [31:0] dw1_int,
      input signed [31:0] sqrt1mrho2_q,
      input signed [31:0] z2_q,
      input signed [31:0] sqrt_dt);
    reg signed [63:0] a64, b64, c64;
    reg signed [31:0] a32, b32, c32;
    begin
      a64 = $signed(rho_q) * $signed(dw1_int);
      a32 = a64[55:24];
      b64 = $signed(sqrt1mrho2_q) * $signed(z2_q);
      b32 = b64[55:24];
      c64 = $signed(b32) * $signed(sqrt_dt);
      c32 = c64[55:24];
      exp_dw2 = a32 + c32;
    end
  endfunction

  integer tol;
  integer i;
  real z1_r, z2_r, rho_r, dt_r;
  reg  signed [31:0] dw1e, dw2e;
  reg  signed [31:0] dw1_hold, dw2_hold;
  integer d1, d2;

  task automatic check_close(input [127:0] name, input signed [31:0] got, input signed [31:0] exp);
    integer d;
    begin
      d = (got>exp)?(got-exp):(exp-got);
      if (d > tol) $error("%s mismatch: got=%0d exp=%0d diff=%0d > tol", name, got, exp, d);
      else         $display("%s OK: got=%0d exp=%0d diff=%0d", name, got, exp, d);
    end
  endtask

  function automatic signed [31:0] q824_from_real(input real r);
    begin
      q824_from_real = $rtoi(r * (1<<24));
    end
  endfunction

  initial begin
    clk = 0;
  end
  always #5 clk = ~clk;

  initial begin
    tol = 2000;
    rst=1; en=0; z1=0; z2=0; rho=0; dt=0;
    repeat(2) @(posedge clk);
    rst=0; @(posedge clk);
    if (dw1!==0 || dw2!==0) $error("Reset failed");

    for (i=0; i<10; i=i+1) begin
      z1_r  = ($urandom_range(-4000,4000))/1000.0;
      z2_r  = ($urandom_range(-4000,4000))/1000.0;
      rho_r = ($urandom_range(-950, 950))/1000.0;
      dt_r  = ($urandom_range(10,1000))/1000.0;

      z1 = q824_from_real(z1_r);
      z2 = q824_from_real(z2_r);
      rho= q824_from_real(rho_r);
      dt = q824_from_real(dt_r);

      en = 1; 
      @(posedge clk);
      #1;

      dw1e = exp_dw1(z1, sqrt_dt_q);
      dw2e = exp_dw2(rho, dw1e, sqrt_1m_rho2_q, z2, sqrt_dt_q);

      check_close({"T",i," dw1"}, dw1, dw1e);
      check_close({"T",i," dw2"}, dw2, dw2e);

      dw1_hold = dw1; dw2_hold = dw2;
      z1 = q824_from_real(z1_r + 0.5);
      z2 = q824_from_real(z2_r - 0.5);
      rho= q824_from_real(rho_r * 0.5);
      dt = q824_from_real(dt_r  * 0.7);
      @(posedge clk);
      if (dw1!==dw1_hold || dw2!==dw2_hold) $error({"T",i,": hold failed"});
    end

    $display("correlated_noise TB: 10 checks done.");
    $finish;
  end

endmodule
