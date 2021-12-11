`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/09/2021 01:58:24 PM
// Design Name:
// Module Name: euc_wrapper
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


module euc_wrapper#(
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
  output logic [15:0] sqrt_out
  );

  //COUNTER SIZE
  localparam  COUNT_WIDTH = $clog2(MEMORY_DEPTH)+1;

  // HOLDER
  logic [27:0] value, nx_value;
  logic [COUNT_WIDTH-1:0] pre_data;
  logic [2*COUNT_WIDTH-1:0] data;
  // logic [15:0] sqrt_out;

  // DIFF CALCULATE
  always_comb begin
    if(A > B) begin
      pre_data = A-B;
    end

    else begin
      pre_data = B-A;
    end
  end

  //assign data = pre_data*pre_data;



  logic [COUNT_WIDTH-1:0] counter, nx_counter;
  // FSM
  logic count_enable, count_flag, clear_count, cleared, sqrt_in_valid, sqrt_out_valid;

  typedef enum logic [3:0] {IDLE, READ, ACUM, CHECK, SQRT, TX1, TX2, NEXT, DONE} state;
  state pr_state, nx_state;

  always_ff @ (posedge clk) begin
    if(~reset) pr_state <= IDLE;
    else pr_state <= nx_state;
  end

  always_comb begin
    sqrt_in_valid = 1'b0;
    clear_count = 1'b0;
    count_enable = 1'b0;
    next_data = 1'b0;
    op_done = 1'b0;
    tx_enable = 1'b0;
    nx_state = IDLE;
    tx_data = 'd0;
    data = 'd0;
    case (pr_state)
      IDLE: begin
        clear_count = 1'b1;
        if (enable) nx_state = READ;
      end

      READ: begin
        nx_state = READ;
        if(read_flag) nx_state = ACUM;

        if (~enable) nx_state = IDLE;
      end

      ACUM: begin
        count_enable = 1'b1;
        data = pre_data*pre_data;
        nx_state = CHECK;
      end

      CHECK: begin
        if(counter == MEMORY_DEPTH) nx_state = SQRT;
        else nx_state = NEXT;
      end

      SQRT: begin
        sqrt_in_valid = 1'b1;
        if(sqrt_out_valid) nx_state = TX1;
        else nx_state = SQRT;
      end

      TX1: begin
        tx_enable = 1'b1;
        tx_data = sqrt_out[15:8];
        if(tx_done) nx_state = TX2;
        else nx_state = TX1;
      end

      TX2: begin
        tx_enable = 1'b1;
        tx_data = sqrt_out[7:0];
        if(tx_done) nx_state = DONE;
        else nx_state = TX2;
      end

      // TX3: begin
      //   tx_enable = 1'b1;
      //   tx_data = sqrt_out[7:0];
      //   if(tx_done) nx_state = DONE;
      //   else nx_state = TX3;
      // end

      NEXT: begin
        next_data = 1'b1;
        nx_state = READ;
      end

      DONE: begin
        op_done = 1'b1;
        //clear_count = 1'b1;
        nx_state = IDLE;
      end
    endcase
  end

  // Counter

  always_ff @ (posedge clk) begin
    if(~reset || clear_count) begin
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

  cordic_0 SQRT_EUC (
  .aclk(clk),                                        // input wire aclk
  .s_axis_cartesian_tvalid(sqrt_in_valid),  // input wire s_axis_cartesian_tvalid
  .s_axis_cartesian_tdata(value),    // input wire [15 : 0] s_axis_cartesian_tdata
  .m_axis_dout_tvalid(sqrt_out_valid),            // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(sqrt_out)              // output wire [15 : 0] m_axis_dout_tdata
  );
endmodule
