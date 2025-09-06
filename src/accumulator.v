module accumulator (
    input clk,
    input rst,
    input en,
    input valid_in,
    input [31:0] payoff_in,     // Q8.24 format
    output [31:0] sum_out,      // Accumulated payoff sum
    output [31:0] count_out,     // Integers
    output done
);

    reg [31:0] sum;
    reg [31:0] count;

    always @(posedge clk) 
    begin
        if (rst) 
        begin
            sum <= 32'b0;
            count <= 32'b0;
        end
        else 
        if (en) 
        begin
            if (valid_in) 
            begin
                sum <= sum + payoff_in;
                count <= count + 1;
            end 
        end
        else
        begin
            sum <= 32'b0;
            count <= 32'b0;
        end
    end

    assign sum_out = sum;
    assign count_out = count;
    assign done = (count == 32'b100000) ? 1 : 0; 
endmodule
