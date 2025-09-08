module auto_comparator (
    input  wire [15:0] In_Read,
    input  wire [15:0] In_COMP,
    input  wire         RST_COMP,
    input  wire         EN_COMP,
    input  wire         CLK,
    output reg  [15:0] Output
  );
  always @(posedge CLK)
  begin
    if (RST_COMP)
    begin
      Output <= 16'h0000;
    end
    else if (EN_COMP)
    begin
      if (In_Read > In_COMP)
        Output <= In_Read;
      else
        Output <= In_COMP;
    end
  end
endmodule
