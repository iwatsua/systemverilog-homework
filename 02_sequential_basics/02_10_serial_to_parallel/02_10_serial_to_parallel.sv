//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_to_parallel
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      serial_valid,
    input                      serial_data,

    output logic               parallel_valid,
    output logic [width - 1:0] parallel_data
);
    // Task:
    // Implement a module that converts serial data to the parallel multibit value.
    //
    // The module should accept one-bit values with valid interface in a serial manner.
    // After accumulating 'width' bits, the module should assert the parallel_valid
    // output and set the data.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.

    // var1.
    // logic [width-1:0] shift_reg; // code 1 of N logic [$clog2(width): 0] count; // binary code
    // logic [$clog2(width):0] count;
    // always_ff @(posedge clk or posedge rst) begin
    //     if (rst) begin
    //         shift_reg <= '0;
    //         count <= '0;
    //         parallel_valid <= '0;
    //         parallel_data <= '0;
    //     end else begin
    //         parallel_valid <= '0;
    //         if (serial_valid) begin
    //             shift_reg = {serial_data, shift_reg[width-1:1]};

    //             if (count == width - 1) begin 
    //                 parallel_data = shift_reg;
    //                 parallel_valid <= '1;
    //                 count <= 0; 
    //             end else
    //                 count <= count + 1;
    //         end
    //     end
    // end


    // var2.
    logic [width-1:0] shift_reg; // code 1 of N logic [$clog2(width): 0] count; // binary code
    logic [$clog2(width):0] count;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg <= '0;
            count <= '0;
            parallel_valid <= '0;
            parallel_data <= '0;
        end else begin
            parallel_valid <= '0;
            if (serial_valid) begin
                shift_reg[count] = serial_data;

                if (count == width - 1) begin 
                    parallel_data = shift_reg;
                    parallel_valid <= '1;
                    count <= 0; 
                end else
                    count <= count + 1;
            end
        end
    end


endmodule
