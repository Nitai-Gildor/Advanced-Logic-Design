module timing (
    input  logic        clk,       // 512 MHz clock
    input  logic        resetb,    // active-low reset
    input  logic [7:0]  period_sel,     // 1/(2^period_sel)
    output logic        timing     // one-cycle pulse each
);

    // Divider counter  (its the main thing here so we didn't create another module)
    logic [7:0] div_cnt;
    always_ff @(posedge clk or negedge resetb) begin
        if (!resetb) begin
        div_cnt <= 8'd0;
        end
        else if (div_cnt >= period_sel) begin
        div_cnt <= 8'd0;
        end
        else begin
        div_cnt <= div_cnt + 1;
        end
    end

    always_comb
        timing = div_cnt==period_sel;

endmodule

