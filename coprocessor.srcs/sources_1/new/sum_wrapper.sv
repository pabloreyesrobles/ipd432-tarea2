`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/08/2021 08:20:21 PM
// Design Name:
// Module Name: sum_wrapper
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


module sum_wrapper #(
  parameter MEMORY_DEPTH = 8
  )
  (
  input logic clk,
  input logic reset,
  input logic enable,
  input logic [MEMORY_DEPTH-1:0] A,
  input logic [MEMORY_DEPTH-1:0] B,
  input logic tx_done,
  output logic tx_enable,
  output logic op_done,
  output logic [7:0] tx_data
  );

  logic [15:0] internal_buffer_A, internal_buffer_B, internal_result;
  assign internal_buffer_A = {8'd0, A};
  assign internal_buffer_B = {8'd0, B};
  assign internal_result = internal_buffer_A + internal_buffer_B;

  typedef enum logic [1:0] {IDLE, LSB, MSB, DONE} state;
  state pr_state, nx_state;

  always_ff @ (posedge clk) begin
    if(~reset) pr_state <= IDLE;
    else pr_state <= nx_state;
  end

  always_comb begin
    nx_state = IDLE;
    tx_enable = 1'b0;
    op_done = 1'b0;
    tx_data = 'd0;

    case(pr_state)
      IDLE: if(enable) nx_state = MSB;

      MSB: begin
        tx_enable = 1'b1;
        tx_data = internal_result[15:8];
        if(tx_done) nx_state = LSB;
        else nx_state = MSB;
      end

      LSB: begin
        tx_enable = 1'b1;
        tx_data = internal_result[7:0];
        if(tx_done) nx_state = DONE;
        else nx_state = LSB;
      end

      DONE: begin
        op_done = 1'b1;
        nx_state = IDLE;
      end
    endcase
  end

endmodule
