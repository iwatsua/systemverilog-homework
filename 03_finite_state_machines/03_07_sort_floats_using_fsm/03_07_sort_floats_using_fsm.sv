//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module sort_floats_using_fsm (
    input                          clk,
    input                          rst,

    input                          valid_in,
    input        [0:2][FLEN - 1:0] unsorted,

    output logic                   valid_out,
    output logic [0:2][FLEN - 1:0] sorted,
    output logic                   err,
    output                         busy,

    // f_less_or_equal interface
    output logic      [FLEN - 1:0] f_le_a,
    output logic      [FLEN - 1:0] f_le_b,
    input                          f_le_res,
    input                          f_le_err
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs them in the increasing order using FSM.
    //
    // Requirements:
    // The solution must have latency equal to the three clock cycles.
    // The solution should use the inputs and outputs to the single "f_less_or_equal" module.
    // The solution should NOT create instances of any modules.
    //
    // Notes:
    // res0 must be less or equal to the res1
    // res1 must be less or equal to the res1
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

    enum logic [2:0]
    {
        st_a_less_b = 3'd0,        
        st_a_less_c = 3'd1,
        st_b_less_c = 3'd2,
        st_res = 3'd3
    }
    state, next_state;

    // Регистры для хранения результатов сравнений
    logic cmp_a_less_b, cmp_a_less_c, cmp_b_less_c;  // 1 если a <= b
    logic err_a_less_b, err_a_less_c, err_b_less_c;
    //logic [0:2][FLEN-1:0] unsorted_reg;

    assign err = err_a_less_b | err_b_less_c | err_a_less_c;
    assign valid_out = (state == st_res);
    assign busy = (state == st_a_less_c) | (state == st_b_less_c);

    // always_ff @(posedge clk or posedge rst) begin
    //     if (rst) begin
    //     unsorted_reg <= '0;
    //     end else begin
    //     if (valid_in) begin
    //         unsorted_reg <= unsorted;
    //     end
    //     end
    // end

    always_ff @ (posedge clk)
        if (rst)
            state <= st_a_less_b;
        else
            state <= next_state;

    always_comb
    begin
        next_state = state;
        case (state)
        st_a_less_b : 
            if ( valid_in ) next_state = st_a_less_c;
        st_a_less_c : next_state = st_b_less_c;
        st_b_less_c : next_state = st_res; 
        st_res : next_state = st_a_less_b;       
        endcase
    end

    always_comb
    begin
        f_le_a = 0;
        f_le_b = 0;

        case (state)
        st_a_less_b:
        begin   
            f_le_a = unsorted[0];
            f_le_b = unsorted[1];            
        end 

        st_a_less_c:
        begin
            f_le_a = unsorted[0];
            f_le_b = unsorted[2];
        end

        st_b_less_c:
        begin
            f_le_a = unsorted[1];
            f_le_b = unsorted[2];
        end
        endcase                  
    end

    always_comb
        if (cmp_a_less_b && cmp_a_less_c)  // a<b && a<c
            if (cmp_b_less_c)  // b<c
                sorted = unsorted;  // abc
            else  // b>c
                sorted = { unsorted [0], unsorted [2], unsorted [1] };  // acb
        else
            if (cmp_b_less_c)  // b<c
                if (cmp_a_less_c)  // a<c
                    sorted = { unsorted [1], unsorted [0], unsorted [2] };  // bac
                else  // a>c
                    sorted = { unsorted [1], unsorted [2], unsorted [0] };  // bca           
            else  // b>c
                if (cmp_a_less_b)  // a<b
                    sorted = { unsorted [2], unsorted [0], unsorted [1] };  // cab
                else  // a>b
                    sorted = { unsorted [2], unsorted [1], unsorted [0] };  // cba

    // Сохранение результатов сравнений
    always_ff @(posedge clk)
    begin
        if (rst) 
        begin
            cmp_a_less_b <= 0; cmp_a_less_c <= 0; cmp_b_less_c <= 0;
            err_a_less_b <= 0; err_a_less_c <= 0; err_b_less_c <= 0;
        end else begin
            case (state)
                st_a_less_b: 
                begin
                    cmp_a_less_b <= f_le_res;
                    err_a_less_b <= f_le_err;
                end
                st_a_less_c: 
                begin
                    cmp_a_less_c <= f_le_res;
                    err_a_less_c <= f_le_err;
                end
                st_b_less_c: 
                begin
                    cmp_b_less_c <= f_le_res;
                    err_b_less_c <= f_le_err;
                end
            endcase
        end
    end
endmodule
