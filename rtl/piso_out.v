module piso_out (
    input  wire        CLKEXT,
    input  wire        RST_GLO,
    input  wire        EN_PISO_OUT,
    input  wire        CLR_PISO_OUT,
    input  wire        SHIFT_OUT,
    input  wire [15:0] mac0_out,
    input  wire [15:0] mac1_out,
    output reg  [7:0]  D_OUT
  );

  // Four 8-bit registers as per schematic
  reg [7:0] reg0, reg1, reg2, reg3;

  always @(posedge CLKEXT or posedge RST_GLO)
  begin
    if (RST_GLO)
    begin
      reg0 <= 8'd0;
      reg1 <= 8'd0;
      reg2 <= 8'd0;
      reg3 <= 8'd0;
      D_OUT <= 8'd0;
    end
    else if (CLR_PISO_OUT)
    begin
      reg0 <= 8'd0;
      reg1 <= 8'd0;
      reg2 <= 8'd0;
      reg3 <= 8'd0;
      D_OUT <= 8'd0;
    end
    else if (EN_PISO_OUT)
    begin
      if (!SHIFT_OUT)
      begin
        // Load: ReLU1_OUT[7:0] -> reg0, ReLU1_OUT[15:8] -> reg1
        //       ReLU2_OUT[7:0] -> reg2, ReLU2_OUT[15:8] -> reg3
        reg0 <= mac0_out[7:0];
        reg1 <= mac0_out[15:8];
        reg2 <= mac1_out[7:0];
        reg3 <= mac1_out[15:8];
      end
      else
      begin
        // Shift: output reg3 and shift left
        D_OUT <= reg3;
        reg3 <= reg2;
        reg2 <= reg1;
        reg1 <= reg0;
        reg0 <= 8'd0;
      end
    end
  end

endmodule
