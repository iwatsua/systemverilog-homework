module sqrt_formula_distributor
# (
    parameter formula = 1,
              impl    = 1
)
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output        res_vld,
    output [31:0] res
);

    // Task:
    //
    // Implement a module that will calculate formula 1 or formula 2
    // based on the parameter values. The module must be pipelined.
    // It should be able to accept new triple of arguments a, b, c arriving
    // at every clock cycle.
    //
    // The idea of the task is to implement hardware task distributor,
    // that will accept triplet of the arguments and assign the task
    // of the calculation formula 1 or formula 2 with these arguments
    // to the free FSM-based internal module.
    //
    // The first step to solve the task is to fill 03_04 and 03_05 files.
    //
    // Note 1:
    // Latency of the module "formula_1_isqrt" should be clarified from the corresponding waveform
    // or simply assumed to be equal 50 clock cycles.
    //
    // Note 2:
    // The task assumes idealized distributor (with 50 internal computational blocks),
    // because in practice engineers rarely use more than 10 modules at ones.
    // Usually people use 3-5 blocks and utilize stall in case of high load.
    //
    // Hint:
    // Instantiate sufficient number of "formula_1_impl_1_top", "formula_1_impl_2_top",
    // or "formula_2_top" modules to achieve desired performance.
    localparam CAL_DELAY = (formula == 1 && impl == 1) ? 53 : (formula == 1 && impl == 2) ? 53 : (formula == 2) ? 53 : 0;

    logic [                 31:0] a_array       [0:CAL_DELAY-1];
    logic [                 31:0] b_array       [0:CAL_DELAY-1];
    logic [                 31:0] c_array       [0:CAL_DELAY-1];
    logic [        CAL_DELAY-1:0] arg_vld_array;
    logic [        CAL_DELAY-1:0] res_vld_array;
    logic [                 31:0] res_array     [0:CAL_DELAY-1];
    logic [                 31:0] res_array_temp[0:CAL_DELAY-1];
    logic [$clog2(CAL_DELAY)-1:0] cur_idx;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
        cur_idx <= '0;
        end else begin
        if (arg_vld) begin
            if (cur_idx < CAL_DELAY -1) cur_idx <= cur_idx + 1;
            else cur_idx <= 'b0;
        end
        end
    end

    generate
        genvar i;
        for (i = 0; i < CAL_DELAY; i = i + 1) begin : gen_block
        if (formula == 1 && impl == 1) begin
            formula_1_impl_1_top u_formula_1_impl_1_top (
            .clk    (clk),
            .rst    (rst),
            .arg_vld(arg_vld_array[i]),
            .a      (a_array[i]),
            .b      (b_array[i]),
            .c      (c_array[i]),
            .res_vld(res_vld_array[i]),
            .res    (res_array[i])
            );
        end else if (formula == 1 && impl == 2) begin
            formula_1_impl_2_top u_formula_1_impl_2_top (
            .clk    (clk),
            .rst    (rst),
            .arg_vld(arg_vld_array[i]),
            .a      (a_array[i]),
            .b      (b_array[i]),
            .c      (c_array[i]),
            .res_vld(res_vld_array[i]),
            .res    (res_array[i])
            );
        end else if (formula == 2 && impl == 1) begin
            formula_2_top u_formula_2_top (
            .clk    (clk),
            .rst    (rst),
            .arg_vld(arg_vld_array[i]),
            .a      (a_array[i]),
            .b      (b_array[i]),
            .c      (c_array[i]),
            .res_vld(res_vld_array[i]),
            .res    (res_array[i])
            );
        end
        end
    endgenerate


    generate
        genvar j;
        for (j = 0; j < CAL_DELAY; j = j + 1) begin : gen_input
        always_ff @(posedge clk or posedge rst) begin
            if (rst) begin
                a_array[j]       <= 32'b0;
                b_array[j]       <= 32'b0;
                c_array[j]       <= 32'b0;
                arg_vld_array[j] <= 1'b0;
            end else begin
            if (arg_vld && cur_idx == j) begin
                a_array[j]       <= a;
                b_array[j]       <= b;
                c_array[j]       <= c;
                arg_vld_array[j] <= 1'b1;
            end else begin
                arg_vld_array[j] <= 1'b0;
            end
            end
        end
        end
    endgenerate

    generate
        genvar k;
        for (k = 0; k < CAL_DELAY; k = k + 1) begin : gen_output
        assign res_array_temp[k] = res_array[k] & {32{res_vld_array[k]}};
        end
    endgenerate

    assign res_vld = |res_vld_array;
    always_comb begin
        res = '0;  // Результат инициализации равен нулю.
        for (int l = 0; l < CAL_DELAY; l++) begin
        res |= res_array_temp[l];  // Побитовая операция ИЛИ
        end
    end



endmodule
