`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/06/2021 11:18:09 PM
// Design Name:
// Module Name: cmd_decoder_v2
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


module cmd_decoder #(
  parameter CMD_WIDTH = 3
)
(
  input logic clk,
  input logic reset,
  input logic rx_ready,
  input logic [7:0] rx_data,
  input logic core_lock,
  output logic cmd_flag,
  output logic [CMD_WIDTH - 1:0] cmd_dec,
  output logic bram_sel
);

  // FSM Logic
  typedef enum logic [1:0] {IDLE, DECODING, DONE, LOCK} state;
  state current_state, next_state;

  // Logic
  logic cmd_store_flag, clear_old_cmd;
  // FSM
  always_ff @ (posedge clk) begin
    if(~reset) current_state <= IDLE;
    else current_state <= next_state;
  end

  always_comb begin
    next_state = IDLE;
    cmd_store_flag = 1'b0;
    cmd_flag = 1'b0;
    clear_old_cmd = 1'b0;
    case (current_state)

      IDLE: begin
        clear_old_cmd = 1'b1;
        if(rx_ready) begin
          cmd_store_flag = 1'b1;
          next_state = DECODING;
        end
      end

      DECODING: begin
        cmd_store_flag = 1'b1;
        next_state = DONE;
      end

      DONE: begin
        cmd_flag = 1'b1;
        next_state = DONE;
        if(core_lock) next_state = LOCK;
      end

      LOCK: begin
        if(core_lock) next_state = LOCK;
      end

    endcase
  end

  // DECODER
  always_ff @ (posedge clk) begin
    if(~reset | clear_old_cmd) begin
      cmd_dec <= 'd0;
      bram_sel <= 1'b0;
    end
    else begin
      if(cmd_store_flag) begin
        cmd_dec <= rx_data[2:0];
        bram_sel <= rx_data[4];
      end
      else begin
        cmd_dec <= cmd_dec;
        bram_sel <= bram_sel;
      end
    end
  end

endmodule
