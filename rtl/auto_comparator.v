module auto_comparator (
    input  wire [15:0] In_Read,
    input  wire [15:0] In_COMP,
    input  wire         RST_COMP,
    input  wire         EN_COMP,
    input  wire         CLK,
    output reg  [15:0] Output
  );
<<<<<<< HEAD
  reg [7:0] cont;

  always @(posedge CLKEXT)
  begin
    if (RST_COMP)
    begin
      largest <= 16'sh8000; // menor número negativo
      index   <= 8'd0;
      cont    <= 8'd0;
=======
  always @(posedge CLK)
  begin
    if (RST_COMP)
    begin
      Output <= 16'h0000;
>>>>>>> nathcarletti/first-test
    end
    else if (EN_COMP)
    begin
<<<<<<< HEAD
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
=======
      if (In_Read > In_COMP)
        Output <= In_Read;
      else
        Output <= In_COMP;
>>>>>>> nathcarletti/first-test
    end
  end
endmodule
