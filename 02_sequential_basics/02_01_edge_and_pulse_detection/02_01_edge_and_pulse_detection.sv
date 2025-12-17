//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module posedge_detector (input clk, rst, a, output detected);
  // Note:
  // The a_r flip-flop input value d propogates to the output q
  // only on the next clock cycle.
  logic a_r;

  always_ff @ (posedge clk)
    if (rst)
      a_r <= '0;
    else
      a_r <= a;

  assign detected = ~ a_r & a;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module one_cycle_pulse_detector (input clk, rst, a, output detected);

  // Task:
  // Create an one cycle pulse (010) detector.
  //
  // Note:
  // See the testbench for the output format ($display task).

  //var1.
  // logic a_r, a_r2;  

  // always_ff @ (posedge clk)
  //   begin
  //     if (rst)
  //       begin
  //         a_r <= 0;
  //         a_r2 <= 0;          
  //       end
  //     else 
  //       begin
  //         a_r <= a;        
  //         a_r2 <= a_r;
  //       end;   
  //   end

  // assign detected = ~ a_r2 & a_r & ~ a; 


  // var2. FSM
  typedef enum logic [1:0] {IDLE, ZERO_0, ONE_1, ZERO_2 } state_t;
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
        if (a) state_nx = IDLE;
        else state_nx = ZERO_0;
      ZERO_0: 
        if (a) state_nx = ONE_1;
        else state_nx = ZERO_0;
      ONE_1: 
        if (a) state_nx = IDLE;
        else state_nx = ZERO_2;
      ZERO_2: 
        if (a) state_nx = ONE_1; 
        else state_nx = ZERO_0;
    endcase
  end

  assign detected = state_nx == ZERO_2;


  // var3. slise reg
  // logic [2:0] slice_comp;
  // logic [1:0] slice_f;

  // always_ff @(posedge clk) begin
  //   if (rst) begin
  //     slice_f <= '0;
  //   end
  //   else begin
  //     slice_f<= { slice_f [0], a };
  //   end
  // end

  // assign slice_comp = { slice_f, a }; 
  // assign detected = {slice_comp== 3'b010};

  

endmodule
