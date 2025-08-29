`timescale 1ns/1ps

module tb_mac_module;

    reg CLKEXT, EN_MAC, RST_MAC;
    reg [7:0] BIAS_IN;
    reg signed [7:0] A, B;
    wire signed [15:0] Y;

    mac_module uut (
        .CLKEXT(CLKEXT),
        .EN_MAC(EN_MAC),
        .RST_MAC(RST_MAC),
        .BIAS_IN(BIAS_IN),
        .A(A),.B(B),.Y(Y)
    );

    always #5 CLKEXT = ~CLKEXT;

    
    reg signed [15:0] exp_Y;
    task check_output;
        if (Y !== exp_Y) begin
            $display("ERRO t=%0t | Esperado=%d (0x%h) Obtido=%d (0x%h)", 
                      $time, exp_Y, exp_Y, Y, Y);
        end else begin
            $display("OK   t=%0t | Y=%d (0x%h)", $time, Y, Y);
        end
    endtask

    initial begin
        
        CLKEXT = 0;
        EN_MAC = 0;
        RST_MAC = 0;
        BIAS_IN = 0;
        A = 0; B = 0; 
        
        exp_Y = 0;

        // --- Teste 1: Reset carrega BIAS_IN ---
        #2;
        RST_MAC = 1; 
        BIAS_IN = 8'd10; // esperado: 0x000A
        EN_MAC = 1;
        @(posedge CLKEXT);
        exp_Y = 16'd10;
        #1 check_output();

        // --- Teste 2: MAC acumulando ---
        RST_MAC = 0; 
        A = 8'sd2; B = 8'sd3; // produto = 6
        @(posedge CLKEXT);
        exp_Y = exp_Y + (A * B); // 10 + 6 = 16
        #1 check_output();

        // --- Teste 3: EN_MAC desabilitado (saída não muda) ---
        EN_MAC = 0;
        A = 8'sd50; B = 8'sd50; // produto = 2500
        @(posedge CLKEXT);
        #1 check_output(); // deve manter 16

        // --- Teste 4: Overflow positivo ---
        EN_MAC = 1;
        A = 8'sd127; B = 8'sd127; // 16129
        repeat (3) @(posedge CLKEXT); // acumular várias vezes
        exp_Y = 16'sh7FFF; // saturação positiva
        #1 check_output();

        // --- Teste 5: Overflow negativo ---
        RST_MAC = 1; BIAS_IN = 0; @(posedge CLKEXT); // reset para 0
        exp_Y = 0; #1 check_output();

        RST_MAC = 0;
        A = -128; B = 127; // produto = -16256
        repeat (3) @(posedge CLKEXT);
        exp_Y = -32768; // saturação negativa (0x8000)
        #1 check_output();

        #20;
        $stop;
    end

endmodule
