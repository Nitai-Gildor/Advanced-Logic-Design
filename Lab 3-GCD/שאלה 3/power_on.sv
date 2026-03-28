module power_on (
	input logic clk,
	input logic resetb,
    input logic power_good,
    output logic enable
	);

//number of "successful" flops counter
logic [5:0] counter;
logic power_good_d;   // registered version of power_good
assign enable = (counter >= 30) ? 1'b1 : 1'b0;


// FF to create power_good delay
always_ff @(posedge clk or negedge resetb) begin
    if (~resetb)
        power_good_d <= 1'b0;
    else
        power_good_d <= power_good;
end

// Counter FF
always_ff @ (posedge clk or negedge resetb) 
begin
    if(~resetb)
        counter <= 6'b0;
    else begin
        if(power_good_d)
            counter <= counter + 1'b1;
        else
            counter <= 6'b0;
    end
        
end

endmodule