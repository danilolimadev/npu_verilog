`timescale 1ns/1ps

module tb_piso_deb;
  reg CLKEXT;
  reg RST_GLO;
  reg EN_PISO_DEB;
  reg CLR_PISO_DEB;
  reg SHIFT_DEB;
  reg [15:0] SSFR;
  reg [15:0] CON_SIG;
  reg [15:0] MAC2;
  reg [15:0] MAC1;
  reg [7:0] DD;
  reg [7:0] DC;
  reg [7:0] DB;
  reg [7:0] DA;

  wire [7:0] D_OUT;

  piso_deb uut (
             .CLKEXT(CLKEXT),
             .RST_GLO(RST_GLO),
             .EN_PISO_DEB(EN_PISO_DEB),
             .CLR_PISO_DEB(CLR_PISO_DEB),
             .SHIFT_DEB(SHIFT_DEB),
             .SSFR(SSFR),
             .CON_SIG(CON_SIG),
             .MAC2(MAC2),
             .MAC1(MAC1),
             .DD(DD),
             .DC(DC),
             .DB(DB),
             .DA(DA),
             .D_OUT(D_OUT)
           );

  initial
    CLKEXT = 0;
  always #5 CLKEXT = ~CLKEXT;

  reg [15:0] test_SSFR [0:1];
  reg [15:0] test_CON [0:1];
  reg [15:0] test_MAC2 [0:1];
  reg [15:0] test_MAC1 [0:1];
  reg [7:0] test_DD [0:1];
  reg [7:0] test_DC [0:1];
  reg [7:0] test_DB [0:1];
  reg [7:0] test_DA [0:1];

  integer i, j;
  reg [7:0] expected_bytes [0:11];

  initial
  begin
    RST_GLO = 1;
    EN_PISO_DEB = 0;
    CLR_PISO_DEB = 0;
    SHIFT_DEB = 0;
    SSFR = 16'h0000;
    CON_SIG = 16'h0000;
    MAC2 = 16'h0000;
    MAC1 = 16'h0000;
    DD = 8'h00;
    DC = 8'h00;
    DB = 8'h00;
    DA = 8'h00;
    #20;
    RST_GLO = 0;
    #10;

    test_SSFR[0] = 16'hAAAA;
    test_CON[0] = 16'h5555;
    test_MAC2[0] = 16'h1234;
    test_MAC1[0] = 16'hABCD;
    test_DD[0] = 8'h01;
    test_DC[0] = 8'h02;
    test_DB[0] = 8'h03;
    test_DA[0] = 8'h04;

    test_SSFR[1] = 16'hFFFF;
    test_CON[1] = 16'h0000;
    test_MAC2[1] = 16'hDEAD;
    test_MAC1[1] = 16'hBEEF;
    test_DD[1] = 8'hAA;
    test_DC[1] = 8'hBB;
    test_DB[1] = 8'hCC;
    test_DA[1] = 8'hDD;

    for (i=0; i<2; i=i+1)
    begin
      SSFR = test_SSFR[i];
      CON_SIG = test_CON[i];
      MAC2 = test_MAC2[i];
      MAC1 = test_MAC1[i];
      DD = test_DD[i];
      DC = test_DC[i];
      DB = test_DB[i];
      DA = test_DA[i];

      EN_PISO_DEB = 1;
      SHIFT_DEB = 0;
      #10;

      expected_bytes[0]  = SSFR[15:8];
      expected_bytes[1]  = SSFR[7:0];
      expected_bytes[2]  = CON_SIG[15:8];
      expected_bytes[3]  = CON_SIG[7:0];
      expected_bytes[4]  = MAC2[15:8];
      expected_bytes[5]  = MAC2[7:0];
      expected_bytes[6]  = MAC1[15:8];
      expected_bytes[7]  = MAC1[7:0];
      expected_bytes[8]  = DD;
      expected_bytes[9]  = DC;
      expected_bytes[10] = DB;
      expected_bytes[11] = DA;

      SHIFT_DEB = 1;
      for (j=0; j<12; j=j+1)
      begin
        #10;
        if (D_OUT !== expected_bytes[j])
          $display("FAIL: Test %0d, byte %0d | D_OUT=%h | Expected=%h | Time=%0t", i, j, D_OUT, expected_bytes[j], $time);
        else
          $display("PASS: Test %0d, byte %0d | D_OUT=%h | Time=%0t", i, j, D_OUT, $time);
      end

      EN_PISO_DEB = 0;
      SHIFT_DEB = 0;
      #10;
    end

    $stop;
  end

endmodule
