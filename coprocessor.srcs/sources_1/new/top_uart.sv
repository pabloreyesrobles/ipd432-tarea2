`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/21/2021 02:15:54 AM
// Design Name:
// Module Name: top_uart
// Project Name:
// Target Devices:
// Tool Versions:
// Description: Does loopback to test the correct functioning of the UART module.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module top_uart(
  input logic CLK100MHZ,
  input logic CPU_RESETN,
  input logic UART_TXD_IN,
  output logic [1:0] JA,
  output logic UART_RXD_OUT
  );

  logic [7:0] saved, rx_read, tx_packet;
  logic rx_flag, tx_start, tx_busy;

  uart_basic#(
      .CLK_FREQUENCY(100000000),
      .BAUD_RATE(115200)
  )
  UART(
  .clk(CLK100MHZ),
  .reset(!CPU_RESETN),
  .rx(UART_TXD_IN),
  .rx_data(rx_read),
  .rx_ready(rx_flag),
  .tx(UART_RXD_OUT),
  .tx_start(tx_start),
  .tx_data(tx_packet),
  .tx_busy(tx_busy)
  );

  assign JA[0] = UART_TXD_IN;
  assign JA[1] = UART_RXD_OUT;

  // save READED values
  always_ff @ (posedge CLK100MHZ) begin
    if(!CPU_RESETN) saved <= 0;
    else if (rx_flag) saved <= rx_read;
    else saved <= saved;
  end

  // Send modified value back
  always_ff @ (posedge CLK100MHZ) begin
    if(!CPU_RESETN) begin
      tx_packet <= 0;
      tx_start <= 0;
    end
    else if(!tx_busy && rx_flag) begin
      tx_packet <= {saved[3:0],saved[7:4]};
      tx_start <= 1;
    end
    else if(tx_busy) tx_start <= 0;
    else begin
      tx_packet <= tx_packet;
      tx_start <= tx_start;
    end
  end

endmodule
