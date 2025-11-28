//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module serial_comparator_least_significant_first
(
  input  clk,
  input  rst,
  input  a,
  input  b,
  output a_less_b,
  output a_eq_b,
  output a_greater_b
);

  logic prev_a_eq_b, prev_a_less_b;

  assign a_eq_b      = prev_a_eq_b & (a == b);
  assign a_less_b    = (~ a & b) | (a == b & prev_a_less_b);
  assign a_greater_b = (~ a_eq_b) & (~ a_less_b);

  always_ff @ (posedge clk)
    if (rst)
    begin
      prev_a_eq_b   <= '1;
      prev_a_less_b <= '0;
    end
    else
    begin
      prev_a_eq_b   <= a_eq_b;
      prev_a_less_b <= a_less_b;
    end

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_comparator_most_significant_first
(
  input  clk,
  input  rst,
  input  a,
  input  b,
  output logic a_less_b,
  output logic a_eq_b,
  output logic a_greater_b
);

  // Task:
  // Implement a module that compares two numbers in a serial manner.
  // The module inputs a and b are 1-bit digits of the numbers
  // and most significant bits are first.
  // The module outputs a_less_b, a_eq_b, and a_greater_b
  // should indicate whether a is less than, equal to, or greater than b, respectively.
  // The module should also use the clk and rst inputs.
  //
  // See the testbench for the output format ($display task).
  // СЃСЂР°РІРЅРёРІР°РµРј РґРІСѓС…Р±РёС‚РѕРІС‹Рµ С‡РёСЃР»Р°, СЃС‚Р°СЂС€РёР№ Р±РёС‚ С‚РѕС‚, РєРѕС‚РѕСЂС‹Р№ РїСЂРёС€РµР» СЂР°РЅСЊС€Рµ.
  logic prev_a_eq_b, prev_a_less_b, prev_a_greater_b;

  always_comb begin
    if (prev_a_eq_b) 
      begin
        a_eq_b = (a == b);
        a_less_b = (a < b);
        a_greater_b = (a > b);
      end
    else begin
        a_eq_b = 1'b0;
        a_less_b = prev_a_less_b;
        a_greater_b = prev_a_greater_b;
      end
  end

  always_ff @ (posedge clk or posedge rst)
    if (rst)
    begin
      prev_a_eq_b   <= 1'b1;
      prev_a_less_b <= 1'b0;
      prev_a_greater_b <= 1'b0;      
    end
    else
    begin
      prev_a_eq_b   <= a_eq_b;
      prev_a_less_b <= a_less_b;
      prev_a_greater_b <= a_greater_b;          
    end 


  // logic prev_a_eq_b, prev_a_less_b, prev_a_greater_b;

  // always_ff @ (posedge clk or posedge rst)
  //   if (rst)
  //   begin
  //     prev_a_eq_b   <= 1'b1;
  //     prev_a_less_b <= 1'b0;
  //     prev_a_greater_b <= 1'b0;  
  //     a_eq_b          <= 1'b1;
  //     a_less_b        <= 1'b0;
  //     a_greater_b     <= 1'b0;          
  //   end
  //   else
  //   begin
  //     if (prev_a_eq_b) 
  //       begin
  //         a_eq_b <= (a == b);
  //         a_less_b <= (a < b);
  //         a_greater_b <= (a > b);
  //       end
  //     else begin
  //         a_eq_b <= 1'b0;
  //         a_less_b <= prev_a_less_b;
  //         a_greater_b <= prev_a_greater_b;
  //       end

  //     prev_a_eq_b   <= a_eq_b;
  //     prev_a_less_b <= a_less_b;
  //     prev_a_greater_b <= a_greater_b;          
  //   end 





  // always_ff @(posedge clk or posedge rst) begin
  //   logic next_eq, next_less, next_greater;  // Локальные next значения
    
  //   if (rst) begin
  //     prev_a_eq_b   <= 1'b1;
  //     prev_a_less_b <= 1'b0;
  //     prev_a_greater_b <= 1'b0;  
  //     a_eq_b        <= 1'b1;
  //     a_less_b      <= 1'b0;
  //     a_greater_b   <= 1'b0;          
  //   end else begin
  //     // Вычисляем НОВЫЕ значения
  //     if (prev_a_eq_b) begin
  //       next_eq      = (a == b);
  //       next_less    = (a < b);
  //       next_greater = (a > b);
  //     end else begin
  //       next_eq      = 1'b0;
  //       next_less    = prev_a_less_b;
  //       next_greater = prev_a_greater_b;
  //     end
      
  //     // Обновляем выходы и состояние ОДНОВРЕМЕННО
  //     a_eq_b         <= next_eq;
  //     a_less_b       <= next_less;
  //     a_greater_b    <= next_greater;
      
  //     prev_a_eq_b    <= next_eq;
  //     prev_a_less_b  <= next_less;
  //     prev_a_greater_b <= next_greater;
  //   end
  // end


endmodule
