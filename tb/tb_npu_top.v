// Testbench para o sistema NPU completo
// Simula o módulo npu_top com todos os componentes integrados
`timescale 1ns/1ps

module tb_npu_top;

    reg         CLKEXT;
    reg         RST_GLO;
    reg         START;
    reg  [15:0] SSFR;
    reg  [15:0] CON_SIG;
    reg  [7:0]  DA, DB, DC, DD;
    reg  [7:0]  BIAS_IN;
    wire [7:0]  D_OUT;
    wire        FIFO_FULL;
    wire        FIFO_EMPTY;
    wire        BUSY;
    wire        DONE;
    
    npu_top npu_inst (
        .CLKEXT(CLKEXT),
        .RST_GLO(RST_GLO),
        .START(START),
        .SSFR(SSFR),
        .CON_SIG(CON_SIG),
        .DA(DA),
        .DB(DB),
        .DC(DC),
        .DD(DD),
        .BIAS_IN(BIAS_IN),
        .D_OUT(D_OUT),
        .FIFO_FULL(FIFO_FULL),
        .FIFO_EMPTY(FIFO_EMPTY),
        .BUSY(BUSY),
        .DONE(DONE)
    );
    
    initial begin
        CLKEXT = 0;
        forever #5 CLKEXT = ~CLKEXT;
    end
    
    initial begin
        $display("=== Testbench NPU Top - Sistema Completo ===");
        $display("Tempo: %t - Iniciando simulacao", $time);
        
        RST_GLO = 1;
        START = 0;
        SSFR = 16'h0000;
        CON_SIG = 16'h0000;
        DA = 8'h00;
        DB = 8'h00;
        DC = 8'h00;
        DD = 8'h00;
        BIAS_IN = 8'h00;
        
        #20;
        
        $display("\n=== Teste 1: Reset e Inicializacao ===");
        RST_GLO = 0;
        #10;
        $display("Tempo: %t - Reset liberado", $time);
        $display("  BUSY = %b, DONE = %b, FIFO_EMPTY = %b", BUSY, DONE, FIFO_EMPTY);
        
        $display("\n=== Teste 2: Configuracao de Dados ===");
        DA = 8'h12;
        DB = 8'h34;
        DC = 8'h56;
        DD = 8'h78;
        BIAS_IN = 8'h10;
        SSFR = 16'h0001;
        #10;
        $display("Tempo: %t - Dados configurados", $time);
        $display("  DA = %h, DB = %h, DC = %h, DD = %h, BIAS = %h", DA, DB, DC, DD, BIAS_IN);
        
        $display("\n=== Teste 3: Iniciar Operacao ===");
        START = 1;
        #10;
        START = 0;
        $display("Tempo: %t - START ativado", $time);
        $display("  BUSY = %b, DONE = %b", BUSY, DONE);
        
        $display("\n=== Aguardando Processamento ===");
        repeat(20) begin
            #10;
            if (DONE == 1) begin
                $display("Tempo: %t - Operacao concluida!", $time);
              
            end
            if ($time > 1000) begin
                $display("Tempo: %t - Timeout! Operacao nao concluida", $time);
               
            end
        end
        
        $display("\n=== Teste 4: Verificar Saida ===");
        $display("Tempo: %t - D_OUT = %h", $time, D_OUT);
        $display("  FIFO_FULL = %b, FIFO_EMPTY = %b", FIFO_FULL, FIFO_EMPTY);
        
        $display("\n=== Teste 5: Segunda Operacao ===");
        DA = 8'hAB;
        DB = 8'hCD;
        DC = 8'hEF;
        DD = 8'h01;
        BIAS_IN = 8'h20;
        #10;
        
        START = 1;
        #10;
        START = 0;
        $display("Tempo: %t - Segunda operacao iniciada", $time);
        
        repeat(20) begin
            #10;
            if (DONE == 1) begin
                $display("Tempo: %t - Segunda operacao concluida!", $time);
               
            end
        end
        
        $display("\nTempo: %t - D_OUT final = %h", $time, D_OUT);
        
        #50;
        $display("\nFim da Simulacao");
        $finish;
    end
    
   
    initial begin
        $monitor("Tempo: %t | CLK: %b | START: %b | BUSY: %b | DONE: %b | D_OUT: %h | FIFO: %b/%b", 
                 $time, CLKEXT, START, BUSY, DONE, D_OUT, FIFO_FULL, FIFO_EMPTY);
    end
    
    
    initial begin
        $dumpfile("npu_simulation.vcd");
        $dumpvars(0, tb_npu_top);
    end

endmodule
