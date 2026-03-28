`timescale 1ns / 1ps
module sync_bridge_tb;

    // Parameters and Signals
    logic clka, clkb, resetb_clkb;
    logic [7:0] din_clka, dout_clkb;
    logic data_valid_clka, data_valid_clkb;
    logic data_req_clka, data_req_clkb;

    // Expected data queue for the checker
    integer expected_queue[$];

    // Clock Generation
    initial clka = 0;
    always #6.25ns clka = ~clka; 

    initial clkb = 0;
    always #10ns clkb = ~clkb;  

    initial begin
        data_valid_clka = 1'b0;
        din_clka = 8'h00;
    end
    // DUT Instantiation
    sync_bridge DUT (
        .clka(clka),
        .data_valid_clka(data_valid_clka),
        .din_clka(din_clka),
        .resetb_clkb(resetb_clkb),
        .clkb(clkb),
        .data_req_clkb(data_req_clkb),
        .data_req_clka(data_req_clka),
        .data_valid_clkb(data_valid_clkb),
        .dout_clkb(dout_clkb)
    );

    // Driver B (Mimic Block B)
    initial begin
        resetb_clkb = 0;
        data_req_clkb = 0;
        #50 resetb_clkb = 1;

        repeat(5) @(posedge clkb);
        // Send one cycle req
        data_req_clkb <= 1'b1;
        @(posedge clkb);
        data_req_clkb <= 1'b0;
    end

    // Driver A 
    always @(posedge clka) begin
        if (~resetb_clkb) begin
            data_valid_clka <= 0;
            din_clka <= 0;
        end else if (data_req_clka) begin
            // Generate 20 random numbers 
            repeat(20) begin
                @(posedge clka);
                data_valid_clka <= 1'b1;
                din_clka <= $urandom_range(0, 255);
                expected_queue.push_back(din_clka);
            end
            @(posedge clka);
            data_valid_clka <= 1'b0;
        end
    end
    int count = 0;
    // Monitor & Checker 
    logic [7:0] popped_data;
    initial begin
        forever begin
            @(posedge clkb);
            if (resetb_clkb) begin 
                if (expected_queue.size() > 0 && data_valid_clkb) begin
                    
                    // Checker
                    popped_data = expected_queue.pop_front();
                    if (dout_clkb !== popped_data)
                        $error("Mismatch at %t! Expected %h, Got %h", $time, popped_data, dout_clkb);
                    else
                        $display("Match: %h at %t", dout_clkb, $time);
                    count = count + 1;
                    if (count >= 20)begin
                        #10ns
                        $finish;
                    end
                end 
            end
        end
    end

endmodule