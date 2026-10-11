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
    output logic [ width   - 1 : 0 ]  down_data
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

    `define SOLUTION_1
    //`define SOLUTION_2
    //`define SOLUTION_3


    `ifdef SOLUTION_1
    // реализация на fifo

    localparam ADDR_WIDTH = 16;
    localparam CNT_WIDTH = $clog2(n_inputs);  // Биты счётчика: для 4 входов = 2 бита
    logic [ n_inputs - 1 : 0][width    - 1 : 0] down_data_pre;  // Данные из всех FIFO (мультиплексор входы)
    logic [ n_inputs - 1 : 0]                   rd_en_array;  // Сигналы чтения FIFO (по одному на канал)

    logic [ n_inputs - 1 : 0]                   rd_empty_array;  // Пустые ли FIFO (от всех FIFO)
    logic [CNT_WIDTH - 1 : 0]                   cnt;  // Текущий канал для чтения (0,1,2,3...)

    // Переменная для хранения индекса, из которого данные ФИЗИЧЕСКИ выходят в данный момент
    logic [CNT_WIDTH - 1 : 0]                cnt_data;

    // Комбинаторно подключаем выход модуля к выходу текущего FIFO
    // Так как FIFO выдает данные на такт N+1 после чтения, мы коммутируем их с помощью cnt_data,
    // который указывает на канал, из которого чтение было запущено на такте N.
    assign down_data = down_data_pre[cnt_data];

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <= '0;  // При сбросе cnt=0 (первый канал FIFO[0])
            down_vld <= 1'b0;
            cnt_data <= '0;
        end else begin
            // down_vld становится 1 на такте N+1, если на такте N было чтение
            down_vld <= ~rd_empty_array[cnt];

            // Если из текущего FIFO происходит чтение, на следующем такте переходим к следующему
            if (~rd_empty_array[cnt]) begin  // Если хотя бы одно чтение активно
                // Фиксируем, из какого именно канала сейчас выходят валидные данные
                cnt_data <= cnt;

                // Переходим к опросу следующего канала по кругу
                cnt <= (cnt == n_inputs - 1) ? '0 : cnt + 1;  // Переход к следующему каналу
            end
        end
    end

    always_comb begin  // Читаем FIFO[k]
        rd_en_array = '0;
        // Читаем только из того FIFO, на которое сейчас указывает наш строгий черед (cnt)
        rd_en_array[cnt] = ~rd_empty_array[cnt];
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

    `endif


    `ifdef SOLUTION_2
    // реализация на flip-flop

    localparam CNT_WIDTH = $clog2(n_inputs);

    // Внутренние сигналы (Определения из Скриншота 1)
    logic [CNT_WIDTH - 1 : 0]   counter;                  // Счетчик строгого обхода (для Realization 1)
    logic [width - 1 : 0]       data_arr [n_inputs];      // Общие буферы данных для каждого входа
    logic [n_inputs - 1 : 0]    vld_arr;                  // Общие флаги занятости буферов

    // 1. Продвижение счетчика обхода
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= '0;
        end else if (vld_arr[counter] | up_vlds[counter]) begin
            counter <= (counter < n_inputs - 1) ? counter + 1'b1 : '0;
        end
    end

    // 2. Управление флагами занятости буферов vld_arr
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            vld_arr <= '0;
        end else begin
            // Если пришли новые валидные данные — взводим соответствующий флаг занятости
            if (|up_vlds) begin
                vld_arr <= vld_arr | up_vlds;
            end
            
            // Если данные с текущего канала counter успешно уходят на выход, 
            // сбрасываем флаг занятости этого канала в 0.
            if (up_vlds[counter] ^ vld_arr[counter]) begin
                vld_arr[counter] <= 1'b0;
            end
        end
    end

    // 3. Буферизация входных данных
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Обнуление массива данных при сбросе
            for (int i = 0; i < n_inputs; i++) begin
                data_arr[i] <= '0;
            end
        end else begin
            // Запись входящих данных в индивидуальные регистры по их готовности
            for (int i = 0; i < n_inputs; i++) begin
                if (up_vlds[i]) begin
                    data_arr[i] <= up_data[i];
                end
            end
        end
    end

    // 4. Выходной мультиплексор данных down_data
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            down_data <= '0;
        end else begin
            if (vld_arr[counter]) begin
                down_data <= data_arr[counter];
            end else if (up_vlds[counter]) begin
                down_data <= up_data[counter];
            end
        end
    end

    // 5. Формирование выходной валидности down_vld
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            down_vld <= 1'b0;
        end else begin
            down_vld <= vld_arr[counter] | up_vlds[counter];
        end
    end

    `endif

endmodule
