//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module posedge_detector (input clk, rst, a, output detected);

  logic a_r;

  // Note:
  // The a_r flip-flop input value d propogates to the output q
  // only on the next clock cycle.
  logic a_r;
  logic a_r2;  

  always_ff @ (posedge clk)
    begin
      a_r2 <= a_r;
      if (rst)
        a_r <= '0;
      else
        a_r <= a;
    end

  assign detected = a_r & (~ a) & (~ a_r2); 

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


endmodule
