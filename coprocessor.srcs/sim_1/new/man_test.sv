`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/09/2021 10:21:36 AM
// Design Name:
// Module Name: man_test
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


module man_test();

  logic clk, reset, man_enable, done, man_tx_enable, man_done, man_tx_data, man_next_data;
  logic [7:0] A,B;

  man_wrapper #(
  .MEMORY_DEPTH(8)
  )
  MAN_TX_CTRL
  (
    .clk(clk),
    .reset(reset),
    .enable(man_enable),
    .A(A),
    .B(B),
    .tx_done(done),
    .tx_enable(man_tx_enable),
    .op_done(man_done),
    .tx_data(man_tx_data),
    .next_data(man_next_data)
  );

  always #5 clk = ~clk;
  initial begin
    clk = 1'b0;
    reset = 1'b0;
    man_enable = 1'b0;
    A = 'd255;
    B = 'd0;
    done = 1'b1;
    #10
    reset = 1'b1;
    #10
    man_enable = 1'b1;
    wait(man_done) B = 'd255;
  end





endmodule
