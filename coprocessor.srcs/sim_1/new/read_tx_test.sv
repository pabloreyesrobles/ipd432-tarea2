`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/28/2021 12:49:23 PM
// Design Name:
// Module Name: read_tx_test
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


module read_tx_test(

    );

    localparam  MEMORY_DEPTH = 8;
    localparam  ADDRESS_WIDTH = $clog2(MEMORY_DEPTH);
    localparam  WAIT_READ_CYCLES = 3;

    logic clk, reset, enable_read, tx_busy, done, tx_start;
    logic [ADDRESS_WIDTH-1:0] read_address;

    read_tx #(
      .MEMORY_DEPTH(MEMORY_DEPTH),
      .ADDRESS_WIDTH(ADDRESS_WIDTH),
      .WAIT_READ_CYCLES(WAIT_READ_CYCLES)
    )
    FSM_READ_TX
    (
      .clk(clk),
      .reset(reset),
      .enable(enable_read),
      .tx_busy(tx_busy),
      .read_address(read_address),
      .done(done),
      .tx_start(tx_start)
    );

    always #5 clk=~clk;
    initial begin
      clk = 1'b0;
      reset = 1'b1;
      enable_read = 1'b0;
      tx_busy = 1'b0;
      #10 reset = 1'b0;
      #10 enable_read = 1'b1;

    end
endmodule
