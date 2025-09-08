module piso_deb (
    input  wire        CLKEXT,            // system clock (CLKEXT)
    input  wire        RST_GLO,        // global reset, active high (from datasheet)
    input  wire        EN_PISO_DEB,    // enable debugging PISO (from SSFR/pin)
    input  wire        CLR_PISO_DEB,   // clear pulse for PISO_DEB (active high, 1 cycle)
    input  wire        SHIFT_DEB,      // 0 = load/capture, 1 = shift out (per datasheet timing)
    input  wire [15:0] SSFR,           // SSFR[15:0]
    input  wire [15:0] CON_SIG,        // control signals group as 16-bit
    input  wire [15:0] MAC2,           // MAC2[15:0]
    input  wire [15:0] MAC1,           // MAC1[15:0]
    input  wire  [7:0] QD,
    input  wire  [7:0] QC,
    input  wire  [7:0] QB,
    input  wire  [7:0] QA,
    output reg  [7:0]  D_OUT          
);

    reg [7:0] dbg_bytes [0:11];  // 0 -> first byte to be transmitted
    reg [3:0] byte_idx;          // index 0..11
    reg       loaded;            // indicates we have captured snapshot and ready to shift
    reg       en_prev;           // previous cycle EN (to detect rising edge)
    integer   i;

    // synchronous logic
    always @(posedge CLKEXT or posedge RST_GLO) begin
        if (RST_GLO) begin
            D_OUT   <= 8'h00;
            byte_idx <= 4'd0;
            loaded   <= 1'b0;
            en_prev  <= 1'b0;
            for (i=0; i<12; i=i+1) dbg_bytes[i] <= 8'h00;
        end else begin
            if (CLR_PISO_DEB) begin
                byte_idx <= 4'd0;
                loaded   <= 1'b0;
                D_OUT    <= 8'h00;
                for (i=0; i<12; i=i+1) dbg_bytes[i] <= 8'h00;
            end else begin
                if (EN_PISO_DEB) begin
                    if (~en_prev) begin
                        if (~SHIFT_DEB) begin
                            dbg_bytes[0]  <= SSFR[15:8];   // SSFR upper
                            dbg_bytes[1]  <= SSFR[7:0];    // SSFR lower
                            dbg_bytes[2]  <= CON_SIG[15:8];
                            dbg_bytes[3]  <= CON_SIG[7:0];
                            dbg_bytes[4]  <= MAC2[15:8];
                            dbg_bytes[5]  <= MAC2[7:0];
                            dbg_bytes[6]  <= MAC1[15:8];
                            dbg_bytes[7]  <= MAC1[7:0];
                            dbg_bytes[8]  <= QD;
                            dbg_bytes[9]  <= QC;
                            dbg_bytes[10] <= QB;
                            dbg_bytes[11] <= QA;
                            byte_idx <= 4'd0;
                            loaded   <= 1'b1;
                            D_OUT    <= 8'h00;
                        end else begin
                            dbg_bytes[0]  <= SSFR[15:8];
                            dbg_bytes[1]  <= SSFR[7:0];
                            dbg_bytes[2]  <= CON_SIG[15:8];
                            dbg_bytes[3]  <= CON_SIG[7:0];
                            dbg_bytes[4]  <= MAC2[15:8];
                            dbg_bytes[5]  <= MAC2[7:0];
                            dbg_bytes[6]  <= MAC1[15:8];
                            dbg_bytes[7]  <= MAC1[7:0];
                            dbg_bytes[8]  <= QD;
                            dbg_bytes[9]  <= QC;
                            dbg_bytes[10] <= QB;
                            dbg_bytes[11] <= QA;
                            byte_idx <= 4'd1;
                            loaded   <= 1'b1;
                            D_OUT    <= SSFR[15:8];
                        end
                    end else begin
                        if (loaded) begin
                            if (SHIFT_DEB) begin
                                if (byte_idx <= 4'd11) begin
                                    D_OUT <= dbg_bytes[byte_idx];
                                    byte_idx <= byte_idx + 4'd1;
                                end else begin
                                    D_OUT <= D_OUT;
                                end
                            end else begin
                                D_OUT <= D_OUT;
                            end
                        end else begin
                            if (~SHIFT_DEB) begin
                                dbg_bytes[0]  <= SSFR[15:8];
                                dbg_bytes[1]  <= SSFR[7:0];
                                dbg_bytes[2]  <= CON_SIG[15:8];
                                dbg_bytes[3]  <= CON_SIG[7:0];
                                dbg_bytes[4]  <= MAC2[15:8];
                                dbg_bytes[5]  <= MAC2[7:0];
                                dbg_bytes[6]  <= MAC1[15:8];
                                dbg_bytes[7]  <= MAC1[7:0];
                                dbg_bytes[8]  <= QD;
                                dbg_bytes[9]  <= QC;
                                dbg_bytes[10] <= QB;
                                dbg_bytes[11] <= QA;
                                byte_idx <= 4'd0;
                                loaded   <= 1'b1;
                            end
                        end
                    end
                end else begin
                    loaded <= 1'b0;
                    byte_idx <= 4'd0;
                end
            end
            en_prev <= EN_PISO_DEB;
        end 
    end 

endmodule
