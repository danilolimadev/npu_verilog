`timescale 1ns/1ps

module tb_input_buffer;
    reg CLKEXT,CLR_BUF_IN,EN_BUF_IN;
    reg [7:0] DA, DB, DC, DD;
    wire [7:0] QA, QB, QC, QD;

    input_buffer uut (
        .CLKEXT(CLKEXT),
        .CLR_BUF_IN(CLR_BUF_IN),
        .EN_BUF_IN(EN_BUF_IN),
        .DA(DA),.DB(DB),.DC(DC),.DD(DD),
        .QA(QA),.QB(QB),.QC(QC),.QD(QD)
    );

    always #5 CLKEXT = ~CLKEXT;

    initial begin
  
        CLKEXT = 0;
        CLR_BUF_IN = 0; // reset ativo
        EN_BUF_IN = 0;
        DA = 8'd0; DB = 8'd0; DC = 8'd0; DD = 8'd0;
        #15;
        CLR_BUF_IN = 1; // reset desativado

        #10;
        EN_BUF_IN = 1;
        DA = 8'h01; DB = 8'h05; DC = 8'hFF; DD = 8'h1D; //saídas alteraj

        #10;
        EN_BUF_IN = 0; 
        DA = 8'h11; DB = 8'h22; DC = 8'h33; DD = 8'h44; //saídas não alteram

        #20;
        $stop;
    end

endmodule
