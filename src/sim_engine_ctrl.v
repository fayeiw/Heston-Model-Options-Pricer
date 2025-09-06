module sim_engine_ctrl(
    input clk,
    input rst,
    input load,
    output reg [4:0] mc_output_ctrl,
    output reg done
);
    reg [2:0] state, next_state;
    reg [16:0] counter;

    // Next State Logic
    always@(*)
    begin
        if (state == 3'd0)
        begin
            if (load == 1)
            begin
                next_state = 3'd1;
            end
            else
            begin
                next_state = 3'd0;
            end
        end
        else if (state == 3'd1)
        begin
            next_state = 3'd1;
        end
        else if (state == 3'd2)
        begin
            next_state = 3'd2;
        end
        else if (state == 3'd3)
        begin
            next_state = 3'd3;
        end
        else if (state == 3'd4)
        begin
            next_state = 3'd4;
        end
        else if (state == 3'd5)
        begin
            if (counter == 17'd100_000)
            begin
                next_state = 3'd6;
            end
            else
            begin
                next_state = 3'd5;
            end
        end
        else if (state = 3'd6)
        begin
            next_state = 3'd0;
        end
    end


    // State Register
    always @ (posedge clk)
    begin
        if (rst)
        begin
            state <= 3'b0;
            counter <= 17'b0;
        end
        else
        begin
            state <= next_state;
            if (state == 3'd5)
            begin
                counter <= counter + 1'b1;
            end
        end
    end

    // Output Logic
    always @ (*)
    begin
        if (state == 3'd0)
        begin
            mc_output_ctrl = 5'b00000;
            done = 1'b0;
        end
        else if (state == 3'd1)
        begin
            mc_output_ctrl = 5'b00001;
            done = 1'b0;
        end
        else if (state == 3'd2)
        begin
            mc_output_ctrl = 5'b00011;
            done = 1'b0;
        end
        else if (state == 3'd3)
        begin
            mc_output_ctrl = 5'b00111;
            done = 1'b0;
        end
        else if (state == 3'd4)
        begin
            mc_output_ctrl = 5'b01111;
            done = 1'b0;
        end
        else if (state == 3'd5)
        begin
            mc_output_ctrl = 5'b11111;
            done = 1'b0;
        end
        else if (state = 3'd6)
        begin
            mc_output_ctrl = 5'b00000;
            done = 1'b1;
        end
    end
endmodule

