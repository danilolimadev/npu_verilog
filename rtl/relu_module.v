// Módulo ReLU (Rectified Linear Unit) para NPU
// Implementa a função ReLU com bypass opcional

module relu_module (
    input wire [15:0] Data_Reg,
    input wire En_ReLU,
    input wire En_MAC_ReLU,
    input wire BYPASS_ReLU,
    input wire CLK,
    output reg [15:0] ReLU_OUT
);

    // Sinal interno para o resultado do ReLU
    wire [15:0] relu_result;
    
    // Multiplexer para seleção entre entrada e zero (função ReLU)
    // Se En_ReLU = 1 e Data_Reg[15] = 0 (positivo), passa Data_Reg
    // Se En_ReLU = 1 e Data_Reg[15] = 1 (negativo), passa 0
    // Se En_ReLU = 0, passa 0
    assign relu_result = (En_ReLU & En_MAC_ReLU) ? 
                        (Data_Reg[15] ? 16'h0000 : Data_Reg) : 16'h0000;
    
    // Flip-flop para armazenar o resultado
    always @(posedge CLK) begin
        if (BYPASS_ReLU) begin
            // Bypass: passa a entrada diretamente
            ReLU_OUT <= Data_Reg;
        end else begin
            // Aplica a função ReLU
            ReLU_OUT <= relu_result;
        end
    end

endmodule
