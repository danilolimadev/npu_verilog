// Testbench para os módulos ReLU e Auto Comparador da NPU
`timescale 1ns/1ps

module testbench;

    // Sinais para o módulo ReLU
    reg [15:0] Data_Reg;
    reg En_ReLU;
    reg En_MAC_ReLU;
    reg BYPASS_ReLU;
    reg CLK;
    wire [15:0] ReLU_OUT;
    
    // Sinais para o módulo Auto Comparador
    reg [15:0] In_Read;
    reg [15:0] In_COMP;
    reg RST_COMP;
    reg EN_COMP;
    wire [15:0] Output;
    
    // Instanciar o módulo ReLU
    relu_module relu_inst (
        .Data_Reg(Data_Reg),
        .En_ReLU(En_ReLU),
        .En_MAC_ReLU(En_MAC_ReLU),
        .BYPASS_ReLU(BYPASS_ReLU),
        .CLK(CLK),
        .ReLU_OUT(ReLU_OUT)
    );
    
    // Instanciar o módulo Auto Comparador
    auto_comparator comp_inst (
        .In_Read(In_Read),
        .In_COMP(In_COMP),
        .RST_COMP(RST_COMP),
        .EN_COMP(EN_COMP),
        .CLK(CLK),
        .Output(Output)
    );
    
    // Gerar clock
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK; // Clock de 10ns (50MHz)
    end
    
    // Teste do módulo ReLU
    initial begin
        $display("=== Teste do Módulo ReLU ===");
        
        // Inicializar sinais
        Data_Reg = 0;
        En_ReLU = 0;
        En_MAC_ReLU = 0;
        BYPASS_ReLU = 0;
        
        #20; // Aguardar estabilização
        
        // Teste 1: ReLU com valor positivo
        $display("\nTeste 1: ReLU com valor positivo");
        Data_Reg = 16'h1234; // Valor positivo
        En_ReLU = 1;
        En_MAC_ReLU = 1;
        BYPASS_ReLU = 0;
        #10;
        $display("Entrada: %h, Saída: %h", Data_Reg, ReLU_OUT);
        
        // Teste 2: ReLU com valor negativo
        $display("\nTeste 2: ReLU com valor negativo");
        Data_Reg = 16'h8000; // Valor negativo (bit de sinal = 1)
        #10;
        $display("Entrada: %h, Saída: %h", Data_Reg, ReLU_OUT);
        
        // Teste 3: ReLU desabilitado
        $display("\nTeste 3: ReLU desabilitado");
        Data_Reg = 16'h1234;
        En_ReLU = 0;
        #10;
        $display("Entrada: %h, Saída: %h", Data_Reg, ReLU_OUT);
        
        // Teste 4: Bypass ativado
        $display("\nTeste 4: Bypass ativado");
        Data_Reg = 16'h8000;
        BYPASS_ReLU = 1;
        #10;
        $display("Entrada: %h, Saída: %h", Data_Reg, ReLU_OUT);
        
        #20;
    end
    
    // Teste do módulo Auto Comparador
    initial begin
        #100; // Aguardar testes do ReLU
        
        $display("\n=== Teste do Módulo Auto Comparador ===");
        
        // Inicializar sinais
        In_Read = 0;
        In_COMP = 0;
        RST_COMP = 0;
        EN_COMP = 0;
        
        #20; // Aguardar estabilização
        
        // Teste 1: In_Read > In_COMP
        $display("\nTeste 1: In_Read > In_COMP");
        In_Read = 16'h1234;
        In_COMP = 16'h1000;
        EN_COMP = 1;
        #10;
        $display("In_Read: %h, In_COMP: %h, Saída: %h", In_Read, In_COMP, Output);
        
        // Teste 2: In_Read < In_COMP
        $display("\nTeste 2: In_Read < In_COMP");
        In_Read = 16'h1000;
        In_COMP = 16'h1234;
        #10;
        $display("In_Read: %h, In_COMP: %h, Saída: %h", In_Read, In_COMP, Output);
        
        // Teste 3: In_Read = In_COMP
        $display("\nTeste 3: In_Read = In_COMP");
        In_Read = 16'h1234;
        In_COMP = 16'h1234;
        #10;
        $display("In_Read: %h, In_COMP: %h, Saída: %h", In_Read, In_COMP, Output);
        
        // Teste 4: Comparador desabilitado
        $display("\nTeste 4: Comparador desabilitado");
        In_Read = 16'h1234;
        In_COMP = 16'h1000;
        EN_COMP = 0;
        #10;
        $display("In_Read: %h, In_COMP: %h, Saída: %h", In_Read, In_COMP, Output);
        
        // Teste 5: Reset
        $display("\nTeste 5: Reset");
        In_Read = 16'h1234;
        In_COMP = 16'h1000;
        EN_COMP = 1;
        RST_COMP = 1;
        #10;
        $display("Após reset - Saída: %h", Output);
        
        #20;
        $display("\n=== Fim dos Testes ===");
        $finish;
    end
    
    // Monitor de sinais
    initial begin
        $monitor("Tempo: %t, CLK: %b, ReLU_OUT: %h, Output: %h", 
                 $time, CLK, ReLU_OUT, Output);
    end

endmodule
