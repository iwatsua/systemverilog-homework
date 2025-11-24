//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_impl_2_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_1_x_vld,
    output logic [31:0] isqrt_1_x,

    input               isqrt_1_y_vld,
    input        [15:0] isqrt_1_y,

    output logic        isqrt_2_x_vld,
    output logic [31:0] isqrt_2_x,

    input               isqrt_2_y_vld,
    input        [15:0] isqrt_2_y
);

    // Task:
    // Implement a module that calculates the formula from the `formula_1_fn.svh` file
    // using two instances of the isqrt module in parallel.
    //
    // Design the FSM to calculate an answer and provide the correct `res` value
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm
    //
    //Необходимо ознакомиться с формулой в файле formula_1_fn.svh и примером конечного автомата для последовательного 
    //вычисления этой формулы в файле formula_1_impl_1_fsm.sv или formula_1_impl_1_fsm_style_2.sv.
    //Задание: В файле formula_1_impl_2_fsm.sv, имплементировать вычисление Формулы 1 используя два модуля isqrt одновременно. 
    //Необходимо вычислить два из трёх значений параллельно. Далее, вычислить оставшееся значение и предоставить результат суммы.


endmodule
