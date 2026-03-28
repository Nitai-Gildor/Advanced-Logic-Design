module asynchronous_fifo (
	input logic clka,
    input logic clkb,
    input logic resetb_clka,
    input logic resetb_clkb,
    input logic [7:0] din_clka,
    input logic write_clka,
    input logic read_clkb,
    output logic full_clka,
    output logic empty_clkb,
    output logic [7:0] dout_clkb
	);


// 16 data registers of size 8 bit
logic [7:0] fifo [15:0];

// Read write enables that also check empty/full
logic write_en_clka;
logic read_en_clkb;

// Grey read write pointers
logic [3:0] wr_ptr_grey_clka;
logic [3:0] rd_ptr_grey_clkb;

// Binary read write pointers
logic [3:0] wr_ptr_bin_clka; // For decoder and adder
logic [3:0] rd_ptr_bin_clkb; // For demux and adder

// After synchronizer logics
logic [3:0] wr_ptr_grey_clkb; // Write after synchronizer
logic [3:0] rd_ptr_grey_clka;

// After synchronizer and changed to bin
logic [3:0] wr_ptr_bin_clkb;
logic [3:0] rd_ptr_bin_clka;

// Used for next val calculations
logic [3:0] wr_ptr_grey_next;
logic [3:0] rd_ptr_grey_next;
// ------------------------------------------------------
// grey2bin converters
//most left
grey2bin #(4) wr_grey_bin_clka(
    .gray(wr_ptr_grey_clka),
    .bin(wr_ptr_bin_clka)
);

//
grey2bin #(4) rd_grey_bin_clkb(
    .gray(rd_ptr_grey_clkb),
    .bin(rd_ptr_bin_clkb)
);

//mid right
grey2bin #(4) wr_grey_bin_clkb(
    .gray(wr_ptr_grey_clkb),
    .bin(wr_ptr_bin_clkb)
);

grey2bin #(4) rd_grey_bin_clka(
    .gray(rd_ptr_grey_clka),
    .bin(rd_ptr_bin_clka)
);

// bin2gray converters (for the value of the main pointers)
bin2gray #(4) b2g_wr (
    .bin(wr_ptr_bin_clka + 1'b1),
    .gray(wr_ptr_grey_next)
);

bin2gray #(4) b2g_rd (
    .bin(rd_ptr_bin_clkb + 1'b1),
    .gray(rd_ptr_grey_next)
);

// Write Pointer FF
always_ff @(posedge clka or negedge resetb_clka) begin
    if (~resetb_clka)
        wr_ptr_grey_clka <= 4'b0000;
    else if (write_en_clka)
        wr_ptr_grey_clka <= wr_ptr_grey_next;
end

// Read Pointer FF
always_ff @(posedge clkb or negedge resetb_clkb) begin
    if (~resetb_clkb)
        rd_ptr_grey_clkb <= 4'b1000; //start from "end" 1000
    else if (read_en_clkb)
        rd_ptr_grey_clkb <= rd_ptr_grey_next;
end
// ------------------------------------------------------
// FIFO FF writing
always_ff @ (posedge clka or negedge resetb_clka) begin
    if (~resetb_clka) begin
        for (int i = 0; i < 16; i++) begin
            fifo[i] <= 8'b0;
        end
    end else if (write_en_clka) begin
        fifo[wr_ptr_bin_clka] <= din_clka;
    end
end

// FIFO read (mux)
assign dout_clkb = fifo[rd_ptr_bin_clkb];


// ------------------------------------------------------
// Synchronizers
// Write a to b synchronizer
dff_sync #(4) wr_a2b(
    .clk(clkb),
    .resetb(resetb_clkb),
    .d(wr_ptr_grey_clka),
    .q(wr_ptr_grey_clkb)
);

// read b to a synchronizer
dff_sync #(4) rd_b2a(
    .clk(clka),
    .resetb(resetb_clka),
    .d(rd_ptr_grey_clkb),
    .q(rd_ptr_grey_clka)
);

// Outputs
always_comb begin
    full_clka = (wr_ptr_bin_clka + 1'b1 == rd_ptr_bin_clka);
    empty_clkb = (rd_ptr_bin_clkb + 1'b1 == wr_ptr_bin_clkb); 
end

//Enables
always_comb begin
    write_en_clka = write_clka & ~full_clka;
    read_en_clkb = read_clkb & ~empty_clkb;
end


endmodule