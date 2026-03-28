module n_counter (
    input logic clk,
    input logic resetb,
    input logic en,
    input logic reset_cnt, // synchronic reset
    output logic [3:0] n // maximum n can be is as 8 bit u and v size.
);
    always_ff @(posedge clk or negedge resetb)
    if(~resetb)
        n <= 4'b0;
    else begin
        if(reset_cnt)
            n<=4'b0;
        else
        if (en)
            n<=(n==4'b1000)?n : n+1; // not possible in design, but still, for not creating overload
    end

endmodule