module put_in_order
# (
    parameter width    = 16,
              n_inputs = 4
)
(
    input                       clk,
    input                       rst,

    input  [ n_inputs - 1 : 0 ] up_vlds,
    input  [ n_inputs - 1 : 0 ]
           [ width    - 1 : 0 ] up_data,

    output                      down_vld,
    output [ width   - 1 : 0 ]  down_data
);

    // Task:
    //
    // Implement a module that accepts many outputs of the computational blocks
    // and outputs them one by one in order. Input signals "up_vlds" and "up_data"
    // are coming from an array of non-pipelined computational blocks.
    // These external computational blocks have a variable latency.
    //
    // The order of incoming "up_vlds" is not determent, and the task is to
    // output "down_vld" and corresponding data in a round-robin manner,
    // one after another, in order.
    //
    // Comment:
    // The idea of the block is kinda similar to the "parallel_to_serial" block
    // from Homework 2, but here block should also preserve the output order.

    localparam ADDR_WIDTH = 16;
    localparam CNT_WIDTH = $clog2(n_inputs);
    logic [ n_inputs - 1 : 0][width    - 1 : 0] down_data_pre;
    logic [ n_inputs - 1 : 0]                   rd_en_array;

    logic [ n_inputs - 1 : 0]                   rd_empty_array;
    logic [CNT_WIDTH - 1 : 0]                   cnt;
    logic [CNT_WIDTH - 1 : 0]                   cnt_d;

    assign down_data = down_data_pre[cnt_d];

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
        cnt <= '0;
        end else begin
        if (|rd_en_array) begin
            cnt <= cnt + 1;
        end
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_d <= '0;
        end else begin
            cnt_d <= cnt;
        end
    end

    // fifo need one cycle to read out data, so we need to delay the down_data_pre
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            down_vld <= 1'b0;
        end else begin
            down_vld <= |rd_en_array;
        end
    end


    always_comb begin
        for (int k = 0; k < n_inputs; k++) begin
            rd_en_array[k] = (cnt == CNT_WIDTH'(k) && (~rd_empty_array[k]));
        end
    end

    generate
        genvar i;
        for (i = 0; i < n_inputs; i = i + 1) begin : gen_blk_fifo
        fifo #(
            .DATA_LEN  (width),
            .ADDR_WIDTH(ADDR_WIDTH)
        ) u_fifo (
            .clk     (clk),
            .rst_n   (~rst),
            .data_in (up_data[i]),
            .data_out(down_data_pre[i]),
            .wr_en   (up_vlds[i]),
            .rd_en   (rd_en_array[i]),
            .wr_full (),
            .rd_empty(rd_empty_array[i])
        );
        end
    endgenerate

endmodule
