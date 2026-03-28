`timescale 1ns/1ps
module sin_gen_tb ();

logic [7:0] period_sel;
logic [8:0] sin_out;  
logic en;
logic clk;
logic resetb;


// DUT (Device Under Test)
sin_gen sin_gen (
    .clk(clk),
    .resetb(resetb),
    .en(en),
    .period_sel(period_sel),
    .sin_out(sin_out)
);

//clk
always begin
    #0.97656ns;   // aproxx 512 MHz
    clk=~clk;
end

// Test flow
initial 
    begin
        {en, period_sel, clk} = 0; // initialize default value
        resetb = 0;
        #20;
        resetb = 1;
        en = 1;
        #10ns;
        period_sel = 1;
        #2100ns;
        period_sel = 0;

    end



endmodule