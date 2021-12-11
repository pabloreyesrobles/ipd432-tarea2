`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/08/2021 04:17:10 PM
// Design Name:
// Module Name: read_module_test
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


module read_module_test();

  localparam  ADDRESS_WIDTH = 3;
  localparam  MEMORY_DEPTH = 8;
  localparam  WAIT_READ_CYCLES = 3;
  logic clk, reset, enable, read_done, next_read, clear_address, read_flag, read_op_done;
  logic [ADDRESS_WIDTH-1:0] address_a, address_b;

  read_fsm_control #(
  .ADDRESS_WIDTH(ADDRESS_WIDTH),
  .MEMORY_DEPTH(MEMORY_DEPTH),
  .WAIT_READ_CYCLES(WAIT_READ_CYCLES)
  )
  READ_MAIN_FSM
  (
    .clk(clk),
    .reset(reset),
    .enable(enable),
    .next_read(next_read),
    .clear_address(clear_address),
    .read_flag(read_flag),
    .read_done(read_done),
    .read_op_done(read_op_done),
    .read_address_a(address_a),
    .read_address_b(address_b)
  );

  always #5 clk = ~clk;
  initial begin
    clk = 1'b0;
    reset = 1'b0;
    enable = 1'b0;
    next_read = 1'b0;
    clear_address = 1'b0;
    #10
    reset = 1'b1;
    #20
    enable = 1'b1;
    #50
    next_read = 1'b1;

  end

endmodule
