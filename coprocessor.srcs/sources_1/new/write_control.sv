`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/28/2021 01:03:14 AM
// Design Name:
// Module Name: write_control
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


module write_control  #(
  parameter MEMORY_DEPTH = 8,
  parameter ADDRESS_WIDTH = 3
  )(
  input logic clk,
  input logic reset,
  input logic enable,
  input logic rx_ready,
  output logic write_enable,
  output logic done,
  output logic[ADDRESS_WIDTH-1:0] address
  );

  // FSM Logic
  typedef enum logic [2:0] {IDLE, WRITE, ADDRESS, HOLD, DONE} state;
  state pr_state, nx_state;
  // Inner Logic
  logic count_enable, max_address;

  // FSM
  always_ff @ (posedge clk) begin
    if(reset) pr_state <= IDLE;
    else pr_state <= nx_state;
  end

  always_comb begin
    nx_state = IDLE;
    write_enable = 1'b0;
    count_enable = 1'b0;
    done = 1'b0;

    case (pr_state)
      IDLE: begin
        if(enable && rx_ready) nx_state = WRITE;
        else nx_state = IDLE;
      end

      WRITE:  begin
        write_enable = 1'b1;
        if(max_address) nx_state = DONE;
        else nx_state = ADDRESS;
      end

      ADDRESS:  begin
        count_enable = 1'b1;
        nx_state = HOLD;
      end

      HOLD: begin
        if(rx_ready) nx_state = WRITE;
        else nx_state = HOLD;
      end

      DONE: begin
        done = 1'b1;
        nx_state = IDLE;
      end
    endcase
  end

  address_counter #(
      .MEMORY_DEPTH(MEMORY_DEPTH),
      .ADDRESS_WIDTH(ADDRESS_WIDTH)
      )
      WRITE_ADDRESS
      (
      .clk(clk),
      .reset(reset),
      .enable(count_enable),
      .clear(done),
      .address(address),
      .max_address(max_address)
      );

endmodule
