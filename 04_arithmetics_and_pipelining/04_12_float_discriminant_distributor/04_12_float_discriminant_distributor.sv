module float_discriminant_distributor (
    input                           clk,
    input                           rst,

    input                           arg_vld,
    input        [FLEN - 1:0]       a,
    input        [FLEN - 1:0]       b,
    input        [FLEN - 1:0]       c,

    output logic                    res_vld,
    output logic [FLEN - 1:0]       res,
    output logic                    res_negative,
    output logic                    err,

    output logic                    busy
);

    // Task:
    //
    // Implement a module that will calculate the discriminant based
    // on the triplet of input number a, b, c. The module must be pipelined.
    // It should be able to accept a new triple of arguments on each clock cycle
    // and also, after some time, provide the result on each clock cycle.
    // The idea of the task is similar to the task 04_11. The main difference is
    // in the underlying module 03_08 instead of formula modules.
    //
    // Note 1:
    // Reuse your file "03_08_float_discriminant.sv" from the Homework 03.
    //
    // Note 2:
    // Latency of the module "float_discriminant" should be clarified from the waveform.

    localparam CAL_DELAY = 18;

    logic [           FLEN - 1:0] a_array            [0:CAL_DELAY-1];
    logic [           FLEN - 1:0] b_array            [0:CAL_DELAY-1];
    logic [           FLEN - 1:0] c_array            [0:CAL_DELAY-1];
    logic [        CAL_DELAY-1:0] arg_vld_array;
    logic [        CAL_DELAY-1:0] res_vld_array;
    logic [        CAL_DELAY-1:0] res_negative_array;
    logic [        CAL_DELAY-1:0] err_array;
    logic [        CAL_DELAY-1:0] busy_array;
    logic [           FLEN - 1:0] res_array          [0:CAL_DELAY-1];
    logic [           FLEN - 1:0] res_array_temp     [0:CAL_DELAY-1];
    logic [$clog2(CAL_DELAY)-1:0] cur_idx;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cur_idx <= '0;
        end else begin
        if (arg_vld) begin
            if (cur_idx < CAL_DELAY - 1) cur_idx <= cur_idx + 1;
            else cur_idx <= 'b0;
        end
        end
    end

    generate
        genvar i;
        for (i = 0; i < CAL_DELAY; i = i + 1) begin : gen_block
        float_discriminant u_float_discriminant (
            .clk         (clk),
            .rst         (rst),
            .arg_vld     (arg_vld_array[i]),
            .a           (a_array[i]),
            .b           (b_array[i]),
            .c           (c_array[i]),
            .res_vld     (res_vld_array[i]),
            .res         (res_array[i]),
            .res_negative(res_negative_array[i]),
            .err         (err_array[i]),
            .busy        (busy_array[i])
        );

        end
    endgenerate


    generate
        genvar j;
        for (j = 0; j < CAL_DELAY; j = j + 1) begin : gen_input
        always_ff @(posedge clk or posedge rst) begin
            if (rst) begin
                a_array[j]       <= {FLEN{1'b0}};
                b_array[j]       <= {FLEN{1'b0}};
                c_array[j]       <= {FLEN{1'b0}};
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
            assign res_array_temp[k] = res_array[k] & {FLEN{res_vld_array[k]}};
        end
    endgenerate

    assign res_vld      = |res_vld_array;
    assign res_negative = |res_negative_array;
    assign err          = |err_array;
    assign busy         = |busy_array;
    always_comb begin
        res = '0;  // Результат инициализации равен нулю.
        for (int l = 0; l < CAL_DELAY; l++) begin
        res |= res_array_temp[l];  // Побитовая операция ИЛИ
        end
    end

endmodule
