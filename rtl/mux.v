module mux_out (   
    input  wire [2:0]  SEL_OUT,   
    input  wire [7:0]  fifo_data,  
    input  wire [7:0]  piso_out_data, 
    input  wire [7:0]  index_data,  
    input  wire [7:0]  msb_largest_data,  
    input  wire [7:0]  lsb_largest_data,  
    input  wire [7:0]  piso_deb_data,   
    output reg  [7:0]  D_OUT       // saída multiplexada final
);

    always @(*) begin
        case (SEL_OUT)
            3'b000: D_OUT = fifo_data;      
            3'b001: D_OUT = piso_out_data;      
            3'b010: D_OUT = index_data;  
            3'b011: D_OUT = msb_largest_data; 
            3'b100: D_OUT = lsb_largest_data;  
            3'b101: D_OUT = piso_deb_data; 
            default: D_OUT = 8'h00;         
        endcase
    end

endmodule