`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/08/2021 05:07:26 PM
// Design Name:
// Module Name: read_fsm_control
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


module read_fsm_control#(
  parameter ADDRESS_WIDTH = 3,
  parameter MEMORY_DEPTH = 8,
  parameter WAIT_READ_CYCLES = 3
  )
  (
  input logic clk,
  input logic reset,
  input logic enable,
  input logic next_read,
  input logic clear_address,
  output logic read_flag,
  output logic read_op_done,
  output logic[ADDRESS_WIDTH-1:0] read_address_a,
  output logic[ADDRESS_WIDTH-1:0] read_address_b
  );



  logic read_enable,max_address, address_enable;

  // ADDRESS
  logic [ADDRESS_WIDTH-1:0] common_address;
  // MAIN FSM
  typedef enum logic [2:0] {IDLE, FETCH, READED, CHECK, ADDRESS, DONE} state;
  state pr_state, nx_state;

  always_ff @ (posedge clk) begin
    if(~reset) pr_state <= IDLE;
    else pr_state <= nx_state;
  end

  always_comb begin
    nx_state = IDLE;
    read_flag = 1'b0;
    read_enable = 1'b0;
    address_enable = 1'b0;
    read_op_done = 1'b0;
    case (pr_state)

      IDLE: if (enable) nx_state = FETCH;

      FETCH: begin
        read_enable = 1'b1;
        if(read_done) nx_state = READED;
        else nx_state = FETCH;
      end

      READED: begin
        read_flag = 1'b1;
        if(next_read) nx_state = CHECK;
        else nx_state = READED;
      end

      CHECK: begin
        if(max_address) nx_state = DONE;
        else nx_state = ADDRESS;
      end

      ADDRESS: begin
        address_enable = 1'b1;
        nx_state = FETCH;
      end

      DONE: begin
        nx_state = DONE;
        read_op_done = 1'b1;
        if (~enable) nx_state = IDLE;
      end
    endcase
  end

  // WAIT - READ LOGIC
  read_module #(
  .ADDRESS_WIDTH(ADDRESS_WIDTH),
  .MEMORY_DEPTH(MEMORY_DEPTH),
  .WAIT_READ_CYCLES(WAIT_READ_CYCLES)
  )
  READ
  (
    .clk(clk),
    .reset(reset),
    .enable(read_enable),
    .read_done(read_done)
  );

  // ADDRESS HANDLER
  address_counter #(
      .MEMORY_DEPTH(MEMORY_DEPTH),
      .ADDRESS_WIDTH(ADDRESS_WIDTH)
      )
      READ_ADDRESS
      (
      .clk(clk),
      .reset(~reset),
      .enable(address_enable),
      .clear(read_op_done | clear_address),
      .address(common_address),
      .max_address(max_address),
      .over_address()
      );

  assign read_address_a = common_address;
  assign read_address_b = common_address;

endmodule
