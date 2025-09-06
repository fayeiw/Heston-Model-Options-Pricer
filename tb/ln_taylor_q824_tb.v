// SUCCESSFUL

`timescale 1ns/1ps

module tb_ln_taylor_q824;
  localparam int SCALE = 1 << 24;
  logic  signed [31:0] x_q;
  logic  signed [31:0] one_plus_x_q;
  wire   signed [31:0] y_q;

  ln1p_taylor_q824 dut (
    .x        (x_q),
    .ln1p_out (y_q)
  );

  function real q824_to_real (int signed q);
    q824_to_real = q / real'(SCALE);
  endfunction


  real test_vals [0:9] = '{
    0.0,        // ln(1.0)
    0.1,        // ln(1.1)
    0.365,      // ln(1.365)
    0.5,        // ln(1.5)
    0.9,        // ln(1.9)
    1.0         // ln(2.0)
  };

  initial begin
    $display("x (float)      x_q824           y_q824           y (float)");
    $display("---------------------------------------------------------------");

    foreach (test_vals[i]) begin
      one_plus_x_q = $rtoi(test_vals[i] * SCALE);
      x_q        = one_plus_x_q - 32'h01000000;
      #1ns;
      $display("%0.6f   %0d   %0d   (%0.8f)",
               test_vals[i],
               x_q,
               y_q,
               q824_to_real(y_q));
    end
    $finish;
  end
endmodule
