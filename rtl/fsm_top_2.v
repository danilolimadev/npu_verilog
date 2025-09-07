// npu_fsm_top.v
// Top-level FSM controller para o NPU — escrito em Verilog (compatível Verilog-2001)
// Objetivo: integrar módulos existentes em rtl/ sem usar SystemVerilog.
// Adapte sinais e nomes conforme os módulos reais do seu repositório.

module npu_fsm_top (
    input  CLKEXT,      // main clock
    input  RST_GLO,     // global reset (active high)
    input  START,       // start pulse (1-cycle) to begin operation

    // configuration / status
    input  [15:0] SSFR,        // status / control register (debug)
    input  [15:0] CON_SIG,     // group of control signals (debug)

    // data inputs (4 lanes)
    input  [7:0] DA,
    input  [7:0] DB,
    input  [7:0] DC,
    input  [7:0] DD,

    // bias
    input  [7:0] BIAS_IN,

    // primary output
    output [7:0] D_OUT,       // final multiplexed output
    output FIFO_FULL,
    output FIFO_EMPTY,

    // status
    output reg BUSY,
    output reg DONE
  );

  // ------------------------------------------------------------------
  // Parameters
  // ------------------------------------------------------------------
  parameter IDLE         = 4'd0;
  parameter LOAD_INPUT   = 4'd1;
  parameter COMPUTE      = 4'd2;
  parameter RELU_STAGE   = 4'd3;
  parameter WRITE_FIFO   = 4'd4;
  parameter OUTPUT_SHIFT = 4'd5;
  parameter FINISH       = 4'd6;

  parameter MAC_CYCLES   = 8'd4;    // ajuste conforme necessidade

  // ------------------------------------------------------------------
  // Internal signals
  // ------------------------------------------------------------------
  reg [3:0] state, next_state;
  reg [7:0] cycle_cnt;
  reg start_sync;

  // Signals between instantiated modules
  wire [7:0] QA, QB, QC, QD; // outputs from input_buffer

  // MAC interface
  reg EN_MAC;
  reg RST_MAC;
  wire [15:0] MAC0_Y, MAC1_Y; // 16-bit mac output (sem "signed")

  // ReLU interface
  reg En_ReLU;
  reg BYPASS_ReLU;
  wire [15:0] ReLU0_OUT, ReLU1_OUT;

  // PISO_OUT interface
  reg EN_PISO_OUT;
  reg CLR_PISO_OUT;
  reg SHIFT_OUT;
  wire [7:0] PISO_DOUT;

  // FIFO interface
  reg fifo_wf_en;
  reg fifo_rd_en;
  wire [7:0] fifo_data_out;
  reg  [7:0] fifo_data_in;

  // Mux selection for final output
  reg  [2:0] SEL_OUT;

  // Comparator
  reg EN_COMP;
  reg RST_COMP;
  wire [15:0] COMP_OUT;

  // temporary registers
  reg [15:0] mac0_out_reg;
  reg [15:0] mac1_out_reg;

  // ------------------------------------------------------------------
  // Instantiate datapath modules (assuma que nomes e portas batem com rtl/)
  // ------------------------------------------------------------------
  input_buffer ib (
                 .CLKEXT(CLKEXT),
                 .CLR_BUF_IN(~RST_GLO),
                 .EN_BUF_IN(state==LOAD_INPUT),
                 .DA(DA), .DB(DB), .DC(DC), .DD(DD),
                 .QA(QA), .QB(QB), .QC(QC), .QD(QD)
               );

  mac_module mac0 (
               .CLKEXT(CLKEXT),
               .EN_MAC(EN_MAC),
               .RST_MAC(RST_MAC),
               .BIAS_IN(DA),
               .A(QA),
               .B(QB),
               .Y(MAC0_Y)
             );


  mac_module mac1 (
               .CLKEXT(CLKEXT),
               .EN_MAC(EN_MAC),
               .RST_MAC(RST_MAC),
               .BIAS_IN(DC),
               .A(QC),
               .B(QD),
               .Y(MAC1_Y)
             );

  relu_module relu1 (
                .Data_Reg(MAC0_Y),
                .En_ReLU(En_ReLU),
                .En_MAC_ReLU(1'b1),
                .BYPASS_ReLU(BYPASS_ReLU),
                .RST_GLO(RST_GLO),
                .CLKEXT(CLKEXT)
                .ReLU_OUT(ReLU0_OUT)
              );

  relu_module relu2 (
                .Data_Reg(MAC1_Y),
                .En_ReLU(En_ReLU),
                .En_MAC_ReLU(1'b1),
                .BYPASS_ReLU(BYPASS_ReLU),
                .RST_GLO(RST_GLO),
                .CLKEXT(CLKEXT)
                .ReLU_OUT(ReLU1_OUT)
              );

  piso_out piso (
             .CLKEXT(CLKEXT),
             .RST_GLO(RST_GLO),
             .EN_PISO_OUT(EN_PISO_OUT),
             .CLR_PISO_OUT(CLR_PISO_OUT),
             .SHIFT_OUT(SHIFT_OUT),
             .mac0_out(mac0_out_reg),
             .mac1_out(mac1_out_reg),
             .D_OUT(PISO_DOUT)
           );

  fifo #(.DATA_WIDTH(8), .DEPTH(128)) out_fifo (
         .clk(CLKEXT),
         .rst(RST_GLO),
         .enable(1'b1),
         .wf_en(fifo_wf_en),
         .rd_en(fifo_rd_en),
         .data_in(fifo_data_in),
         .data_out(fifo_data_out),
         .empty(FIFO_EMPTY),
         .full(FIFO_FULL)
       );

  mux_out final_mux (
            .CLKEXT(CLKEXT),
            .RST_GLO(RST_GLO),
            .SEL_OUT(SEL_OUT),
            .fifo_data(fifo_data_out),
            .piso_data(PISO_DOUT),
            .cmp_data(COMP_OUT[7:0]),
            .relu_data(ReLU_OUT[7:0]),
            .mac_data(MAC_Y[7:0]),
            .D_OUT(D_OUT)
          );

  auto_comparator comp (
                    .in1(MAC_Y),
                    .in2(COMP_OUT),
                    .RST_COMP(RST_COMP),
                    .EN_COMP(EN_COMP),
                    .CLKEXT(CLKEXT),
                    .Output(COMP_OUT)
                  );

  // ------------------------------------------------------------------
  // Start synchronizer
  // ------------------------------------------------------------------
  always @(posedge CLKEXT or posedge RST_GLO)
  begin
    if (RST_GLO)
    begin
      start_sync <= 1'b0;
    end
    else
    begin
      start_sync <= START;
    end
  end

  // ------------------------------------------------------------------
  // FSM sequential
  // ------------------------------------------------------------------
  always @(posedge CLKEXT or posedge RST_GLO)
  begin
    if (RST_GLO)
    begin
      state <= IDLE;
      cycle_cnt <= 8'd0;
      BUSY <= 1'b0;
      DONE <= 1'b0;
    end
    else
    begin
      state <= next_state;
      if (state == COMPUTE)
        cycle_cnt <= cycle_cnt + 1'b1;
      else
        cycle_cnt <= 8'd0;
    end
  end

  // ------------------------------------------------------------------
  // FSM combinational
  // ------------------------------------------------------------------
  always @(*)
  begin
    // defaults
    next_state = state;
    if (state != IDLE && state != FINISH)
      BUSY = 1'b1;
    else
      BUSY = 1'b0;

    if (state == FINISH)
      DONE = 1'b1;
    else
      DONE = 1'b0;

    // default control signals
    EN_MAC = 1'b0;
    RST_MAC = RST_GLO;
    En_ReLU = 1'b0;
    BYPASS_ReLU = 1'b0;
    EN_PISO_OUT = 1'b0;
    CLR_PISO_OUT = 1'b0;
    SHIFT_OUT = 1'b0;
    fifo_wf_en = 1'b0;
    fifo_rd_en = 1'b0;
    fifo_data_in = 8'h00;
    SEL_OUT = 3'b000;
    EN_COMP = 1'b0;
    RST_COMP = RST_GLO;

    case (state)
      IDLE:
      begin
        if (start_sync)
          next_state = LOAD_INPUT;
        else
          next_state = IDLE;
      end

      LOAD_INPUT:
      begin
        // habilita captura no input_buffer por um ciclo
        next_state = COMPUTE;
      end

      COMPUTE:
      begin
        EN_MAC = 1'b1;
        RST_MAC = 1'b0;
        if (cycle_cnt >= (MAC_CYCLES - 1))
          next_state = RELU_STAGE;
        else
          next_state = COMPUTE;
      end

      RELU_STAGE:
      begin
        En_ReLU = 1'b1;
        BYPASS_ReLU = 1'b0;
        next_state = WRITE_FIFO;
      end

      WRITE_FIFO:
      begin
        // escreve dois bytes na FIFO (alto primeiro, depois baixo)
        fifo_wf_en = 1'b1;
        if (cycle_cnt == 0)
        begin
          fifo_data_in = ReLU_OUT[15:8];
          next_state = WRITE_FIFO; // permanece para a segunda escrita
        end
        else
        begin
          fifo_data_in = ReLU_OUT[7:0];
          next_state = OUTPUT_SHIFT;
        end
      end

      OUTPUT_SHIFT:
      begin
        EN_PISO_OUT = 1'b1;
        CLR_PISO_OUT = 1'b0;
        SHIFT_OUT = 1'b1;
        SEL_OUT = 3'b001; // escolhe dados do piso
        fifo_rd_en = 1'b0;
        next_state = FINISH;
      end

      FINISH:
      begin
        next_state = IDLE;
      end

      default:
      begin
        next_state = IDLE;
      end
    endcase
  end

  // ------------------------------------------------------------------
  // Capture MAC outputs
  // ------------------------------------------------------------------
  always @(posedge CLKEXT or posedge RST_GLO)
  begin
    if (RST_GLO)
    begin
      mac0_out_reg <= 16'd0;
      mac1_out_reg <= 16'd0;
    end
    else
    begin
      if (state == COMPUTE && next_state == RELU_STAGE)
      begin
        mac0_out_reg <= MAC1_Y;
        mac1_out_reg <= MAC2_Y; // duplicado como exemplo
      end
    end
  end

endmodule
