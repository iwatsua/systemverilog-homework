d:
cd\mprojects\altera_max2\verify\systemverilog-homework-main\systemverilog-homework-main\03_finite_state_machines\03_04_sqrt_formula_fsms
path=c:\iverilog\bin
iverilog -o qqq formula_1_impl_1_fsm.sv testbenches\formula_tb.sv
vvp qqq
path=c:\iverilog\gtkwave\bin
gtkwave out.vcd
pause
del qqq
del out.vcd