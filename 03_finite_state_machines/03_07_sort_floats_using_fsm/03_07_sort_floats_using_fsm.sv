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
        st_idle    = 3'd0,
        st_a_less_b = 3'd1,        
        st_a_less_c = 3'd2,
        st_b_less_c = 3'd3
      
    }
    state, next_state;

    always_ff @ (posedge clk)
        if (rst)
            state <= st_idle;
        else
            state <= next_state;

    always_comb
    begin
        next_state = state;
        case (state)
        st_idle     : if ( valid_in ) next_state = st_a_less_b;
        st_a_less_b : if ( valid_in ) next_state = st_a_less_c;
        st_a_less_c : if ( valid_in ) next_state = st_b_less_c;
        st_b_less_c : next_state = st_idle;        
        endcase
    end

    always_comb
    begin
        valid_out = '0;
       
        case (state)
        st_idle : 
        st_a_less_b :  
        st_a_less_c :
        st_b_less_c : 
        endcase
    end


endmodule
