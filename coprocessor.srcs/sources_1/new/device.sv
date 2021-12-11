module device (
  input   logic CLK100MHZ,
  input   logic CPU_RESETN,
  input   logic UART_TXD_IN,
  output  logic [1:0] LED,
  output  logic [2:0] JA,
  output  logic UART_RXD_OUT
);

  // Logic analizer interface
  assign JA[0] = UART_TXD_IN;
  assign JA[1] = UART_RXD_OUT;
  
  // Memory Logic
  localparam MEMORY_DEPTH = 1024; // 8 For testing
  localparam ADDRESS_WIDTH = $clog2(MEMORY_DEPTH);
  localparam WAIT_READ_CYCLES = 3;
  localparam CMD_WIDTH = 3; 

  logic [ADDRESS_WIDTH - 1:0] write_address;
  logic [ADDRESS_WIDTH - 1:0] read_address;

  logic rx_ready, tx_start, tx_busy;
  logic [7:0] rx_data, tx_data;
  
  // LED activity
  assign LED[0] = rx_ready;
  assign LED[1] = tx_busy;

  logic [CMD_WIDTH - 1:0] cmd_dec;
  logic cmd_flag, bram_sel, core_lock;

  logic [7:0] brama_read, bramb_read;
  logic [9:0] brama_write_addr, brama_read_addr;
  logic [9:0] bramb_write_addr, bramb_read_addr;
  logic brama_write_en, bramb_write_en;

  //UART
  uart_basic #(
    .CLK_FREQUENCY(100000000),
    .BAUD_RATE(115200)
  )
  UART (
    .clk(CLK100MHZ),
    .reset(~CPU_RESETN),
    .rx(UART_TXD_IN),
    .rx_data(rx_data),
    .rx_ready(rx_ready),
    .tx(UART_RXD_OUT),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx_busy(tx_busy)
  );

  // Memory block BRAMA
  blk_mem_gen_0 BRAMA (
    .clka(CLK100MHZ),    // input wire clka
    .wea(brama_write_en),      // input wire [0 : 0] wea
    .addra(brama_write_addr),  // input wire [9 : 0] addra
    .dina(rx_data),    // input wire [7 : 0] dina
    .clkb(CLK100MHZ),    // input wire clkb
    .addrb(brama_read_addr),  // input wire [9 : 0] addrb
    .doutb(brama_read)  // output wire [7 : 0] doutb
  );

  // Memory block BRAMB
  blk_mem_gen_0 BRAMB (
    .clka(CLK100MHZ),    // input wire clka
    .wea(bramb_write_en),      // input wire [0 : 0] wea
    .addra(bramb_write_addr),  // input wire [9 : 0] addra
    .dina(rx_data),    // input wire [7 : 0] dina
    .clkb(CLK100MHZ),    // input wire clkb
    .addrb(bramb_read_addr),  // input wire [9 : 0] addrb
    .doutb(bramb_read)  // output wire [7 : 0] doutb
  );

  cmd_decoder cmd_proc (
    .clk(CLK100MHZ),
    .reset(CPU_RESETN),
    .rx_ready,
    .rx_data,
    .core_lock,
    .cmd_flag,
    .cmd_dec,
    .bram_sel
  );

  processing_core core (
    .clk(CLK100MHZ),
    .reset(CPU_RESETN),
    .rx_ready,
    .tx_busy,
    .cmd_flag,
    .cmd_dec,
    .bram_sel,
    .brama_read,
    .bramb_read,
    .brama_write_addr,
    .brama_read_addr,
    .brama_write_en,
    .bramb_write_addr,
    .bramb_read_addr,
    .bramb_write_en,
    .core_lock,
    .tx_data,
    .tx_start
  );
    
endmodule