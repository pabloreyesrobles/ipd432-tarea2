`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/06/2021 10:39:27 PM
// Design Name:
// Module Name: decoder_test
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


module decoder_test();
  localparam  CMD_WIDTH = 3;
  logic clk, reset, rx_ready, core_lock, cmd_flag, bram_sel;
  logic [CMD_WIDTH-1:0] cmd_dec;
  logic [7:0] rx_data;

  cmd_decoder_v2 #(
    .CMD_WIDTH(CMD_WIDTH)
    )
    COMMANDS
    (
    .clk(clk),
    .reset(reset),
    .rx_ready(rx_ready),
    .rx_data(rx_data),
    .core_lock(core_lock),
    .cmd_flag(cmd_flag),
    .cmd_dec(cmd_dec),
    .bram_sel(bram_sel)
  );


  always #5 clk = ~clk;
  initial begin
    clk = 1'b0;
    reset = 1'b0;
    rx_ready = 1'b0;
    rx_data = 8'd0;
    core_lock = 1'b0;
    #10
    reset = 1'b1;
    rx_data = 8'b00010010;
    #20
    rx_ready = 1'b1;
    #10
    rx_ready = 1'b0;
    #40
    core_lock = 1'b1;
    #40
    core_lock = 1'b0;
    #10
    rx_data = 8'b11111111;
    #20
    rx_ready = 1'b1;
    #10
    rx_ready = 1'b0;
    #10
    core_lock = 1'b1;
    #10
    core_lock = 1'b0;
  end





endmodule
