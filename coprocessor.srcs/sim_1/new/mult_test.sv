`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/09/2021 04:58:11 PM
// Design Name:
// Module Name: mult_test
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


module mult_test();
  logic [7:0] A, B, diff;
  logic [15:0] mult;

  assign diff = A-B;
  assign mult = diff*diff;

  initial begin
    A = 'd255;
    B = 'd0;
  end
endmodule
