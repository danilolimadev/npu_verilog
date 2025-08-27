module input_buffer (
    input  CLKEXT, //clock
    input  CLR_BUF_IN, //clear
    input  EN_BUF_IN, //enable
    input  [7:0] DA, DB, DC, DD, //entradas
    output [7:0] QA, QB, QC, QD //saídas
);

    always @(posedge CLKEXT or negedge CLR_BUF_IN) begin
        if (!CLR_BUF_IN) begin
            QA <= 8'd0;
            QB <= 8'd0;
            QC <= 8'd0;
            QD <= 8'd0;
        end 
        else if (EN_BUF_IN) begin
            QA <= DA;
            QB <= DB;
            QC <= DC;
            QD <= DD;
        end
    end

endmodule
