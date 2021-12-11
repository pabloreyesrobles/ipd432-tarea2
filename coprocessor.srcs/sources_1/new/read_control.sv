`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/28/2021 02:31:53 AM
// Design Name:
// Module Name: read_tx
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


module read_tx  #(
  parameter MEMORY_DEPTH = 8,
  parameter ADDRESS_WIDTH = 8,
  parameter WAIT_READ_CYCLES = 3
  )(
  input logic clk,
  input logic reset,
  input logic enable,
  input logic tx_busy,
  input logic op_done,
  input logic op_override,
  output logic [ADDRESS_WIDTH-1:0] read_address,
  output logic done,
  output logic tx_start,
  output logic op_flag
    );

  // FSM logic
  typedef enum logic [2:0] {IDLE, READ, WAIT_READ, OP, TX, WAIT_TX, ADDRESS, DONE} state;
  state pr_state, nx_state;

  // Inner Logic
    logic max_address, waited, count_enable, over_address;
    localparam  WAIT_WIDTH = $clog2(WAIT_READ_CYCLES);
    logic[WAIT_WIDTH-1:0] wait_cycles;

  // FSM READ_TX
  always_ff @ (posedge clk) begin
    if(reset) pr_state <= IDLE;
    else pr_state <= nx_state;
  end

  always_comb begin
    nx_state = IDLE;
    done = 1'b0;
    tx_start = 1'b0;
    count_enable = 1'b0;
    op_flag = 1'b0;
    case (pr_state)

      IDLE: if(enable) nx_state = READ;

      READ: begin
        if(over_address) nx_state = DONE;
        else nx_state = WAIT_READ;
      end

      WAIT_READ: begin
        if(waited) nx_state = OP;
        else nx_state = WAIT_READ;
      end

      OP: begin
        op_flag = 1'b1;
        if(op_done || op_override) nx_state = TX;
        else nx_state = OP;
      end

      TX: begin
        tx_start = 1'b1;
        nx_state = WAIT_TX;
      end

      WAIT_TX: begin
        if(tx_busy) nx_state = WAIT_TX;
        else nx_state = ADDRESS;
      end

      ADDRESS: begin
        count_enable = 1'b1;
        nx_state = READ;
      end

      DONE: begin
        done = 1'b1;
        nx_state = IDLE;
      end

    endcase
  end

  //address_counter
  address_counter #(
      .MEMORY_DEPTH(MEMORY_DEPTH),
      .ADDRESS_WIDTH(ADDRESS_WIDTH)
      )
      READ_ADDRESS
      (
      .clk(clk),
      .reset(reset),
      .enable(count_enable),
      .clear(done),
      .address(read_address),
      .max_address(max_address),
      .over_address(over_address)
      );


  // WAIT counter
  always_ff @ (posedge clk) begin
    if(reset) begin
      wait_cycles <= 'd0;
      waited <= 1'b0;
    end
    else begin
      if(pr_state == WAIT_READ) begin
        if(wait_cycles == WAIT_READ_CYCLES-1) begin
          wait_cycles <= 'd0;
          waited <= 1'b1;
        end
        else begin
          wait_cycles <= wait_cycles + 'd1;
          waited <= 1'b0;
        end
      end
      else begin
        wait_cycles <= 'd0;
        waited <= 1'b0;
      end
    end
  end
endmodule
