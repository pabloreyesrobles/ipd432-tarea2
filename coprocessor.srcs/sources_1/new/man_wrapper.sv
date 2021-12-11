`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/09/2021 12:08:04 AM
// Design Name:
// Module Name: man_wrapper
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


module man_wrapper#(
  parameter MEMORY_DEPTH = 8
  )(
  input logic clk,
  input logic reset,
  input logic enable,
  input logic read_flag,
  input logic [7:0] A,
  input logic [7:0] B,
  input logic tx_done,
  output logic tx_enable,
  output logic op_done,
  output logic [7:0] tx_data,
  output logic next_data,
  output logic [23:0] value
  );

  //COUNTER SIZE
  localparam  COUNT_WIDTH = $clog2(MEMORY_DEPTH)+1;

  // HOLDER
  // logic [23:0] value, nx_value;
  logic [23:0] nx_value;
  logic [7:0] data;
  // DIFF CALCULATE
  always_comb begin
    if(A > B) begin
      data = A-B;
    end

    else begin
      data = B-A;
    end
  end



  logic [COUNT_WIDTH-1:0] counter, nx_counter;
  // FSM
  logic count_enable, count_flag, clear_count, cleared;

  typedef enum logic [3:0] {IDLE, READ, ACUM, CHECK, TX1, TX2, TX3, NEXT, DONE} state;
  state pr_state, nx_state;

  always_ff @ (posedge clk) begin
    if(~reset) pr_state <= IDLE;
    else pr_state <= nx_state;
  end

  always_comb begin
    clear_count = 1'b0;
    count_enable = 1'b0;
    next_data = 1'b0;
    op_done = 1'b0;
    tx_enable = 1'b0;
    nx_state = IDLE;
    tx_data = 'd0;

    case (pr_state)
      IDLE: begin
        clear_count = 1'b1;
        if (enable) nx_state = READ;
      end

      READ: begin
        nx_state = READ;
        if (read_flag) nx_state = ACUM;

        if (~enable) nx_state = IDLE;
        //else nx_state = READ;
      end

      ACUM: begin
        count_enable = 1'b1;
        nx_state = CHECK;
      end

      CHECK: begin
        if (counter == MEMORY_DEPTH) nx_state = TX1;
        else nx_state = NEXT;
      end

      TX1: begin
        tx_enable = 1'b1;
        tx_data = value[23:16];
        if(tx_done) nx_state = TX2;
        else nx_state = TX1;
      end

      TX2: begin
        tx_enable = 1'b1;
        tx_data = value[15:8];
        if(tx_done) nx_state = TX3;
        else nx_state = TX2;
      end

      TX3: begin
        tx_enable = 1'b1;
        tx_data = value[7:0];
        if(tx_done) nx_state = DONE;
        else nx_state = TX3;
      end

      NEXT: begin
        next_data = 1'b1;
        nx_state = READ;
      end

      DONE: begin
        op_done = 1'b1;
        nx_state = IDLE;
      end
    endcase
  end

  // Counter

  always_ff @ (posedge clk) begin
    if(~reset | clear_count) begin
      counter <= 'd0;
      value <= 'd0;
    end
    else begin
      counter <= nx_counter;
      value <= nx_value;
    end
  end

  always_comb begin
    if(count_enable) begin
      nx_counter = counter + 'd1;
      nx_value = value + data;
    end
    else begin
      nx_counter = counter;
      nx_value = value;
    end
  end

endmodule
