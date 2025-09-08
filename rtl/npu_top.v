// NPU Top Module
// Módulo principal que integra todos os componentes da NPU

module npu_top (
    input  wire        CLKEXT,      // main clock
    input  wire        RST_GLO,     // global reset (active high)
    input  wire        START,       // start pulse (1-cycle) to begin operation

    // configuration / status
    input  wire [15:0] SSFR,        // status / control register (debug)
    input  wire [15:0] CON_SIG,     // group of control signals (debug)

    // data inputs (4 lanes)
    input  wire [7:0]  DA,
    input  wire [7:0]  DB,
    input  wire [7:0]  DC,
    input  wire [7:0]  DD,

    // bias inputs (16-bit each)
    input  wire [15:0] BIAS_N1,
    input  wire [15:0] BIAS_N2,

    // primary output
    output wire [7:0]  D_OUT,       // final multiplexed output
    output wire        FIFO_FULL,
    output wire        FIFO_EMPTY,

    // status
    output wire        BUSY,
    output wire        DONE
);

    // Instanciar o módulo FSM principal
    npu_fsm_top fsm_inst (
        .CLKEXT(CLKEXT),
        .RST_GLO(RST_GLO),
        .START(START),
        .SSFR(SSFR),
        .CON_SIG(CON_SIG),
        .DA(DA),
        .DB(DB),
        .DC(DC),
        .DD(DD),
        .BIAS_N1(BIAS_N1),
        .BIAS_N2(BIAS_N2),
        .D_OUT(D_OUT),
        .FIFO_FULL(FIFO_FULL),
        .FIFO_EMPTY(FIFO_EMPTY),
        .BUSY(BUSY),
        .DONE(DONE)
    );

endmodule
