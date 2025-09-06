module rng_lfsr_32 (
    input clk,
    input reset,
    input en,
    input [31:0] lfsr,
    output reg [31:0] rand_q8_24
);

    wire feedback;
    
    assign feedback = rand_q8_24[23] ^ rand_q8_24[17] ^ rand_q8_24[5] ^ rand_q8_24[0];

    always@(posedge clk) 
    begin
        if (reset)
        begin
            rand_q8_24 <= lfsr;
        end
        else
        begin
            if (en)
            begin
                rand_q8_24 = (rand_q8_24 ^ (rand_q8_24 >> 13)) ^ ((rand_q8_24 << 7) ^ (rand_q8_24 >> 17));
                rand_q8_24 <= {8'b0, rand_q8_24[22:0], feedback};
            end
        end
    end
endmodule
