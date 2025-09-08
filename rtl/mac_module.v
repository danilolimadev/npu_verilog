module mac_module (
    input  CLKEXT, //clock
    input  EN_MAC, //enable
    input  RST_MAC, //seletor do mux
    input  signed [15:0] BIAS_IN, //bias de 16 bits
    input  signed [7:0] A, B, //operandos
    output reg signed [15:0] Y //resultado
);

    // 8 bit multiplier
    wire signed [15:0] mult_out;
    assign mult_out = A * B;

    // 16 bit 2's Complement Adder with Saturation Control (2CASC)
    // 17 bit adder
    wire signed [16:0] acc_ext;  
    wire signed [16:0] mult_ext;
    assign acc_ext  = {Y[15], Y}; //saída estendida em 1 bit
    assign mult_ext = {mult_out[15], mult_out}; //resultado da multiplicação estendido em 1 bit
    wire signed [16:0] add_out;
    assign add_out = acc_ext + mult_ext;
    // Saturation
    reg signed [15:0] sat_out;
    always @(*) begin
        case (add_out[16:15]) 
            2'b01: sat_out = 16'h7FFF; // Positive overflow
            2'b10: sat_out = 16'h8000; // Negative overflow
            default: sat_out = add_out[15:0]; // Normal case
        endcase
    end

    // BIAS_IN já é de 16 bits
    wire signed [15:0] bias_ext;
    assign bias_ext = BIAS_IN;

    // Mux
    wire signed [15:0] next_val;
    assign next_val = (RST_MAC) ? bias_ext : sat_out;

    // FF D
    always @(posedge CLKEXT) begin
        if (EN_MAC)
            Y <= next_val;
    end

endmodule
