`timescale 1ns / 1ps

module async_fifo_solo_tb;
    // Signals matching your FIFO ports exactly
    logic clka, clkb;
    logic resetb_clka, resetb_clkb;
    logic [7:0] din_clka, dout_clkb;
    logic write_clka, read_clkb;
    logic full_clka, empty_clkb;

    integer expected_queue[$];

    // Clock Generation
    initial begin clka = 0; clkb = 0; end
    always #6.25ns clka = ~clka; 
    always #10ns clkb = ~clkb;  

    // --- MANUAL BINDING (No Wildcards) ---
    asynchronous_fifo DUT (
        .clka        (clka),
        .clkb        (clkb),
        .resetb_clka (resetb_clka),
        .resetb_clkb (resetb_clkb),
        .din_clka    (din_clka),
        .write_clka  (write_clka),
        .read_clkb   (read_clkb),
        .full_clka   (full_clka),
        .empty_clkb  (empty_clkb),
        .dout_clkb   (dout_clkb)
    );

    // Write Driver
    initial begin
        // Initialize everything to 0 at time 0 to avoid HiZ
        resetb_clka = 0; write_clka = 0; din_clka = 0;
        #30 resetb_clka = 1;
        repeat(5) @(posedge clka);

        for (int i = 0; i < 10; i++) begin
            @(posedge clka);
            if (!full_clka) begin
                write_clka <= 1;
                din_clka <= 8'hA0 + i;
                expected_queue.push_back(8'hA0 + i);
            end
        end
        @(posedge clka);
        write_clka <= 0;
    end

    // Read Driver
    initial begin
        resetb_clkb = 0; read_clkb = 0;
        #30 resetb_clkb = 1;
        wait (expected_queue.size() > 0);
        repeat(15) @(posedge clkb); 

        while (!empty_clkb) begin
            @(posedge clkb);
            read_clkb <= 1;
        end
        @(posedge clkb);
        read_clkb <= 0;
    end

    // Monitor
    always @(posedge clkb) begin
        if (resetb_clkb && read_clkb && !empty_clkb) begin
            if (expected_queue.size() > 0) begin
                automatic logic [7:0] exp = expected_queue.pop_front();
                #1ps; // Offset to sample after the edge
                if (dout_clkb !== exp)
                    $display("Mismatch! Exp: %h, Got: %h", exp, dout_clkb);
                else
                    $display("Match: %h", dout_clkb);
            end
        end
    end
endmodule