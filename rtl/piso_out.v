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

  reg [31:0] shift_reg;

  always @(posedge CLKEXT or posedge RST_GLO)
  begin
    if (RST_GLO)
    begin
      shift_reg <= 32'd0;
      D_OUT     <= 8'd0;
    end
    else if (CLR_PISO_OUT)
    begin
      shift_reg <= 32'd0;
      D_OUT     <= 8'd0;
    end
    else if (EN_PISO_OUT)
    begin
      if (!SHIFT_OUT)
      begin
        shift_reg <= {mac0_out, mac1_out};
      end
      else
      begin
        D_OUT     <= shift_reg[31:24];
        shift_reg <= {shift_reg[23:0], 8'b0};
      end
    end
  end

endmodule
