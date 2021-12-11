`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/28/2021 01:47:09 PM
// Design Name:
// Module Name: write_fsm_test
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


module write_fsm_test();

  localparam  MEMORY_DEPTH = 8;
  localparam  ADDRESS_WIDTH = $clog2(MEMORY_DEPTH);
  logic clk, reset, enable, write_enable, done;
  logic [ADDRESS_WIDTH-1:0] address;

  write_control #(
  .MEMORY_DEPTH(MEMORY_DEPTH),
  .ADDRESS_WIDTH(ADDRESS_WIDTH)
  )
  FSM_WRITE
  (
  .clk(clk),
  .reset(reset),
  .enable(enable),
  .write_enable(write_enable),
  .done(done),
  .address(address)
  );

  always #5 clk=~clk;
  initial begin
    clk = 1'b0;
    reset = 1'b1;
    enable = 1'b0;
    #10 reset = 1'b0;
    #10 enable = 1'b1;
  end
endmodule
