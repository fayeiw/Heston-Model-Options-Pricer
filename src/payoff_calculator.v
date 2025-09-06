module payoff_calculator (
    input clk,
    input rst,
    input en,
    input [31:0] S_T,
    input [31:0] K,
    input [1:0] option_type, // 00 = call, 01 = put
    output [31:0] payoff
);
// Calculates max(S_T - K, 0) or max(K - S_T, 0)
    reg [31:0] payoff_int;

    always@(posedge clk)
    begin
        if (rst)
        begin
            payoff_int <= 32'b0;
        end
        else if (en)
        begin
            // Call Option
            if (option_type == 2'b00)
            begin
                if (S_T > K)
                begin
                    payoff_int <= S_T - K;
                end
                else
                begin
                    payoff_int <= 32'b0;
                end
            end
            // Put Option
            else if (option_type == 2'b01)
            begin
                if (K > S_T)
                begin
                    payoff_int <= K - S_T;
                end
                else
                begin
                    payoff_int <= 32'b0;
                end
            end
        end
    end

    assign payoff = payoff_int;
endmodule