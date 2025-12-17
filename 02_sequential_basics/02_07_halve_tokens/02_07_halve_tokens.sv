//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module halve_tokens
(
    input  clk,
    input  rst,
    input  a,
    output b
);
    // Task:
    // Implement a serial module that reduces amount of incoming '1' tokens by half.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 110_011_101_000_1111
    // b -> 010_001_001_000_0101

    // reg [1:0] state, new_state;  // Счетчик накопленных '1'


  // FSM
  typedef enum logic [1:0] {IDLE, ONE_0, ONE_1 } state_t;
  state_t state_ff, state_nx;
  
  always_ff @(posedge clk) begin
    if (rst)
      state_ff <= IDLE;    
    else
      state_ff <= state_nx;
  end

  always_comb begin // 01010 
    case (state_ff)
      IDLE: 
        if (a) state_nx = ONE_0;
        else state_nx = IDLE;
      ONE_0: 
        if (a) state_nx = ONE_1;
        else state_nx = ONE_0;
      ONE_1: 
        if (a) state_nx = ONE_0;
        else state_nx = IDLE;
    endcase
  end

  assign b = state_nx == ONE_1;


endmodule
