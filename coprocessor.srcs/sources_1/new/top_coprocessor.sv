`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/07/2021 10:03:40 PM
// Design Name:
// Module Name: top_coprocessor
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module top_coprocessor(
  input logic CLK50MHZ,
  input logic CPU_RESETN,
  input logic UART_TXD_IN,
  output logic UART_RXD_OUT,
  output logic [1:0] JA,
  output logic [6:0] CAT,
  output logic [7:0] AN
  );


  localparam  CMD_WIDTH = 3;
  localparam  MEMORY_DEPTH = 1024;
  localparam  ADDRESS_WIDTH = $clog2(MEMORY_DEPTH);
  localparam  WAIT_READ_CYCLES = 3;

  // Logic
  logic rx_ready, core_lock, cmd_flag, bram_sel, tx_busy, write_enable_a, write_enable_b, tx_start;
  logic [7:0] rx_data, write_data_a, write_data_b, read_data_a, read_data_b, tx_data;
  logic [CMD_WIDTH-1:0] cmd_dec;
  logic [ADDRESS_WIDTH-1:0] write_address_a, write_address_b, read_address_a, read_address_b;

  //---------------------------------------------------------------[CMD-DECODER]

  cmd_decoder #(
  .CMD_WIDTH(CMD_WIDTH)
  )
  CMD
  (
    .clk(CLK50MHZ),
    .reset(CPU_RESETN),
    .rx_ready(rx_ready),
    .rx_data(rx_data),
    .core_lock(core_lock),
    .cmd_flag(cmd_flag),
    .cmd_dec(cmd_dec),
    .bram_sel(bram_sel)
  );

  //---------------------------------------------------------------[COPROCESSOR]
  coprocessor #(
  .CMD_WIDTH(CMD_WIDTH),
  .MEMORY_DEPTH(MEMORY_DEPTH),
  .ADDRESS_WIDTH(ADDRESS_WIDTH),
  .WAIT_READ_CYCLES(WAIT_READ_CYCLES)
  )
  CORE_CORE
  (
    .clk(CLK50MHZ),
    .reset(CPU_RESETN),
    .cmd_flag(cmd_flag),
    .cmd_dec(cmd_dec),
    .bram_sel(bram_sel),
    .rx_data(rx_data),
    .rx_ready(rx_ready),
    .tx_busy(tx_busy),
    .read_data_a(read_data_a),
    .read_data_b(read_data_b),
    .write_enable_a(write_enable_a),
    .write_data_a(write_data_a),
    .write_address_a(write_address_a),
    .write_enable_b(write_enable_b),
    .write_data_b(write_data_b),
    .write_address_b(write_address_b),
    .read_address_a(read_address_a),
    .read_address_b(read_address_b),
    .tx_start(tx_start),
    .core_lock(core_lock),
    .tx_data(tx_data),
    .CAT(CAT),
    .AN(AN)
  );
  //----------------------------------------------------------------------[UART]
  // UART MODULE
  uart_basic#(
      .CLK_FREQUENCY(100_000_000),
      .BAUD_RATE(115200)
  )
  UART(
  .clk(CLK50MHZ),
  .reset(~CPU_RESETN),
  .rx(UART_TXD_IN),
  .rx_data(rx_data),
  .rx_ready(rx_ready),
  .tx(UART_RXD_OUT),
  .tx_start(tx_start),
  .tx_data(tx_data),
  .tx_busy(tx_busy)
  );

  //--------------------------------------------------------------------[MEMORY]
  // MEMORY LOGIC
  // MEMORY MODULE A
  blk_mem_gen_0 BRAMA (
    .clka(CLK50MHZ),    // input wire clka
    .wea(write_enable_a),      // input wire [0 : 0] wea
    .addra(write_address_a),  // input wire [9 : 0] addra
    .dina(write_data_a),    // input wire [7 : 0] dina
    .clkb(CLK50MHZ),    // input wire clkb
    .addrb(read_address_a),  // input wire [9 : 0] addrb
    .doutb(read_data_a)  // output wire [7 : 0] doutb
  );
  // MEMORY MODULE B
  blk_mem_gen_0 BRAMB (
    .clka(CLK50MHZ),    // input wire clka
    .wea(write_enable_b),      // input wire [0 : 0] wea
    .addra(write_address_b),  // input wire [9 : 0] addra
    .dina(write_data_b),    // input wire [7 : 0] dina
    .clkb(CLK50MHZ),    // input wire clkb
    .addrb(read_address_b),  // input wire [9 : 0] addrb
    .doutb(read_data_b)  // output wire [7 : 0] doutb
  );

  assign JA[0] = UART_TXD_IN;
  assign JA[1] = UART_RXD_OUT;

endmodule
