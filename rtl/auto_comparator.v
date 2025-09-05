// Auto Comparator Module for NPU
// Compares two inputs and generates output based on comparison
// In_Read[15:0] -> first input for comparison
// In_COMP[15:0] -> second input for comparison
// RST_COMP -> comparator reset
// EN_COMP -> comparator enable
// Output[15:0] -> comparator output

module auto_comparator (
    input wire [15:0] In_Read,
    input wire [15:0] In_COMP,
    input wire RST_COMP,
    input wire EN_COMP,
    input wire CLK,
    output reg [15:0] Output
);

    // Internal signals for comparison
    wire [15:0] comp_result;
    wire [15:0] diff;
    wire [15:0] abs_diff;
    
    // Calculate difference between inputs
    assign diff = In_Read - In_COMP;
    
    // Calculate absolute value of difference
    assign abs_diff = diff[15] ? (~diff + 1) : diff;
    
    // Comparison logic
    // If EN_COMP = 0, output is 0
    // If EN_COMP = 1, applies comparison logic:
    //   - If In_Read > In_COMP: returns In_Read
    //   - If In_Read < In_COMP: returns In_COMP  
    //   - If In_Read = In_COMP: returns In_Read
    assign comp_result = EN_COMP ? 
                        (In_Read >= In_COMP) ? In_Read : In_COMP : 16'h0000;
    
    // Flip-flop to store the result
    always @(posedge CLK or posedge RST_COMP) begin
        if (RST_COMP) begin
            Output <= 16'h0000;
        end else begin
            Output <= comp_result;
        end
    end

endmodule
