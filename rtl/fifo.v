module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 128,
    parameter ADDR_WIDTH = $clog2(DEPTH)
)(
    input clk,
    input rst,
    input enable,
    input wf_en,
    input rd_en,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output empty,
    output full
);

    // Memória do FIFO
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Ponteiros de leitura e escrita
    reg [ADDR_WIDTH:0] wr_ptr;
    reg [ADDR_WIDTH:0] rd_ptr;
    reg [ADDR_WIDTH:0] count;  // qtd de elementos no FIFO

    // Flags
    assign empty = (count == 0);
    assign full  = (count == DEPTH);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
            data_out <= 0;
        end else if (enable) begin
            // Escrita
            if (wf_en && !full) begin
                mem[wr_ptr[ADDR_WIDTH-1:0]] <= data_in;
                wr_ptr <= wr_ptr + 1;
                count  <= count + 1;
            end

            // Leitura
            if (rd_en && !empty) begin
                data_out <= mem[rd_ptr[ADDR_WIDTH-1:0]];
                rd_ptr <= rd_ptr + 1;
                count  <= count - 1;
            end
        end
    end

endmodule