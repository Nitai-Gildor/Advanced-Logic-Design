`timescale 1ns/1ns
module gcd_tb ();

logic [7:0] u;
logic [7:0] v;
logic [7:0] res;  
logic done;
logic clk;
logic resetb;
logic ld;
int counter;

// DUT (Device Under Test)
gcd gcd_ins (
    .clk(clk),
    .resetb(resetb),
    .u(u),
    .v(v),
    .ld(ld),
    .done(done),
    .res(res)
);
//clk
always begin
    #5ns;
    clk=~clk;
end



// Generator
function automatic void randomize_inputs();
    u = $urandom();
    v = $urandom();
    while (u==0 || v==0) begin
        u = $urandom();
        v = $urandom();        
    end
endfunction

// Driver
task sync();
    @(posedge clk);
    #1;
endtask

task automatic drive_inputs();
    sync;
    randomize_inputs();
    ld = 1;
    sync;
    ld=0;
    wait(done == 1);
    #1; // dealy for checker
endtask

initial
    begin
        {u,v,clk} = 0;
        counter = 0; //for print
        resetb =1;
        #1ns;
        resetb = 0; 
        #20ns;
        resetb=1;
        repeat(100)
        begin
            counter++;
            drive_inputs();
        end
        $stop();
    end


// Golden model
function automatic logic [7:0] golden_model(logic [7:0] u, logic [7:0] v);
        if (u < v)
            golden_model = golden_model(v, u);

        else if(v == 0)
            golden_model = u;
            
        else
            golden_model = golden_model(v,u%v);
		
endfunction 


// Checker
function automatic void check_gcd(logic [7:0] u, logic [7:0] v, logic [7:0] res);
    logic [7:0] exp_result;

    exp_result = golden_model(u,v);

    $display("%d. GCD(%d, %d) = %d \n",counter, u, v, res);

    if (exp_result != res)
        $error("checker failed: exp_result=%d", exp_result);
endfunction


// Monitor
initial
    begin
        wait(resetb==0);
        wait(resetb==1);
        forever
            begin
                @(posedge done);
                #0;
                check_gcd(u, v, res);
            end
    end




endmodule
