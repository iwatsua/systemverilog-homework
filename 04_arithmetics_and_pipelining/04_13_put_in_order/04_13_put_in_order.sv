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

    output logic                down_vld,
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
    localparam CNT_WIDTH = $clog2(n_inputs);  // Биты счётчика: для 4 входов = 2 бита
    logic [ n_inputs - 1 : 0][width    - 1 : 0] down_data_pre;  // Данные из всех FIFO (мультиплексор входы)
    logic [ n_inputs - 1 : 0]                   rd_en_array;  // Сигналы чтения FIFO (по одному на канал)

    logic [ n_inputs - 1 : 0]                   rd_empty_array;  // Пустые ли FIFO (от всех FIFO)
    logic [CNT_WIDTH - 1 : 0]                   cnt;  // Текущий канал для чтения (0,1,2,3...)
    logic [CNT_WIDTH - 1 : 0]                   cnt_d;  // Задержанный cnt (для синхронизации с data)

    assign down_data = down_data_pre[cnt_d];  // Мультиплексор по отслеженному cnt

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <= '0;  // При сбросе cnt=0 (первый канал FIFO[0])
        end else begin
        if (|rd_en_array) begin  // Если хотя бы одно чтение активно
            cnt <= cnt + 1;  // Переход к следующему каналу
        end
        end
    end

    // задержка (регистр) счётчика для синхронизации с задержкой чтения FIFO
    // FIFO имеет задержку чтения 1 такт:
    // Такт N:   rd_en[0]=1 → cnt=0
    // Такт N+1: data_out[0] готов → cnt=1 
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


    always_comb begin  // Читаем FIFO[k]
        for (int k = 0; k < n_inputs; k++) begin
            rd_en_array[k] = (cnt == CNT_WIDTH'(k) && (~rd_empty_array[k]));  // Текущий канал N не пустой
        end
    end

    generate  // генерируется 4 экземпляра FIFO
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
