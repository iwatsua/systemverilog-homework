//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe_aware_fsm
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

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);

    // Task:
    //
    // Implement a module formula_1_pipe_aware_fsm
    // with a Finite State Machine (FSM)
    // that drives the inputs and consumes the outputs
    // of a single pipelined module isqrt.
    //
    // The formula_1_pipe_aware_fsm module is supposed to be instantiated
    // inside the module formula_1_pipe_aware_fsm_top,
    // together with a single instance of isqrt.
    //
    // The resulting structure has to compute the formula
    // defined in the file formula_1_fn.svh.
    //
    // The formula_1_pipe_aware_fsm module
    // should NOT create any instances of isqrt module,
    // it should only use the input and output ports connecting
    // to the instance of isqrt at higher level of the instance hierarchy.
    //
    // All the datapath computations except the square root calculation,
    // should be implemented inside formula_1_pipe_aware_fsm module.
    // So this module is not a state machine only, it is a combination
    // of an FSM with a datapath for additions and the intermediate data
    // registers.
    //
    // Note that the module formula_1_pipe_aware_fsm is NOT pipelined itself.
    // It should be able to accept new arguments a, b and c
    // arriving at every N+3 clock cycles.
    //
    // In order to achieve this latency the FSM is supposed to use the fact
    // that isqrt is a pipelined module.
    //
    // For more details, see the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

    enum logic [2:0]
    {
        ST_IDLE = 3'd0,        
        ST_A_SQRT = 3'd1,
        ST_B_SQRT = 3'd2,
        ST_C_SQRT = 3'd3,
        ST_RES_A = 3'd4,
        ST_RES_B = 3'd5,
        ST_RES_C = 3'd6
    }
    state, next_state;

    logic [15:0] res_a, res_b, res_c;

    always_ff @ (posedge clk)
        if (rst)
            state <= ST_IDLE;
        else
            state <= next_state;

    always_comb
    begin
        next_state = state;
        case (state)
            ST_IDLE:
                if ( arg_vld ) next_state = ST_A_SQRT;
            ST_A_SQRT : 
                next_state = ST_B_SQRT;
            ST_B_SQRT : 
                next_state = ST_C_SQRT;
            ST_C_SQRT :
                if ( isqrt_y_vld ) next_state = ST_RES_A;
            ST_RES_A :
                if ( isqrt_y_vld ) next_state = ST_RES_B;
            ST_RES_B :
                if ( isqrt_y_vld ) next_state = ST_RES_C;
            ST_RES_C :
                next_state = ST_IDLE; 
        endcase
    end

    always_comb
    begin
        isqrt_x_vld = '0;
        isqrt_x = '0;

        case (state)
            ST_IDLE:
            begin   
                isqrt_x_vld = arg_vld;
                isqrt_x = a;
            end 

            ST_A_SQRT:
            begin   
                isqrt_x_vld = '1;
                isqrt_x = b;
            end 

            ST_B_SQRT:
            begin
                isqrt_x_vld = '1;
                isqrt_x = c;
            end
        endcase                  
    end

    always_ff @(posedge clk)
    begin
        if (rst) 
        begin
            res_a <= 0; res_b <= 0; res_c <= 0;
        end else begin
            case (state)
                ST_C_SQRT: 
                    if ( isqrt_y_vld ) res_a <= isqrt_y;

                ST_RES_A: 
                    if ( isqrt_y_vld ) res_b <= isqrt_y;

                ST_RES_B: 
                    if ( isqrt_y_vld ) res_c <= isqrt_y;
            endcase
        end
    end

    assign res_vld = (state == ST_RES_C);
    assign res = {16'b0, res_a} + {16'b0, res_b} + {16'b0, res_c};

endmodule
