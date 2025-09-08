module mux_out (   
    input  wire [2:0]  SEL_OUT,   
    input  wire [7:0]  fifo_data,  
    input  wire [7:0]  target_lsb,  // target[7:0]
    input  wire [7:0]  target_msb,  // target[15:8]
    input  wire [7:0]  piso_deb_data,   
    output reg  [7:0]  D_OUT       // saída multiplexada final
);

    always @(*) begin
        case (SEL_OUT)
            3'b000: D_OUT = fifo_data;      
            3'b001: D_OUT = target_lsb;  // target[7:0]
            3'b010: D_OUT = target_msb;  // target[15:8]
            3'b011: D_OUT = piso_deb_data; 
            3'b100: D_OUT = 8'h00;       // grounded input
            default: D_OUT = 8'h00;         
        endcase
    end

endmodule