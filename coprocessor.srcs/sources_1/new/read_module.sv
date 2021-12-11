`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/08/2021 04:04:35 PM
// Design Name:
// Module Name: read_module
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


module read_module #(
  parameter ADDRESS_WIDTH = 8,
  parameter MEMORY_DEPTH = 8,
  parameter WAIT_READ_CYCLES = 3
  )
  (
  input logic clk,
  input logic reset,
  input logic enable,
  output logic read_done
  );

  localparam  WAIT_WIDTH = $clog2(WAIT_READ_CYCLES);
  logic [WAIT_WIDTH-1:0] wait_cycles;

  // Logic
  logic waited;

  // FSM
  typedef enum logic [1:0] {IDLE, READ, DONE} state;
  state pr_state, nx_state;

  always_ff @ (posedge clk) begin
    if(~reset) pr_state <= IDLE;
    else pr_state <= nx_state;
  end

  always_comb begin
    read_done = 1'b0;
    nx_state = IDLE;

    case (pr_state)

      IDLE: if(enable) nx_state = READ;

      READ: begin
        if(waited) nx_state = DONE;
        else nx_state = READ;
      end

      DONE: begin
        nx_state = IDLE;
        read_done = 1'b1;
      end

    endcase
  end

  // WAIT COUNTER

  always_ff @ (posedge clk) begin
    if(~reset) begin
      wait_cycles <= 'd0;
      waited <= 1'b0;
    end
    else begin
      if(pr_state == READ) begin
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
