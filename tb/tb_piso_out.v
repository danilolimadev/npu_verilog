`timescale 1ns/1ps

module tb_piso_out;
  reg CLKEXT;
  reg RST_GLO;
  reg EN_PISO_OUT;
  reg CLR_PISO_OUT;
  reg SHIFT_OUT;
  reg [15:0] mac0_out;
  reg [15:0] mac1_out;

  wire [7:0] D_OUT;

  piso_out uut (
             .CLKEXT(CLKEXT),
             .RST_GLO(RST_GLO),
             .EN_PISO_OUT(EN_PISO_OUT),
             .CLR_PISO_OUT(CLR_PISO_OUT),
             .SHIFT_OUT(SHIFT_OUT),
             .mac0_out(mac0_out),
             .mac1_out(mac1_out),
             .D_OUT(D_OUT)
           );

  initial
    CLKEXT = 0;
  always #5 CLKEXT = ~CLKEXT;

  reg [31:0] test_vectors [0:2];
  integer i, j;
  reg [7:0] expected_byte;

  initial
  begin
    RST_GLO = 1;
    EN_PISO_OUT = 0;
    CLR_PISO_OUT = 0;
    SHIFT_OUT = 0;
    mac0_out = 16'h0000;
    mac1_out = 16'h0000;
    #20;
    RST_GLO = 0;
    #10;

    test_vectors[0] = {16'hAAAA, 16'h5555};
    test_vectors[1] = {16'h1234, 16'hABCD};
    test_vectors[2] = {16'hFFFF, 16'h0000};

    for (i = 0; i < 3; i = i + 1)
    begin
      mac0_out = test_vectors[i][31:16];
      mac1_out = test_vectors[i][15:0];
      SHIFT_OUT = 0;
      EN_PISO_OUT = 1;
      #10;

      SHIFT_OUT = 1;
      for (j = 0; j < 4; j = j + 1)
      begin
        #10;
        expected_byte = (test_vectors[i] >> (8*(3-j))) & 8'hFF;

        if (D_OUT !== expected_byte)
          $display("FAIL: Test %0d, byte %0d | D_OUT=%h | Expected=%h | Time=%0t", i, j, D_OUT, expected_byte, $time);
        else
          $display("PASS: Test %0d, byte %0d | D_OUT=%h | Time=%0t", i, j, D_OUT, $time);
      end
      #10;
    end

    $stop;
  end

endmodule
