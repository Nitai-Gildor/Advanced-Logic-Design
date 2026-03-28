module addr_counter (
    input  logic       clk,
    input  logic       resetb,
    input  logic       en,      // timing && (q_cs != IDLE)
    output logic [7:0] cnt_out
);

    always_ff @(posedge clk or negedge resetb) begin
        if (~resetb) begin
            cnt_out <= 8'b0;
        end
        else if (en) begin
            cnt_out <= (cnt_out == 8'd255) ? 8'd0 : cnt_out + 1;
        end
    end
endmodule

