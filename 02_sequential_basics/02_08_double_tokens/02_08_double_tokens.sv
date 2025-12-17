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


  reg [7:0] cnt;
  logic res;
  always_ff @(posedge clk) begin
    if (rst) begin
      cnt <= 0;
      overflow <= '0;
      res <= '0; 
    end
    else if (a) begin
      cnt <= cnt + 1;
      if (cnt >= 200) overflow <= '1;
      res <= '1;       
    end
    else if (cnt) begin
      cnt <= cnt - 1;
      res <= '1; 
    end
    else
      res <= '0;     
  end

  assign b = res;


  // logic [7:0] a_cnt;
  // always_ff @(posedge clk) begin
  //   if (rst) {a_cnt, overflow} <= {'1, '0};
  //   else if (a_cnt >= 200) overflow <= '1;
  //   else if (a) begin
  //     a_cnt <= a_cnt + 1;
  //   end
  // end

  // logic [7:0] cnt;
  // logic res;
  // always_ff @(posedge clk) begin
  //   if (rst) {cnt, res} <= {'0, '0};
  //   else if (a) {cnt, res} <= {cnt + '1, '1};
  //   else if (cnt) {cnt, res} <= {cnt - '1, '1};
  //   else res <= '0;
  // end

  // assign b = res & (~overflow);

endmodule
