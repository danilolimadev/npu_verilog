`timescale 1ns/1ps

module tb_mux_out;
    reg        CLKEXT;
    reg        RST_GLO;
    reg [2:0]  SEL_OUT;
    reg [7:0]  fifo_data;
    reg [7:0]  piso_data;
    reg [7:0]  cmp_data;
    reg [7:0]  relu_data;
    reg [7:0]  mac_data;
    wire [7:0] D_OUT;

    mux_out inst (
        .CLKEXT(CLKEXT),
        .RST_GLO(RST_GLO),
        .SEL_OUT(SEL_OUT),
        .fifo_data(fifo_data),
        .piso_data(piso_data),
        .cmp_data(cmp_data),
        .relu_data(relu_data),
        .mac_data(mac_data),
        .D_OUT(D_OUT)
    );

    initial CLKEXT = 0;
    always #5 CLKEXT = ~CLKEXT;  

    initial begin
        RST_GLO   = 1;
        SEL_OUT   = 3'b000;
        fifo_data = 8'hA1;
        piso_data = 8'hB2;
        cmp_data  = 8'hC3;
        relu_data = 8'hD4;
        mac_data  = 8'hE5;

        // libera reset
        #10 RST_GLO = 0;

        // Testa todas as seleções
        #10 SEL_OUT = 3'b000;  // FIFO
        #10 SEL_OUT = 3'b001;  // PISO
        #10 SEL_OUT = 3'b010;  // CMP
        #10 SEL_OUT = 3'b011;  // RELU
        #10 SEL_OUT = 3'b100;  // MAC
        #10 SEL_OUT = 3'b101;  // default (não usado)
        #10 SEL_OUT = 3'b110;
        #10 SEL_OUT = 3'b111;

    end

endmodule
