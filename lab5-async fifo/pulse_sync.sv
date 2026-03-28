module pulse_sync1 (
	input logic clka,
	input logic resetb_a,
    input logic clkb,
    input logic resetb_b,
    input logic pulse_in,
    output logic pulse_out
	);

logic sync1;
logic sync2;
logic sync3;


// First synchronizer FF
always_ff @(posedge clkb or negedge resetb_b) begin
    if (~resetb_b)
        sync1 <= 1'b0;
    else
        sync1 <= pulse_in;
end

// Second synchronizer FF
always_ff @(posedge clkb or negedge resetb_b) begin
    if (~resetb_b)
        sync2 <= 1'b0;
    else
        sync2 <= sync1;
end

// Final FF to create b pulse of only 1 cycle
always_ff @(posedge clkb or negedge resetb_b) begin
    if (~resetb_b)
        sync3 <= 1'b0;
    else
        sync3 <= sync2;
end

assign pulse_out = sync2 & ~sync3;


endmodule




module pulse_sync2 (
	input logic clka,
	input logic resetb_a,
    input logic clkb,
    input logic resetb_b,
    input logic pulse_in,
    output logic pulse_out
	);

logic sync1;
logic sync2;
logic sync3;


// Pulse Stretching - counting 3 cycles of clka
//****************************

logic [1:0] count;
logic stretched_signal;

always_ff @(posedge clka or negedge resetb_a) begin
    if (~resetb_a) begin
        count <= 2'b00;
    end else if (pulse_in) begin
        count <= 2'b11; 
    end else if (count > 0) begin
        count <= count - 1'd1; // Count down every cycle
    end
end

// starting the stretched signal while count if up OR from when the pulse starts
assign stretched_signal = (|count) | pulse_in;

//****************************

// First synchronizer FF
always_ff @(posedge clkb or negedge resetb_b) begin
    if (~resetb_b)
        sync1 <= 1'b0;
    else
        sync1 <= stretched_signal;
end

// Second synchronizer FF
always_ff @(posedge clkb or negedge resetb_b) begin
    if (~resetb_b)
        sync2 <= 1'b0;
    else
        sync2 <= sync1;
end

// Final FF to create b pulse of only 1 cycle
always_ff @(posedge clkb or negedge resetb_b) begin
    if (~resetb_b)
        sync3 <= 1'b0;
    else
        sync3 <= sync2;
end

assign pulse_out = sync2 & ~sync3;


endmodule



module pulse_sync3 (
	input logic clka,
	input logic resetb_a,
    input logic clkb,
    input logic resetb_b,
    input logic pulse_in,
    output logic pulse_out
	);


//********clk1 -> clk2 synchronization**********
logic sync1;
logic sync2;
logic sync3;


// First synchronizer FF
always_ff @(posedge clkb or negedge resetb_b) begin
    if (~resetb_b)
        sync1 <= 1'b0;
    else
        sync1 <= entrance;
end

// Second synchronizer FF
always_ff @(posedge clkb or negedge resetb_b) begin
    if (~resetb_b)
        sync2 <= 1'b0;
    else
        sync2 <= sync1;
end

// Final FF to create b pulse of only 1 cycle
always_ff @(posedge clkb or negedge resetb_b) begin
    if (~resetb_b)
        sync3 <= 1'b0;
    else
        sync3 <= sync2;
end

assign pulse_out = sync2 & ~sync3;




//********clk2 -> clk1 feedback synchronization**********
logic feedback1;
logic feedback2;

// First synchronizer FF
always_ff @(posedge clka or negedge resetb_a) begin
    if (~resetb_a)
        feedback1 <= 1'b0;
    else
        feedback1 <= sync2;
end

// Second synchronizer FF
always_ff @(posedge clka or negedge resetb_a) begin
    if (~resetb_a)
        feedback2 <= 1'b0;
    else
        feedback2 <= feedback1;
end


//***************entrance logic**************

logic entrance;
// FF that stays high until confirmation
always_ff @(posedge clka or negedge resetb_a) begin
    if (~resetb_a)
        entrance <= 1'b0;
    else
        entrance <= or_res;
end

assign and_res = ~feedback2 & entrance;
assign or_res = and_res | pulse_in;



endmodule