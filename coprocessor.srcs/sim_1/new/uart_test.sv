`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/22/2021 03:37:28 PM
// Design Name:
// Module Name: uart_test
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


module uart_test();
  logic clk, resetN, UART_TXD_IN, common_flag, UART_RXD_OUT;
  logic [7:0] loopback;

  uart_basic#(
      .CLK_FREQUENCY(100000000),
      .BAUD_RATE(115200)
  )
  UART(
  .clk(clk),
  .reset(resetN),
  .rx(UART_TXD_IN),
  .rx_data(loopback),
  .rx_ready(common_flag),
  .tx(UART_RXD_OUT),
  .tx_start(common_flag),
  .tx_data(loopback),
  .tx_busy()
  );

  always #5 clk = ~clk;
  initial begin
    clk = 1'b0;
    resetN = 1'b0;
    UART_TXD_IN = 1'b1;
    #30
    resetN = 1'b1;
    #10
    // Start
    UART_TXD_IN = 1'b0;
    #86800
    // 1-bit
    UART_TXD_IN = 1'b1;
    #868
    // 2 to 8 bit
    UART_TXD_IN = 1'b0;
    #6076
    UART_TXD_IN = 1'b1;
  end

endmodule
