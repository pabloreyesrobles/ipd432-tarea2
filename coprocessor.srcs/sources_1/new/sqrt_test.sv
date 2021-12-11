`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/09/2021 03:12:22 PM
// Design Name:
// Module Name: sqrt_test
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


module sqrt_test();
  logic clk, valid_data, valid_out;
  logic [27:0] in;
  logic [14:0] out;

  logic [7:0] A,B;
  logic [15:0] data;
  logic [27:0] value;

  assign data = (A-B)*(A-B);

  cordic_0 TEST (
  .aclk(clk),                                        // input wire aclk
  .s_axis_cartesian_tvalid(valid_data),  // input wire s_axis_cartesian_tvalid
  .s_axis_cartesian_tdata(in),    // input wire [15 : 0] s_axis_cartesian_tdata
  .m_axis_dout_tvalid(valid_out),            // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(out)              // output wire [15 : 0] m_axis_dout_tdata
  );

  always #5 clk = ~clk;
  initial begin
    clk = 1'b0;
    A = 'd255;
    B = 'd0;
    value = 'd0;
    #10
    value = data * 1024;
    #10
    in = value;
    valid_data = 1'b1;
  end

endmodule
