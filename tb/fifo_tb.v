`timescale 1ns/100ps

module fifo_tb;

    parameter DATA_WIDTH = 8;
    parameter DEPTH = 128;

    reg clk, rst, enable, wf_en, rd_en;
    reg [DATA_WIDTH-1:0] data_in;
    wire [DATA_WIDTH-1:0] data_out;
    wire empty, full;

    fifo #(DATA_WIDTH, DEPTH) uut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .wf_en(wf_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .empty(empty),
        .full(full)
    );

    always #5 clk = ~clk; // clock de 100MHz

    initial begin
        clk = 0; rst = 1; enable = 0; wf_en = 0; rd_en = 0; data_in = 0;
        #10 rst = 0; enable = 1;

        @(posedge clk);
        wf_en = 1; data_in = 8'hA1;
        @(posedge clk);
        data_in = 8'hB2;
        @(posedge clk);
        data_in = 8'hC3;
        @(posedge clk);
        wf_en = 0;

        @(posedge clk);
        rd_en = 1;
        @(posedge clk);
        @(posedge clk);
        rd_en = 0;

        wf_en = 1; data_in = 8'hD4;
        @(posedge clk);
        data_in = 8'hE5;
        @(posedge clk);
        wf_en = 0;

        @(posedge clk);
        rd_en = 1;
        repeat(4) @(posedge clk);
        rd_en = 0;

        #20 $stop;
    end

endmodule
