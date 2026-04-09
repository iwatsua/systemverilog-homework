module fifo #(
  parameter  DATA_LEN   = 8,
  parameter  ADDR_WIDTH = 5,
  localparam DATA_DEPTH = 2 ** ADDR_WIDTH
) (
  input  logic                clk,
  input  logic                rst_n,
  input  logic [DATA_LEN-1:0] data_in,
  output logic [DATA_LEN-1:0] data_out,
  input  logic                wr_en,
  input  logic                rd_en,
  output logic                wr_full,
  output logic                rd_empty
);

  logic [  DATA_LEN-1:0] fifo_mem   [0:DATA_DEPTH-1];
  logic [ADDR_WIDTH-1:0] wr_ptr;
  logic [ADDR_WIDTH-1:0] rd_ptr;
  logic [  ADDR_WIDTH:0] wr_ptr_ext;
  logic [  ADDR_WIDTH:0] rd_ptr_ext;

  // FIFO implementation goes here
  assign wr_ptr = wr_ptr_ext[ADDR_WIDTH-1:0];
  assign rd_ptr = rd_ptr_ext[ADDR_WIDTH-1:0];
  assign wr_full = (wr_ptr_ext[ADDR_WIDTH] ^ rd_ptr_ext[ADDR_WIDTH]) && (wr_ptr_ext[ADDR_WIDTH-1:0] == rd_ptr_ext[ADDR_WIDTH-1:0]);
  assign rd_empty = (wr_ptr_ext[ADDR_WIDTH:0] == rd_ptr_ext[ADDR_WIDTH:0]);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_ptr_ext <= '0;
    end else if (wr_en && (~wr_full)) begin
      wr_ptr_ext <= wr_ptr_ext + 1;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rd_ptr_ext <= '0;
    end else if (rd_en && (~rd_empty)) begin
      rd_ptr_ext <= rd_ptr_ext + 1;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < DATA_DEPTH; i++) begin
        fifo_mem[i] <= '0;
      end
    end else if (wr_en) begin
      fifo_mem[wr_ptr] <= data_in;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      data_out <= '0;
    end else if (rd_en) begin
      data_out <= fifo_mem[rd_ptr];
    end
  end

endmodule
