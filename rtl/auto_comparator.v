module auto_comparator (
    input  wire         CLKEXT,
    input  wire         EN_COMP,
    input  wire         RST_COMP,
    input  wire         trig,
    input  wire signed [15:0] in1,
    input  wire signed [15:0] in2,
    output reg          [7:0] index,
    output reg  signed [15:0] largest
  );
  reg [7:0] cont;

  always @(posedge CLKEXT)
  begin
    if (RST_COMP)
    begin
      largest <= 16'sh8000; // menor número negativo
      index   <= 8'd0;
      cont    <= 8'd0;
    end
    else if (EN_COMP && trig)
    begin
      // compara as duas entradas com o maior valor armazenado
      if (in1 > largest) begin
        largest <= in1;
        index   <= cont + 8'd1;  // posição de in1
      end
      if (in2 > largest) begin
        largest <= in2;
        index   <= cont + 8'd2;  // posição de in2
      end
      cont <= cont + 8'd2;  // avança para o próximo par
    end
  end
endmodule
