// SUCCESSFUL

// Directed testbench for sim_engine_ctrl: tests reset, load transition, output hold, and verifies all state outputs by forcing state
`timescale 1ns/1ps
module tb_sim_engine_ctrl;
    reg        clk, rst, load;
    wire [4:0] mc_output_ctrl;
    wire       done;

    sim_engine_ctrl dut (
        .clk(clk),
        .rst(rst),
        .load(load),
        .mc_output_ctrl(mc_output_ctrl),
        .done(done)
    );

    initial 
    begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial 
    begin
        // 1) Reset behavior: state=0 → mc_output_ctrl=00000, done=1
        rst = 1; load = 0;
        #20;
        rst = 0; #10;
        if (mc_output_ctrl !== 5'b00000 || done !== 1)
            $error("After reset: mc_output_ctrl=%b done=%b (expected 00000,1)", mc_output_ctrl, done);

        // 2) Apply load pulse: transition to state1 → mc_output_ctrl=00001, done=0
        load = 1; #10;
        load = 0; #10;
        if (mc_output_ctrl !== 5'b00001 || done !== 0)
            $error("After load: mc_output_ctrl=%b done=%b (expected 00001,0)", mc_output_ctrl, done);

        // 3) Hold behavior in state1: outputs remain constant when load toggles
        load = 1; #10; load = 0; #10;
        if (mc_output_ctrl !== 5'b00001 || done !== 0)
            $error("Hold in state1 failed: mc_output_ctrl=%b done=%b", mc_output_ctrl, done);

        // 4) Verify outputs for states 2–5 by forcing internal state
        force dut.state = 3'd2; #10;
        if (mc_output_ctrl !== 5'b00011 || done !== 0)
            $error("State2 output wrong: mc_output_ctrl=%b done=%b", mc_output_ctrl, done);

        force dut.state = 3'd3; #10;
        if (mc_output_ctrl !== 5'b00111 || done !== 0)
            $error("State3 output wrong: mc_output_ctrl=%b done=%b", mc_output_ctrl, done);

        force dut.state = 3'd4; #10;
        if (mc_output_ctrl !== 5'b01111 || done !== 0)
            $error("State4 output wrong: mc_output_ctrl=%b done=%b", mc_output_ctrl, done);

        force dut.state = 3'd5; #10;
        if (mc_output_ctrl !== 5'b11111 || done !== 0)
            $error("State5 output wrong: mc_output_ctrl=%b done=%b", mc_output_ctrl, done);

        release dut.state;

        $display("tb_sim_engine_ctrl: All directed tests passed");
        $finish;
    end
endmodule
