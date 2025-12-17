//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module double_tokens
(
    input        clk,
    input        rst,
    input        a,
    output       b,
    output logic overflow
);
    // Task:
    // Implement a serial module that doubles each incoming token '1' two times.
    // The module should handle doubling for at least 200 tokens '1' arriving in a row.
    //
    // In case module detects more than 200 sequential tokens '1', it should assert
    // an overflow error. The overflow error should be sticky. Once the error is on,
    // the only way to clear it is by using the "rst" reset signal.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 10010011000110100001100100
    // b -> 11011011110111111001111110

    // FSM
    typedef enum logic [1:0] {IDLE, ONE_0, ONE_1 } state_t;
    state_t state_ff, state_nx;

    always_ff @(posedge clk) begin
    if (rst)
      state_ff <= IDLE;    
    else
      state_ff <= state_nx;
    end

    always_comb begin
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
