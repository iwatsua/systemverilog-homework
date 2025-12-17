//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module serial_comparator_least_significant_first_using_fsm
(
  input  clk,
  input  rst,
  input  a,
  input  b,
  output a_less_b,
  output a_eq_b,
  output a_greater_b
);

  // States
  enum logic[2:0]
  {
     st_a_less_b    = 3'b100,
     st_equal       = 3'b010,
     st_a_greater_b = 3'b001
  }
  state, new_state;

  // State transition logic
  always_comb
  begin
    new_state = state;

    // This lint warning is bogus because we assign the default value above
    // verilator lint_off CASEINCOMPLETE

    case (state)
      st_equal       : if (~ a &   b) new_state = st_a_less_b;
                  else if (  a & ~ b) new_state = st_a_greater_b;
      st_a_less_b    : if (  a & ~ b) new_state = st_a_greater_b;
      st_a_greater_b : if (~ a &   b) new_state = st_a_less_b;
    endcase

    // verilator lint_on  CASEINCOMPLETE
  end

  // Output logic
  assign { a_less_b, a_eq_b, a_greater_b } = new_state;

  always_ff @ (posedge clk)
    if (rst)
      state <= st_equal;
    else
      state <= new_state;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_comparator_most_significant_first_using_fsm
(
  input  clk,
  input  rst,
  input  a,
  input  b,
  output a_less_b,
  output a_eq_b,
  output a_greater_b
);

  // Task:
  // Implement a serial comparator module similar to the previus exercise
  // but use the Finite State Machine to evaluate the result.
  // Most significant bits arrive first.
  // States

  // var1
  // enum logic[2:0]
  // {
  //    st_a_less_b    = 3'b100,
  //    st_equal       = 3'b010,
  //    st_a_greater_b = 3'b001 
  // }
  // state, new_state;

  // // State transition logic
  // always_comb
  // begin
  //   new_state = state;

  //   case (state)
  //     st_equal       : if (~ a &   b) new_state = st_a_less_b;
  //                 else if (  a & ~ b) new_state = st_a_greater_b;
  //     st_a_less_b    : new_state = st_a_less_b;
  //     st_a_greater_b : new_state = st_a_greater_b;
  //   endcase
  // end

  // // Output logic
  // assign { a_less_b, a_eq_b, a_greater_b } = new_state;

  // always_ff @ (posedge clk)
  //   if (rst)
  //     state <= st_equal;
  //   else
  //     state <= new_state;


  //var2
  typedef enum logic [1:0] {IDLE, EQUAL, LESS, GREATER } state_t;
  state_t state_nx, state_ff;
  
  always_ff @(posedge clk) begin
    if (rst) begin
      state_ff <= IDLE;
    end
    else begin
      state_ff <= state_nx;
    end
  end
  
  always_comb begin : comp
    case (state_ff)
      IDLE: begin
        if (a & ~b) state_nx = GREATER; 
        else if (~a & b) state_nx = LESS; 
        else state_nx = EQUAL;
      end

      EQUAL: begin
        if (a & ~b) state_nx = GREATER; 
        else if (~a & b) state_nx = LESS; 
        else state_nx = EQUAL;
      end

      GREATER: 
        state_nx = GREATER;

      LESS: 
        state_nx = LESS;
    endcase
  end

  assign a_less_b  = state_nx == LESS; 
  assign a_eq_b = state_nx == EQUAL;
  assign a_greater_b = state_nx == GREATER;

endmodule
