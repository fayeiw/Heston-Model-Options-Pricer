`timescale 1ns/1ps
module tb_sde_solver;

  reg clk, rst, en;
  reg  signed [31:0] S_in, v_in, dW1, dW2, dt, r, kappa, theta, sigma;
  wire signed [31:0] S_out, v_out;

  sde_solver dut (
    .clk(clk), .rst(rst), .en(en),
    .S_in(S_in), .v_in(v_in), .dW1(dW1), .dW2(dW2),
    .dt(dt), .r(r), .kappa(kappa), .theta(theta), .sigma(sigma),
    .S_out(S_out), .v_out(v_out)
  );

  initial begin clk=0; forever #5 clk=~clk; end

  function automatic real rand_frac24;
    int u;
    begin
      u = $urandom_range(0,(1<<24)-1);
      rand_frac24 = u / real'(1<<24);
    end
  endfunction

  function automatic signed [31:0] q824(input real x);
    begin
      q824 = $rtoi(x * (1<<24));
    end
  endfunction

  wire signed [31:0] sqrt_v_q;
  sqrt_q824 ref_sqrt (.a(v_in), .sqrt_out(sqrt_v_q));

  function automatic signed [31:0] exp_ds(
      input signed [31:0] r_q, input signed [31:0] S_q,
      input signed [31:0] sqrtv_q, input signed [31:0] dW1_q, input signed [31:0] dt_q);
    reg signed [63:0] t0, t1, t2, t3;
    reg signed [31:0] a, b;
    begin
      t0 = r_q * S_q;      a = t0[55:24];
      t1 = a   * dt_q;     a = t1[55:24];
      t2 = sqrtv_q * S_q;  b = t2[55:24];
      t3 = b * dW1_q;      b = t3[55:24];
      exp_ds = a + b;
    end
  endfunction

  function automatic signed [31:0] exp_dv(
      input signed [31:0] kappa_q, input signed [31:0] theta_q, input signed [31:0] v_q,
      input signed [31:0] sigma_q, input signed [31:0] sqrtv_q, input signed [31:0] dW2_q, input signed [31:0] dt_q);
    reg signed [31:0] vdiff;
    reg signed [63:0] t0, t1, t2, t3;
    reg signed [31:0] a, b;
    begin
      vdiff = theta_q - v_q;
      t0 = kappa_q * vdiff; a = t0[55:24];
      t1 = a * dt_q;        a = t1[55:24];
      t2 = sigma_q * sqrtv_q; b = t2[55:24];
      t3 = b * dW2_q;         b = t3[55:24];
      exp_dv = a + b;
    end
  endfunction

  integer i, tol, diffS, diffV;
  real S_r, v_r, dW1_r, dW2_r, dt_r, r_r, kappa_r, theta_r, sigma_r;
  reg signed [31:0] ds_e, dv_e, S_e, V_e;

  initial begin
    tol = 200;
    rst=1; en=0; S_in=0; v_in=0; dW1=0; dW2=0; dt=0; r=0; kappa=0; theta=0; sigma=0;
    repeat(3) @(posedge clk);
    rst=0; @(posedge clk);

    for (i=0;i<10;i=i+1) begin
      S_r     = 1.0 + $urandom_range(0,99) + rand_frac24; if (S_r>127.99) S_r=127.99;
      v_r     = 0.1 + $urandom_range(0,9)  + rand_frac24; if (v_r>127.99) v_r=127.99;
      dt_r    = 0.001 + ($urandom_range(1,9))/1000.0;
      dW1_r   = ($urandom_range(-250,250))/1000.0;
      dW2_r   = ($urandom_range(-250,250))/1000.0;
      r_r     = ($urandom_range(-100,100))/10000.0;
      kappa_r = 0.1 + ($urandom_range(0,290))/100.0;
      theta_r = 0.1 + ($urandom_range(0,190))/100.0;
      sigma_r = 0.1 + ($urandom_range(0,190))/100.0;

      S_in    = q824(S_r);
      v_in    = q824(v_r);
      dt      = q824(dt_r);
      dW1     = q824(dW1_r);
      dW2     = q824(dW2_r);
      r       = q824(r_r);
      kappa   = q824(kappa_r);
      theta   = q824(theta_r);
      sigma   = q824(sigma_r);

      en=1; @(posedge clk); en=0; @(posedge clk);

      ds_e = exp_ds(r, S_in, sqrt_v_q, dW1, dt);
      dv_e = exp_dv(kappa, theta, v_in, sigma, sqrt_v_q, dW2, dt);
      S_e  = S_in + ds_e;
      V_e  = v_in + dv_e;

      diffS = (S_out>S_e) ? (S_out-S_e) : (S_e-S_out);
      diffV = (v_out>V_e) ? (v_out-V_e) : (V_e-v_out);

      if (diffS > tol) $error("Test %0d S_out: got %0d exp %0d diff %0d > tol", i, S_out, S_e, diffS);
      else $display("S OK");

      if (diffV > tol) $error("Test %0d v_out: got %0d exp %0d diff %0d > tol", i, v_out, V_e, diffV);
      else $display("V OK");
    end

    $display("All sde_solver tests done.");
    $finish;
  end

endmodule
