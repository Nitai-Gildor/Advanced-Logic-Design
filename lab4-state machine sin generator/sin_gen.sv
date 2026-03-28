module sin_gen (
    input  logic clk,
    input  logic resetb,
    input  logic en,
    input  logic [7:0] period_sel,
    output logic [8:0] sin_out
    
);

  //------------------------------------------------------------------
  //  Declarations
  //------------------------------------------------------------------
  typedef enum logic [2:0] {
    IDLE = 3'd0,
    Q1 = 3'd1,
    Q2 = 3'd2,
    Q3 = 3'd3,
    Q4 = 3'd4
  } q_fsm;

  // State identifiers
  q_fsm q_cs;
  q_fsm q_ns;

  // Current period_sel
  logic[7:0] current_period_sel;


  // Counter from 0 - 255 for sin_lut
  logic[7:0] counter;
  logic timing;
  logic cnt_enable;

  // Defines the inputs and outputs of sin_lut
  logic [7:0] sin_in;
  logic [8:0] extended_lut_data;
  logic [7:0] lut_data;



  //------------------------------------------------------------------
  //  Code
  //----------------------------------------------------------------

// sin_lut
  always_comb begin
    extended_lut_data = {0, lut_data}; //MSB is 0
    sin_in = (q_cs==Q1||q_cs==Q3) ? counter : (255-counter);
  end
  sin_lut sin_lut_inst(.address(sin_in), .dout(lut_data));


  //  Timing 
  timing timing_inst(.clk(clk), .resetb(resetb), .period_sel(current_period_sel),.timing(timing));

  // Current period selector FF
  always_ff @(posedge clk or negedge resetb)
    if(~resetb)
        current_period_sel <= 8'b0;
    else begin
        if (q_cs == IDLE | (q_cs == Q1 & counter == 0))
            current_period_sel <= period_sel;
    end

assign cnt_enable = timing & q_cs != IDLE;
 addr_counter addr_counter_inst (
        .clk     (clk),
        .resetb  (resetb),
        .en      (cnt_enable), 
        .cnt_out (counter)
    );

  //------------------------------------------------------------------
  //  State Machine
  //------------------------------------------------------------------
  always_ff @(posedge clk or negedge resetb) begin
    if (~resetb)
      q_cs <= IDLE;
    else
      q_cs <= q_ns;
  end

    // State Transitions
  always_comb begin
    case (q_cs)
      IDLE: q_ns = (en==1)? Q1 : IDLE; 
      Q1: q_ns = (counter == 255 && timing ) ? Q2 : Q1;
      Q2: q_ns = (counter == 255 && timing ) ? Q3 : Q2;
      Q3: q_ns = (counter == 255 && timing ) ? Q4 : Q3;
      Q4: q_ns = (counter == 255 && timing) ? ((en==1)? Q1:IDLE) : Q4;
      
      default: q_ns = IDLE;
    endcase
  end

  //------------------------------------------------------------------
  //  Output - Fsm Func
  //------------------------------------------------------------------
  always_comb begin
    case (q_cs)

      IDLE:     sin_out = 9'b0;
      Q1:       sin_out = extended_lut_data;
      Q2:       sin_out = extended_lut_data;
      Q3:       sin_out = -extended_lut_data;
      Q4:       sin_out = -extended_lut_data;
      
      default:  sin_out = 9'b0;
    endcase
  end

endmodule
