//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module add
(
  input  [3:0] a, b,
  output [3:0] sum
);

  assign sum = a + b;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module signed_add_with_saturation
(
  input  [3:0] a, b,
  output [3:0] sum
);

  // Task:
  //
  // Implement a module that adds two signed numbers with saturation.
  //
  // "Adding with saturation" means:
  //
  // When the result does not fit into 4 bits,
  // and the arguments are positive,
  // the sum should be set to the maximum positive number.
  //
  // When the result does not fit into 4 bits,
  // and the arguments are negative,
  // the sum should be set to the minimum negative number.

  // 1. Диапазон 4-бит signed two's complement
  localparam [3:0] MAX_POS = 4'd7;   // 0111 = +7
  localparam [3:0] MIN_NEG = 4'd8;   // 1000 = -8
  
  // 2. Сумма с guard bit
  wire [4:0] full_sum = {a[3], a} + {b[3], b};
  
  // 3. Overflow детекция
  wire overflow = full_sum[4] ^ full_sum[3];
  
  // 4. Saturation логика
  assign sum = overflow ? 
               (a[3] == b[3] ? 
                 (a[3] ? MIN_NEG : MAX_POS) :  // оба neg → -8, оба pos → +7
                 full_sum[3:0]) :              // разные знаки → обычная сумма
               full_sum[3:0];

//   0100   (+4)
// + 0111   (+7)
// -------
// 1 1011   (+11, carry=1)
// -------
//  1011   (-5 в 4 битах!)

endmodule
