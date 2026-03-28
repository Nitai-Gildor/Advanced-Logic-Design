module sync_bridge (
	input logic clka,
	input logic data_valid_clka,
    input logic [7:0]din_clka,
    input logic resetb_clkb,
    input logic clkb,
    input logic data_req_clkb,
    output logic data_req_clka,
    output logic data_valid_clkb,
    output logic [7:0] dout_clkb
	);

logic full_clka;
logic empty_clkb;
logic read_clkb;
logic resetb_clka;
logic after_sync;
logic posedge_sup;

// asynchronus fifo in the center of the system
asynchronous_fifo main_fifo(
    .clka(clka),
    .clkb(clkb),
    .resetb_clka(resetb_clka),
    .resetb_clkb(resetb_clkb),
    .din_clka(din_clka),
    .write_clka(data_valid_clka),
    .read_clkb(read_clkb),
    .full_clka(full_clka),
    .empty_clkb(empty_clkb),
    .dout_clkb(dout_clkb)
);



assign read_clkb = 1'b1;



// DFF_SYNCHRONIZER for the data request from b to a
dff_sync #(1) reset_sync(
    .clk(clka),
    .resetb(resetb_clkb),
    .d(1'b1),
    .q(resetb_clka)
);


// DFF_SYNCHRONIZER for data_req sync
dff_sync #(1) data_req_sync(
    .clk(clka),
    .resetb(resetb_clka),
    .d(data_req_clkb),
    .q(after_sync)
);

// Final FF to create b pulse of only 1 cycle
always_ff @(posedge clka or negedge resetb_clka) begin
    if (~resetb_clka)
        posedge_sup <= 1'b0;
    else
        posedge_sup <= after_sync;
end

assign data_req_clka = after_sync & ~posedge_sup;

assign data_valid_clkb = ~empty_clkb;

endmodule
