`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/08/2021 06:15:06 PM
// Design Name:
// Module Name: tx_control
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


module tx_control(
  input logic clk,
  input logic reset,
  input logic enable,
  input logic tx_busy,
  output logic tx_start,
  output logic done
  );

  typedef enum logic [1:0] {IDLE, TX, WAIT, DONE} state;
  state pr_state, nx_state;

  always_ff @ (posedge clk) begin
    if(~reset) pr_state <= IDLE;
    else pr_state <= nx_state;
  end

  always_comb begin
    nx_state = IDLE;
    tx_start = 1'b0;
    done = 1'b0;
    case (pr_state)
      IDLE: if(enable) nx_state = TX;

      TX: begin
        tx_start = 1'b1;
        nx_state = WAIT;;
      end

      WAIT: begin
        if(tx_busy) nx_state = WAIT;
        else nx_state = DONE;
      end

      DONE: begin
        done = 1'b1;
        nx_state = IDLE;
      end
    endcase
  end

endmodule
