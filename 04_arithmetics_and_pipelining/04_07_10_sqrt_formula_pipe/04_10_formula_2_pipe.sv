//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe
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
    // Implement a pipelined module formula_2_pipe that computes the result
    // of the formula defined in the file formula_2_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_2_pipe has to be pipelined.
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
    localparam N_PIP_STAGES = 16;

    logic sqrt_1_x_vld, sqrt_2_x_vld, sqrt_3_x_vld;
    logic sqrt_1_y_vld, sqrt_2_y_vld, sqrt_3_y_vld;
    logic [15:0] sqrt_1_y, sqrt_2_y, sqrt_3_y;
    logic [31:0] sqrt_1_x, sqrt_2_x, sqrt_3_x;

    logic [31:0] b_array[N_PIP_STAGES-1:0];
    logic [31:0] a_array[2*N_PIP_STAGES:0];
    logic [31:0] b_array_last, a_array_last;


    assign b_array_last = b_array[N_PIP_STAGES-1];
    assign a_array_last = a_array[2*N_PIP_STAGES];    

    // shift registers for pipelining
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < 2 * N_PIP_STAGES + 1; i++) begin
                a_array[i] <= 32'b0;
            end
        end else begin
            if (arg_vld) begin
                a_array[0] <= a;
            end

            for (int i = 1; i < 2 * N_PIP_STAGES + 1; i++) begin
                a_array[i] <= a_array[i-1];
            end
        end
    end
  
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
        for (int i = 0; i < N_PIP_STAGES; i++) begin
            b_array[i] <= 32'b0;
        end
        end else begin
        if (arg_vld) begin
            b_array[0] <= b;
        end
        for (int i = 1; i < N_PIP_STAGES; i++) begin
            b_array[i] <= b_array[i-1];
        end
        end
    end

    // calculate  sqrt 1 input 
    assign sqrt_1_x     = c;
    assign sqrt_1_x_vld = arg_vld;

    // calculate the sqrt 2 input
    always_ff @(posedge clk or rst) begin
        if (rst) begin
            sqrt_2_x <= 0;
        end else begin
        if (sqrt_1_y_vld) 
            sqrt_2_x <= {16'b0, sqrt_1_y} + b_array[N_PIP_STAGES-1];
        end
    end    

    always_ff @(posedge clk or rst) begin
        if (rst) begin
            sqrt_2_x_vld <= 0;
        end else begin
            sqrt_2_x_vld <= sqrt_1_y_vld;
        end
    end

    //calculate the sqrt 3 input
    always_ff @(posedge clk or rst) begin
        if (rst) begin
            sqrt_3_x <= 0;
        end else begin
            if (sqrt_2_y_vld) 
                sqrt_3_x <= {16'b0, sqrt_2_y} + a_array[2*N_PIP_STAGES];
        end
    end

    always_ff @(posedge clk or rst) begin
        if (rst) begin
        sqrt_3_x_vld <= 0;
        end else begin
        sqrt_3_x_vld <= sqrt_2_y_vld;
        end
    end

    assign res_vld = sqrt_3_y_vld;
    assign res     = {16'b0, sqrt_3_y};

    isqrt #(
        .n_pipe_stages(N_PIP_STAGES)
    ) u_isqrt_1 (
        .clk  (clk),
        .rst  (rst),
        .x_vld(sqrt_1_x_vld),
        .x    (sqrt_1_x),
        .y_vld(sqrt_1_y_vld),
        .y    (sqrt_1_y)
    );

    isqrt #(
        .n_pipe_stages(N_PIP_STAGES)
    ) u_isqrt_2 (
        .clk  (clk),
        .rst  (rst),
        .x_vld(sqrt_2_x_vld),
        .x    (sqrt_2_x),
        .y_vld(sqrt_2_y_vld),
        .y    (sqrt_2_y)
    );

    isqrt #(
        .n_pipe_stages(N_PIP_STAGES)
    ) u_isqrt_3 (
        .clk  (clk),
        .rst  (rst),
        .x_vld(sqrt_3_x_vld),
        .x    (sqrt_3_x),
        .y_vld(sqrt_3_y_vld),
        .y    (sqrt_3_y)
    );


endmodule
