`timescale 1ns/1ns
module power_on_tb ();

    logic resetb;
    logic clk;
    logic power_good;
    logic enable;

    // DUT
    power_on power_on_ins (
        .clk        (clk),
        .resetb     (resetb),
        .power_good (power_good),
        .enable     (enable)
    );

    // test structure
    initial begin
        resetb      = 0;
        power_good  = 1;   // high while in reset test: should not enable
        #405ns;

        resetb      = 1;
        power_good  = 0;   // Should not count up for 400ns
        #400ns;

        // power_good high only 250ns. Enable stays low
        power_good  = 1;
        #250ns;
        power_good  = 0;
        #250ns;

        // power_good high 400ns. Enable must go high at 300ns until 410ns
        power_good  = 1;
        #400ns;
        power_good  = 0;
        #100ns;

        $display("=== TEST DONE ===");
        $stop;
    end

    // Rising edge checker
    always @(posedge power_good) begin : check_enable_delay
        time t_pg_rise;           // declare first
        t_pg_rise = $time;        // then assign
        $display("\nPOSEDGE CHECK: power_good rose at %0t ns", t_pg_rise);

        fork
            // check after 290 ns of powergood == 1 that enable is still down
            begin
                #290ns;
                if (enable !== 1'b0)
                    $error("enable is already 1 at 290ns after power_good!");
                else
                    $display("PASS: enable is 0 at 290ns after posedge");
            end

            // wait until enable rises and measure the delay
            begin
                time delay;
                wait(enable == 1'b1);
                delay = $time - t_pg_rise;
                $display("enable rose at %0t ns (delay = %0t ns)", $time, delay);
                if (delay < 300)
                    $error("ERROR: enable rose TOO EARLY (<300ns)");
                else
                    $display("PASS: enable delay == 300ns");
            end

            // enable stayed on after 450ns
            begin
                #450ns;
                $display(" at %0t ns (450ns after power_good): enable = %0b",
                         $time, enable);
            end
        join
    end

    // Falling edge checker
    always @(negedge power_good) begin
        $display("\nNEGEDGE CHECK: power_good fell at %0t ns", $time);
        #11ns; //wait after drop before check
        if (enable !== 1'b0)
            $error("ERROR: enable did not drop after power_good went low");
        else
            $display("PASS: enable is 0 after power_good went low (1 cycle 10ns delay)");
    end

    // 100 MHz clock
    initial clk = 0;
    always begin
        #5ns;
        clk = ~clk;
    end

endmodule
