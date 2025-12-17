//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module round_robin_arbiter_with_2_requests
(
    input        clk,
    input        rst,
    input  [1:0] requests,
    output [1:0] grants
);
    // Task:
    // Implement a "arbiter" module that accepts up to two requests
    // and grants one of them to operate in a round-robin manner.
    //
    // The module should maintain an internal register
    // to keep track of which requester is next in line for a grant.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // requests -> 01 00 10 11 11 00 11 00 11 11
    // grants   -> 01 00 10 01 10 00 01 00 10 01

    //var1
    // logic next_turn_r, next_turn_d;  //1-right, 0-left.

    // always_comb begin
    //     case(requests)
    //         2'b00: next_turn_d = 1'b0;
    //         2'b01: next_turn_d = 1'b1;
    //         2'b10: next_turn_d = 1'b0;
    //         2'b11: next_turn_d = ~next_turn_r;
    //     endcase
    // end

    // assign grants = requests == 2'b11 ? (next_turn_r ? 2'b10 : 2'b01) : requests;

    // always_ff @(posedge clk) begin
    //     if(rst)
    //         next_turn_r <= 1'b0;
    //     else begin
    //         next_turn_r <= next_turn_d;
    //     end
    // end


    //var2
    typedef enum logic [1:0] {IDLE, ZERO, ONE } state_t;
    state_t state_nx, state_ff;
    
    always_ff @(posedge clk) begin
        if (rst) begin
            state_ff <= IDLE;
        end
        else begin
            state_ff <= state_nx;
        end
    end

    always_comb begin 
        case (state_ff) 
            IDLE: begin
                if (requests == 2'b00) state_nx = IDLE; 
                else if (requests == 2'b10) state_nx = ZERO; 
                else if (requests == 2'b01) state_nx = ONE; 
                else if (requests == 2'b11) state_nx = ZERO;
            end

        
            ZERO: begin
                if (requests == 2'b00) state_nx = ZERO;
                else if (requests == 2'b10) state_nx = ZERO; 
                else if (requests == 2'b01) state_nx = ONE; 
                else if (requests == 2'b11) state_nx = ONE;
            end
    
            ONE: begin
                if (requests == 2'b00) state_nx = ONE;
                else if (requests == 2'b10) state_nx = ZERO; 
                else if (requests == 2'b01) state_nx = ONE; 
                else if (requests == 2'b11) state_nx = ZERO;
            end 
        endcase
    end

    assign grants [1] = requests [1] & (state_nx == ZERO);
    assign grants [0] = requests [0] & (state_nx == ONE);



endmodule
