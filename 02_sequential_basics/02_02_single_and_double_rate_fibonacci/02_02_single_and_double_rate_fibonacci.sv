//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module fibonacci
(
  input               clk,
  input               rst,
  output logic [15:0] num
);

  logic [15:0] num2;

  always_ff @ (posedge clk)
    if (rst)
      { num, num2 } <= { 16'd1, 16'd1 };
    else
      { num, num2 } <= { num2, num + num2 };

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module fibonacci_2
(
  input               clk,
  input               rst,
  output logic [15:0] num,
  output logic [15:0] num2
);

  // Task:
  // Implement a module that generates two fibonacci numbers per cycle
  logic [15:0] n1;   
  logic [15:0] n2;  
  logic [15:0] n3;
  logic [15:0] n4;  

  always_ff @ (posedge clk)
    if (rst)
      { n1, n2, n3 } <= { 16'd1, 16'd1, 16'd2 };
    else begin
      { n1, n2, n3 } <= { n1+n2, n2+n3, n1+n2+n2+n3 };
    end

    assign num = n1;
    assign num2 = n2; 

endmodule
