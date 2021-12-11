`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/28/2021 01:47:42 PM
// Design Name:
// Module Name: counter_test
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


module counter_test();

  localparam  MEMORY_DEPTH = 8;
  localparam  ADDRESS_WIDTH = $clog2(MEMORY_DEPTH);
  logic clk, reset, count_enable, clear, max_address,over_address;
  logic [ADDRESS_WIDTH-1:0] read_address;

  address_counter #(
      .MEMORY_DEPTH(MEMORY_DEPTH),
      .ADDRESS_WIDTH(ADDRESS_WIDTH)
      )
      READ_ADDRESS
      (
      .clk(clk),
      .reset(reset),
      .enable(count_enable),
      .clear(clear),
      .address(read_address),
      .max_address(max_address),
      .over_address(over_address)
      );

  always #5 clk=~clk;
  initial begin
    clk = 1'b0;
    reset = 1'b1;
    count_enable = 1'b0;
    clear = 1'b0;
    #10 reset = 1'b0;
    #20 count_enable = 1'b1;
    #100 clear = 1'b1;
  end
endmodule
