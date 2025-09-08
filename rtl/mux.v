module mux_out (   
    input  wire        CLKEXT,
    input  wire        RST_GLO,
    input  wire [2:0]  SEL_OUT,   
    input  wire [7:0]  fifo_data,  
    input  wire [7:0]  piso_data, 
    input  wire [7:0]  cmp_data,  
    input  wire [7:0]  relu_data,  
    input  wire [7:0]  mac_data,  
    output reg  [7:0]  D_OUT       // saída multiplexada final
);

    always @(*) begin
        case (SEL_OUT)
            3'b000: D_OUT = fifo_data;      
            3'b001: D_OUT = piso_data;      
            3'b010: D_OUT = cmp_data;  
            3'b011: D_OUT = relu_data; 
            3'b100: D_OUT = mac_data;  
            default: D_OUT = 8'h00;         
        endcase
    end

endmodule
