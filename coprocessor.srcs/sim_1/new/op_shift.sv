`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/08/2021 10:43:38 PM
// Design Name:
// Module Name: op_shift
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


module op_shift();
  logic [15:0] internal_result;
  logic [9:0] internal_A, internal_B, internal_pre_result, c_A,c_B;
  logic [7:0] A, B;

  assign internal_A = {1'b0,A,1'b0};
  assign internal_B = {1'b0,B,1'b0};
  assign c_A = A>>1;
  assign c_B = B>>1;
  assign internal_pre_result = (A>>1) + (B>>1);
  assign internal_result = {internal_pre_result[8:0],7'd0};

  initial begin
    A = 8'hFF;
    B = 8'd0;
  end
endmodule
