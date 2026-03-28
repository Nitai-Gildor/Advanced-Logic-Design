module bin2gray #(parameter WIDTH=4) (
    input  [WIDTH-1:0] bin,
    output [WIDTH-1:0] gray
);
    assign gray = bin ^ (bin >> 1);
endmodule

module grey2bin #(parameter WIDTH=4) (
    input  [WIDTH-1:0] gray,
    output reg [WIDTH-1:0] bin
);
    integer i; 
    always_comb begin 
        bin[WIDTH-1] = gray[WIDTH-1]; 
        for (i = WIDTH-2; i >= 0; i = i - 1) begin
            bin[i] = gray[i] ^ bin[i+1];
        end
    end
endmodule
