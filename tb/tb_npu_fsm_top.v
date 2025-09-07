`timescale 1ns/1ps

module tb_npu_fsm_top;

  // clock e reset
  reg CLKEXT;
  reg RST_GLO;
  reg START;

  // config / status
  reg [15:0] SSFR;
  reg [15:0] CON_SIG;

  // dados de entrada
  reg [7:0] DA, DB, DC, DD;
  reg [7:0] BIAS_IN;

  // saídas
  wire [7:0] D_OUT;
  wire FIFO_FULL;
  wire FIFO_EMPTY;
  wire BUSY;
  wire DONE;

  // DUT
  npu_fsm_top dut (
    .CLKEXT(CLKEXT),
    .RST_GLO(RST_GLO),
    .START(START),
    .SSFR(SSFR),
    .CON_SIG(CON_SIG),
    .DA(DA), .DB(DB), .DC(DC), .DD(DD),
    .BIAS_IN(BIAS_IN),
    .D_OUT(D_OUT),
    .FIFO_FULL(FIFO_FULL),
    .FIFO_EMPTY(FIFO_EMPTY),
    .BUSY(BUSY),
    .DONE(DONE)
  );

  // clock
  initial begin
    CLKEXT = 0;
    forever #5 CLKEXT = ~CLKEXT; // 100 MHz
  end

  // tarefas de estímulo
  task reset_dut;
  begin
    RST_GLO = 1;
    START = 0;
    DA=0; DB=0; DC=0; DD=0; BIAS_IN=0;
    SSFR = 16'h0000;
    CON_SIG = 16'h0000;
    #50;
    RST_GLO = 0;
  end
  endtask

  task start_once;
  begin
    @(negedge CLKEXT);
    START = 1;
    @(negedge CLKEXT);
    START = 0;
  end
  endtask

  // sequência de teste
  initial begin
    $display("[TB] Starting simulation");
    reset_dut();

    // caso 1: operação simples
    DA = 8'd3; DB = 8'd4; // multiplicador 1
    DC = 8'd2; DD = 8'd5; // multiplicador 2
    BIAS_IN = 8'd1;

    start_once();
    wait(DONE);
    @(posedge CLKEXT);
    $display("[TB] Done flag asserted, D_OUT=%0d", D_OUT);

    // caso 2: novo conjunto de entradas
    DA = 8'd7; DB = 8'd2;
    DC = 8'd1; DD = 8'd9;
    start_once();
    wait(DONE);
    @(posedge CLKEXT);
    $display("[TB] Done flag asserted, D_OUT=%0d", D_OUT);

    // caso 3: testar bypass de ReLU (forçar SSFR bits)
    SSFR = 16'b0001_1000_0000_0000; // ex: BYPASS ativo
    DA = 8'd255; DB = 8'd255;
    DC = 8'd128; DD = 8'd2;
    start_once();
    wait(DONE);
    @(posedge CLKEXT);
    $display("[TB] With BYPASS ReLU, D_OUT=%0d", D_OUT);

    // caso 4: encher FIFO até FULL (loop)
    repeat(20) begin
      DA = $random;
      DB = $random;
      DC = $random;
      DD = $random;
      start_once();
      wait(DONE);
      @(posedge CLKEXT);
      if (FIFO_FULL) begin
        $display("[TB] FIFO_FULL reached");
        //disable fill_fifo;
      end
    end
    
    // caso 5: reset durante operação
    DA = 8'd10; DB = 8'd10;
    start_once();
    #15 RST_GLO = 1; #20 RST_GLO = 0;
    @(posedge CLKEXT);
    $display("[TB] Applied async reset during BUSY");

    #200;
    $display("[TB] Simulation finished");
    $stop;
  end

endmodule
