//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module parallel_to_serial
# (    (
    (
        output        busy,
        output logic  serial_valid,
        output logic  serial_data
    );

    // Task:
    // Implement a module that converts multi-bit parallel value to the single-bit serial data.
    //
    // The module should accept 'width' bit input parallel data when 'parallel_valid' input is asserted.
    // At the same clock cycle as 'parallel_valid' is asserted, the module should output
    // the least significant bit of the input data. In the following clock cycles the module
    // should output all the remaining bits of the parallel_data.
    // Together with providing correct 'serial_data' value, module should also assert the 'serial_valid' output.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.

    localparam w_index = $clog2(width);
    logic [w_index - 1:0] index;

    always_ff @ (posedge clk)
        if (rst)
            index <= '0;
        else
        begin
            if (parallel_valid)
                index <= w_index'(1);
            else if (index != '0)
                index <= (index == w_index'(width - 1)) ? '0 : index + 1'b1;
        end

    assign serial_valid = parallel_valid | (index != '0);
    assign busy         = index != '0;

    //--

    logic [width - 1:0] parallel_data_r;

    always_ff @ (posedge clk)
        if (parallel_valid)
            parallel_data_r <= parallel_data;

    assign serial_data = parallel_valid ? parallel_data[0] : parallel_data_r[index];

endmodule

