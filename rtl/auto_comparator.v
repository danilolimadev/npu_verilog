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
  reg [7:0] base;
  reg signed [15:0] max_val;
  reg [7:0]         max_idx;

  always @(posedge CLKEXT)
  begin
    if (RST_COMP)
    begin
      largest <= 16'sh8000;
      index   <= 8'd0;
      base    <= 8'd0;
    end
    else if (EN_COMP && trig)
    begin
      max_val = largest;
      max_idx = index;
      if (in1 > max_val)
      begin
        max_val = in1;
        max_idx = base + 8'd1;
      end
      if (in2 > max_val)
      begin
        max_val = in2;
        max_idx = base + 8'd2;
      end
      largest <= max_val;
      index   <= max_idx;
      base    <= base + 8'd2;
    end
  end
endmodule
