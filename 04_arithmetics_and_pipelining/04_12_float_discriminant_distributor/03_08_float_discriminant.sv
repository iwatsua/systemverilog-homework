//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module float_discriminant (
    input                     clk,
    input                     rst,

    input                     arg_vld,
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,
    input        [FLEN - 1:0] c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,

    output logic              busy
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs their discriminant.
    // The resulting value res should be calculated as a discriminant of the quadratic polynomial.
    // That is, res = b^2 - 4ac == b*b - 4*a*c
    //
    // Note:
    // If any argument is not a valid number, that is NaN or Inf, the "err" flag should be set.
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

   localparam FLEN_ZERO = {(FLEN - 1) {1'b0}};
    localparam [FLEN - 1:0] FL_FOUR = 64'h4010_0000_0000_0000;

    enum logic [2:0] {
        IDLE      = 3'b000,
        STAGE_BB  = 3'b001,  //
        STAGE_AC  = 3'b011,  //
        STAGE_4AC = 3'b010,  //
        STAGE_SUB = 3'b110,  // res = b*b - 4*a*c
        DONE      = 3'b111
    }
    state, new_state;

    f_sub u_f_sub (
        .clk       (clk),
        .rst       (rst),
        .a         (sub_a),
        .b         (sub_b),
        .up_valid  (sub_upvalid),
        .res       (sub_res),
        .down_valid(sub_downvalid),
        .busy      (sub_busy),
        .error     (sub_error)
    );

    f_mult u_f_mult (
        .clk       (clk),
        .rst       (rst),
        .a         (mult_a),
        .b         (mult_b),
        .up_valid  (mult_upvalid),
        .res       (mult_res),
        .down_valid(mult_downvalid),
        .busy      (mult_busy),
        .error     (mult_error)
    );

    logic [FLEN-1:0] a_reg;
    logic [FLEN-1:0] b_reg;
    logic [FLEN-1:0] c_reg;

    logic [FLEN-1:0] b_square;
    logic [FLEN-1:0] four_ac;
    logic [FLEN-1:0] a_mul_c;
    logic            sub_upvalid;
    logic            sub_downvalid;
    logic [FLEN-1:0] sub_a;
    logic [FLEN-1:0] sub_b;
    logic [FLEN-1:0] sub_res;
    logic            sub_busy;
    logic            sub_error;

    logic            mult_upvalid;
    logic            mult_downvalid;
    logic [FLEN-1:0] mult_a;
    logic [FLEN-1:0] mult_b;
    logic [FLEN-1:0] mult_res;
    logic            mult_busy;
    logic            mult_error;


    // store the input a b c values
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            a_reg <= '0;
            b_reg <= '0;
            c_reg <= '0;
        end else if (arg_vld) begin
            a_reg <= a;
            b_reg <= b;
            c_reg <= c;
        end
    end

    // state update
    always_ff @(posedge clk)
        if (rst) state <= IDLE;
        else state <= new_state;

    // new state transition
    always_comb begin
        new_state = state;
        case (state)
        IDLE: begin
            if (arg_vld) begin
                new_state = STAGE_BB;
            end
        end
        STAGE_BB: begin
            if (mult_downvalid) begin
                new_state = STAGE_AC;
            end
        end
        STAGE_AC: begin
            if (mult_downvalid) begin
                new_state = STAGE_4AC;
            end
        end
        STAGE_4AC: begin
            if (mult_downvalid) begin
                new_state = STAGE_SUB;
            end
        end
        STAGE_SUB: begin
            if (sub_downvalid) begin
                new_state = DONE;
            end
        end
        DONE: begin
            new_state = IDLE;
        end
        default: begin
            new_state = IDLE;  // Default case to handle unexpected states
        end
        endcase
    end    

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            b_square <= FLEN_ZERO;
            four_ac  <= FLEN_ZERO;
            a_mul_c  <= FLEN_ZERO;
        end else begin
            case (state)
                STAGE_BB: begin
                    if (mult_downvalid) b_square <= mult_res;
                end
                STAGE_AC: begin
                    if (mult_downvalid) a_mul_c <= mult_res;
                end
                STAGE_4AC: begin
                    if (mult_downvalid) four_ac <= mult_res;
                end
                default: begin
                    b_square <= b_square;
                    four_ac  <= four_ac;
                    a_mul_c  <= a_mul_c;
                end
            endcase
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            sub_a       <= FLEN_ZERO;
            sub_b       <= FLEN_ZERO;
            sub_upvalid <= 1'b0;
        end else begin
        case (state)
            STAGE_4AC: begin
                if (mult_downvalid) begin
                    sub_a       <= b_square;
                    sub_b       <= mult_res;
                    sub_upvalid <= 1'b1;
                end
            end
            STAGE_SUB: begin
                sub_upvalid <= 1'b0;
            end
        endcase
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            mult_a       <= FLEN_ZERO;
            mult_b       <= FLEN_ZERO;
            mult_upvalid <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (arg_vld) begin
                        mult_a       <= b;
                        mult_b       <= b;
                        mult_upvalid <= 1'b1;
                    end
                end
                STAGE_BB: begin
                    if (mult_downvalid) begin
                        mult_a       <= a_reg;
                        mult_b       <= c_reg;
                        mult_upvalid <= 1'b1;
                    end else begin
                        mult_upvalid <= 1'b0;
                    end
                end
                STAGE_AC: begin
                    if (mult_downvalid) begin
                        mult_a       <= FL_FOUR;
                        mult_b       <= mult_res;
                        mult_upvalid <= 1'b1;
                    end else begin
                        mult_upvalid <= 1'b0;
                    end
                end
                STAGE_4AC: begin
                    mult_upvalid <= 1'b0;
                end
                default: begin
                    mult_a       <= mult_a;  // retain value
                    mult_b       <= mult_b;  // retain value
                    mult_upvalid <= mult_upvalid;  // retain value
                end
            endcase
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            err <= 1'b0;
        end else begin
        case (state)
            IDLE: begin
                err <= 1'b0;
            end
            STAGE_BB: begin
                if (mult_downvalid) begin
                    err <= err || mult_error;
                end
            end
            STAGE_AC: begin
                if (mult_downvalid) begin
                    err <= err || mult_error;
                end
            end
            STAGE_4AC: begin
                if (mult_downvalid) begin
                    err <= err || mult_error;
                end
            end
            STAGE_SUB: begin
                if (sub_downvalid) begin
                    err <= err || sub_error;
                end
            end
            default: begin
                err <= err;  // Default case to handle unexpected states
            end
        endcase
        end
    end

    assign res_vld      = (state == DONE);
    assign res          = sub_res;
    assign res_negative = res[FLEN-1];
    assign busy         = (state != IDLE) && (state != DONE);

endmodule
