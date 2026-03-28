module gcd (
    input logic clk,
    input logic resetb,
    input logic [7:0] u,
    input logic [7:0] v,
    input logic ld,
    output logic done,
    output logic [7:0] res
);

logic [1:0] op_u, op_v;
logic [7:0] ff_u, ff_v; 
logic op_u_big;  // u>v
logic reset_cnt, en; // for n counter
logic [3:0] n; 
logic [7:0] ff_u_input, ff_v_input;
logic [7:0] sub_res;


//controller
always_comb begin
    op_u_big = ff_u>ff_v;
    done = ff_u==ff_v;
    reset_cnt = 0;
    en = 0;
    op_v = 2'b00;
    op_u = 2'b00;

    if(ld) begin
        op_u = 2'b11;
        op_v = 2'b11;
        reset_cnt = 1;
    end
    else begin

        if (ff_u[0]==0 & ff_v[0]==0) begin // v and u even
            op_u = 2'b10;
            op_v = 2'b10;
            en = 1;
        end

        
        else if (ff_u[0]!=ff_v[0])
                if (ff_u[0]) begin //only v is even
                    op_u = 2'b00;
                    op_v = 2'b10;
                end
                else begin // only u is even
                    op_u = 2'b10;
                    op_v = 2'b00;
                end

            else begin // u and v not even
                if (op_u_big) begin //u>v
                    op_u = 2'b01;
                    op_v = 2'b00;
                end
                else begin // v>u
                    op_u = 2'b00;
                    op_v = 2'b01;
                end 
            end
    end

end


// Flipflop for U
always_ff @ (posedge clk or negedge resetb) begin
    if(~resetb)
        ff_u <= 8'b0;
    else
        ff_u <= ff_u_input;
end

// Flipflop for V
always_ff @ (posedge clk or negedge resetb) begin
    if(~resetb)
        ff_v <= 8'b0;
    else
        ff_v <= ff_v_input;
end


//sub res mux
assign sub_res = (op_u_big)? ff_u-ff_v : ff_v-ff_u; 

// muxes that enters to ff_u, ff_v
always_comb begin
    case(op_u)
    2'b00: ff_u_input = ff_u;
    2'b01: ff_u_input = sub_res;
    2'b10: ff_u_input = ff_u>>1;
    2'b11: ff_u_input = u;
    default: ff_u_input = ff_u;
    endcase

    case(op_v)
    2'b00: ff_v_input = ff_v;
    2'b01: ff_v_input = sub_res;
    2'b10: ff_v_input = ff_v>>1;
    2'b11: ff_v_input = v;
    default: ff_v_input = ff_v;
    endcase
end

 //result
assign res = (done)? ff_u<<n : 8'b0; 

//n_counter
n_counter n_counter(.clk(clk), .resetb(resetb), .en(en), .reset_cnt(reset_cnt), .n(n));
endmodule