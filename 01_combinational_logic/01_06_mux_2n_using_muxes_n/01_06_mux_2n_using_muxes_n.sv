//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module mux_2_1
(
  input  [3:0] d0, d1,
  input        sel,
  output [3:0] y
);

  assign y = sel ? d1 : d0;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module mux_4_1
(
  input  [3:0] d0, d1, d2, d3,
  input  [1:0] sel,
  output [3:0] y
);

  // Task:
  // Implement mux_4_1 using three instances of mux_2_1
  wire [3:0] mux1,mux2;

  mux_2_1 mux_1(d0,d2,sel[1],mux1);
  mux_2_1 mux_2(d1,d3,sel[1],mux2);
  mux_2_1 mux_3(mux1,mux2,sel[0],y); 

endmodule
