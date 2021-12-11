`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/08/2021 06:35:09 PM
// Design Name:
// Module Name: operations_block
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


module operations_block #(
  parameter MEMORY_DEPTH = 8,
  parameter CMD_WIDTH = 3
  )
  (
  input logic clk,
  input logic reset,
  input logic [CMD_WIDTH-1:0] cmd_dec,
  input logic bram_sel,
  input logic [7:0] A,
  input logic [7:0] B,
  input logic tx_busy,
  input logic read_flag,
  output logic next_read,
  output logic tx_start,
  output logic [7:0] tx_data,
  output logic [6:0] CAT,
  output logic [7:0] AN
  );

  enum logic [CMD_WIDTH-1:0] {WRITE_CMD = 3'd1, READ_CMD = 3'd2, SUM_CMD = 3'd3, AVG_CMD = 3'd4, MAN_CMD = 3'd5, EUC_CMD = 3'd6} commands;

  logic done, sum_enable, avg_enable, tx_enable, sum_tx_enable, sum_done, avg_tx_enable, avg_done, man_enable, man_tx_enable, man_done, man_next_data, man_read_flag, euc_enable, euc_tx_enable, euc_done, euc_next_data, euc_read_flag;
  logic [7:0] sum_tx_data, avg_tx_data, man_tx_data, euc_tx_data;

  logic [23:0] man_value;
  logic [15:0] euc_value;
  logic [31:0] seven_seg_data;

  always_comb begin
    tx_enable = 1'b0;
    sum_enable = 1'b0;
    avg_enable = 1'b0;
    man_enable = 1'b0;
    man_read_flag = 1'b0;
    euc_enable = 1'b0;
    euc_read_flag = 1'b0;
    next_read = 1'b0;
    tx_data = 'd0;
    case (cmd_dec)
      READ_CMD: begin
        tx_enable = read_flag;
        next_read = done;
        if(bram_sel) tx_data = B;
        else tx_data = A;
      end

      SUM_CMD: begin
        sum_enable = read_flag;
        tx_enable = sum_tx_enable;
        next_read = sum_done;
        tx_data = sum_tx_data;
      end

      AVG_CMD: begin
        avg_enable = read_flag;
        tx_enable  = avg_tx_enable;
        next_read = avg_done;
        tx_data = avg_tx_data;
      end

      MAN_CMD: begin
        man_enable = 1'b1;
        man_read_flag = read_flag;
        tx_enable = man_tx_enable;
        next_read = man_next_data;
        tx_data = man_tx_data;
      end

      EUC_CMD: begin
        euc_enable = 1'b1;
        euc_read_flag = read_flag;
        tx_enable = euc_tx_enable;
        next_read = euc_next_data;
        tx_data = euc_tx_data;
      end


    endcase
  end

  logic [23:0] last_man_value;
  logic [23:0] last_euc_value;

  logic [19:0] man_bcd_out;
  logic [15:0] euc_bcd_out;

  logic man_conv_bcd, man_done_bcd;
  logic euc_conv_bcd, euc_done_bcd;

  always_ff @(posedge clk) begin
    if (~reset) seven_seg_data <= 32'hCCCCCCCC;

    if (man_done) begin
      last_man_value <= man_value;
      man_conv_bcd <= 1'b1;
    end 
    else man_conv_bcd <= 1'b0;

    if (euc_done) begin
      last_euc_value <= euc_value;
      euc_conv_bcd <= 1'b1;
    end 
    else euc_conv_bcd <= 1'b0;

    if (man_done_bcd) begin
      seven_seg_data[19:0] <= man_bcd_out;
      seven_seg_data[31:20] <= 'hCCC;
    end

    if (euc_done_bcd) begin
      seven_seg_data[15:0] <= euc_bcd_out;
      seven_seg_data[31:16] <= 'hCCCC;
    end
  end


  // UART- TX - Control
  tx_control TX_CONTROL(
    .clk(clk),
    .reset(reset),
    .enable(tx_enable),
    .tx_busy(tx_busy),
    .tx_start(tx_start),
    .done(done)
  );

  // SUM_CTRL_SEND
  sum_wrapper SUM_TX_CTRL
  (
    .clk(clk),
    .reset(reset),
    .enable(sum_enable),
    .A(A),
    .B(B),
    .tx_done(done),
    .tx_enable(sum_tx_enable),
    .op_done(sum_done),
    .tx_data(sum_tx_data)
  );

  // AVG_CTRL_SEND
  avg_wrapper AVG_TX_CTRL
  (
    .clk(clk),
    .reset(reset),
    .enable(avg_enable),
    .A(A),
    .B(B),
    .tx_done(done),
    .tx_enable(avg_tx_enable),
    .op_done(avg_done),
    .tx_data(avg_tx_data)
  );

  man_wrapper #(
  .MEMORY_DEPTH(MEMORY_DEPTH)
  )
  MAN_TX_CTRL
  (
    .clk(clk),
    .reset(reset),
    .enable(man_enable),
    .read_flag(man_read_flag),
    .A(A),
    .B(B),
    .tx_done(done),
    .tx_enable(man_tx_enable),
    .op_done(man_done),
    .tx_data(man_tx_data),
    .next_data(man_next_data),
    .value(man_value)
  );

  euc_wrapper #(
  .MEMORY_DEPTH(MEMORY_DEPTH)
  )
  EUC_TX_CTRL
  (
    .clk(clk),
    .reset(reset),
    .enable(euc_enable),
    .read_flag(euc_read_flag),
    .A(A),
    .B(B),
    .tx_done(done),
    .tx_enable(euc_tx_enable),
    .op_done(euc_done),
    .tx_data(euc_tx_data),
    .next_data(euc_next_data),
    .sqrt_out(euc_value)
  );

  Binary_to_BCD #(
    .INPUT_WIDTH(24),
    .DECIMAL_DIGITS(5)
  )
  man_bcd
  (
    .i_Clock(clk),
    .i_Binary(man_value),
    .i_Start(man_conv_bcd),
    .o_BCD(man_bcd_out),
    .o_DV(man_done_bcd)
  );

  Binary_to_BCD #(
    .INPUT_WIDTH(16),
    .DECIMAL_DIGITS(4)
  )
  euc_bcd
  (
    .i_Clock(clk),
    .i_Binary(euc_value),
    .i_Start(euc_conv_bcd),
    .o_BCD(euc_bcd_out),
    .o_DV(euc_done_bcd)
  );

  seven_seg_controller #(
    .CLK_FREQUENCY('d50_000_000)
  )
  seven_seg_mod
  (
    .clk,
    .resetN(reset),
    .data(seven_seg_data),
    .cat_out(CAT),
    .an_out(AN)
  );

  // ila_0 your_instance_name (
  //    .clk(clk), // input wire clk


  //    .probe0(man_enable), // input wire [0:0]  probe0  
  //    .probe1(man_done), // input wire [0:0]  probe1 
  //    .probe2(euc_enable), // input wire [23:0]  probe2 
  //    .probe3(euc_done), // input wire [10:0]  probe3
  //    .probe4(global_count)
  // );

  // logic [32:0] global_count;
  // always_ff @(posedge clk) begin
  //   if (~reset) global_count <= 0;
  //   global_count <= global_count + 1;
  // end
  
endmodule
