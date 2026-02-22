    //----------------------------------------------------------------------------
    // Task
    //----------------------------------------------------------------------------

module formula_1_pipe (
    input clk,
    input rst,

    input        arg_vld,
    input [31:0] a,
    input [31:0] b,
    input [31:0] c,

    output        res_vld,
    output [31:0] res
    );

    // Task:
    //
    // Implement a pipelined module formula_1_pipe that computes the result
    // of the formula defined in the file formula_1_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_1_pipe has to be pipelined.
    //
    // It should be able to accept a new set of arguments a, b and c
    // arriving at every clock cycle.
    //
    // It also should be able to produce a new result every clock cycle
    // with a fixed latency after accepting the arguments.
    //
    // 2. Your solution should instantiate exactly 3 instances
    // of a pipelined isqrt module, which computes the integer square root.
    //
    // 3. Your solution should save dynamic power by properly connecting
    // the valid bits.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

    wire [15:0] a_sqrt, b_sqrt, c_sqrt;
    // logic [31:0] a_trig, b_trig, c_trig;
    wire a_sqrt_vld, b_sqrt_vld, c_sqrt_vld;
    // logic res_abc_vld;
    // logic [31:0] res_abc;

    // always_ff @(posedge clk or posedge rst) begin
    //     if (rst) begin
    //         res_abc <= 31'b0;
    //     end else begin
    //         res_abc <= {16'b0, a_sqrt} + {16'b0, b_sqrt} + {16'b0, c_sqrt};
    //     end
    // end

    // always_ff @(posedge clk or posedge rst) begin
    //     if (rst) begin
    //         res_abc_vld <= 1'b0;
    //     end else begin
    //         res_abc_vld <= a_sqrt_vld & b_sqrt_vld & c_sqrt_vld;
    //     end
    // end

    // always_ff @(posedge clk) begin
    //     if (rst) begin
    //         a_trig <= 0; b_trig <= 0; c_trig <=0;
    //     end else if (arg_vld) begin
    //         a_trig <= a; b_trig <= b; c_trig <= c;
    //     end
    // end

    assign res = rst ? 1'b0 : {16'b0, a_sqrt} + {16'b0, b_sqrt} + {16'b0, c_sqrt};
    assign res_vld = rst ? 1'b0 : a_sqrt_vld & b_sqrt_vld & c_sqrt_vld;

    isqrt #(
        .n_pipe_stages(1)
    ) u_isqrt_a (
        .clk  (clk),
        .rst  (rst),
        .x_vld(arg_vld),
        .x    (a),
        .y_vld(a_sqrt_vld),
        .y    (a_sqrt)
    );

    isqrt #(
        .n_pipe_stages(1)
    ) u_isqrt_b (
        .clk  (clk),
        .rst  (rst),
        .x_vld(arg_vld),
        .x    (b),
        .y_vld(b_sqrt_vld),
        .y    (b_sqrt)
    );

    isqrt #(
        .n_pipe_stages(1)
    ) u_isqrt_c (
        .clk  (clk),
        .rst  (rst),
        .x_vld(arg_vld),
        .x    (c),
        .y_vld(c_sqrt_vld),
        .y    (c_sqrt)
    );

    //   always_comb begin
    //     if (rst) begin
    //       res_vld = 1'b0;
    //     end else begin
    //       res_vld = res_abc_vld;
    //     end
    //   end



    //   always_ff @(posedge clk or posedge rst) begin
    //     if (rst) begin
    //       res <= 32'b0;
    //     end else begin
    //       res <= {16'b0, a_sqrt} + {16'b0, b_sqrt} + {16'b0, c_sqrt};
    //     end
    //   end


endmodule