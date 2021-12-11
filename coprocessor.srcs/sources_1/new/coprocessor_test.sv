`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/07/2021 10:14:48 PM
// Design Name:
// Module Name: coprocessor_test
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


module coprocessor_test();

  localparam  CMD_WIDTH = 3;
  localparam  MEMORY_DEPTH = 8;
  localparam  ADDRESS_WIDTH = 3;

  logic clk, reset, cmd_flag, bram_sel, rx_ready, write_enable_a, write_enable_b;
  logic [CMD_WIDTH-1:0] cmd_dec;
  logic [7:0] rx_data, write_data_a, write_data_b;
  logic [ADDRESS_WIDTH-1:0] write_address_a, write_address_b;

  coprocessor #(
  .CMD_WIDTH(CMD_WIDTH),
  .MEMORY_DEPTH(MEMORY_DEPTH),
  .ADDRESS_WIDTH(ADDRESS_WIDTH)
  )
  COP_TEST
  (
  .clk(clk),
  .reset(reset),
  .cmd_flag(cmd_flag),
  .cmd_dec(cmd_dec),
  .bram_sel(bram_sel),
  .rx_data(rx_data),
  .rx_ready(rx_ready)
  .write_enable_a(write_enable_a),
  .write_data_a(write_data_a),
  .write_address_a(write_address_a),
  .write_enable_b(write_enable_b),
  .write_data_b(write_data_b),
  .write_address_b(write_address_b)
  );

  always #5 clk = ~clk;
  initial begin
    clk = 1'b0;
    reset = 1'b0;
    cmd_flag = 1'b0;
    cmd_dec = 'd0;
    bram_sel = 1'b0;
    rx_data = 'd0;
    rx_ready = 1'b0;
    #20
    reset = 1'b1;
    #20
    bram_sel = 1'b1;
    cmd_dec = 'd1;
    cmd_flag = 1'b1;
    #20
    

  end

endmodule
