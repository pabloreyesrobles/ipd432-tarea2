`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/23/2021 06:56:08 PM
// Design Name:
// Module Name: mem_uart_test
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


module mem_uart_test(
    input logic CLK100MHZ,
    input logic CPU_RESETN,
    input logic UART_TXD_IN,
    output logic [1:0] LED,
    output logic[2:0] JA,
    output logic UART_RXD_OUT
    );
    //Logic analizer interface
    assign JA[0] = UART_TXD_IN;
    assign JA[1] = UART_RXD_OUT;
    // ResetN to Reset
    logic reset;
    assign reset = !CPU_RESETN;
    // Memory Logic
    localparam  MEMORY_DEPTH = 1024; // 8 For testing
    localparam  ADDRESS_WIDTH = $clog2(MEMORY_DEPTH);
    localparam  WAIT_READ_CYCLES = 3;
    logic [ADDRESS_WIDTH-1:0] write_address;
    logic [ADDRESS_WIDTH-1:0] read_address;
    // FSM Control logic
    typedef enum logic [1:0] {IDLE, WRITE, READ} state;
    state pr_state, nx_state;
    logic write_done, read_done, rx_ready, enable_write, enable_read, write_enable, tx_start, tx_busy;
    // UART
    logic [7:0] rx_data;
    logic [7:0] tx_data;


    //FSM_Control
    always_ff @ (posedge CLK100MHZ) begin
      if(reset) pr_state <= IDLE;
      else pr_state <= nx_state;
    end

    always_comb begin
      nx_state = IDLE;
      enable_write = 1'b0;
      enable_read = 1'b0;
      case(pr_state)

        IDLE: begin
          if(rx_ready) nx_state = WRITE;
        end

        WRITE: begin
          enable_write = 1'b1;
          if(write_done) nx_state = READ;
          else nx_state = WRITE;
        end

        READ: begin
          enable_read = 1'b1;
          if(read_done) nx_state = IDLE;
          else nx_state = READ;
        end
      endcase
    end

    // FSM WRITE
    write_control #(
    .MEMORY_DEPTH(MEMORY_DEPTH),
    .ADDRESS_WIDTH(ADDRESS_WIDTH)
    )
    FSM_WRITE
    (
    .clk(CLK100MHZ),
    .reset(reset),
    .enable(enable_write),
    .rx_ready(rx_ready),
    .write_enable(write_enable),
    .done(write_done),
    .address(write_address)
    );

    // FSM READ & TX
    read_tx #(
      .MEMORY_DEPTH(MEMORY_DEPTH),
      .ADDRESS_WIDTH(ADDRESS_WIDTH),
      .WAIT_READ_CYCLES(WAIT_READ_CYCLES)
    )
    FSM_READ_TX
    (
      .clk(CLK100MHZ),
      .reset(reset),
      .enable(enable_read),
      .tx_busy(tx_busy),
      .read_address(read_address),
      .done(read_done),
      .tx_start(tx_start)
    );




    // Memory block
    blk_mem_gen_0 BRAMA (
      .clka(CLK100MHZ),    // input wire clka
      .wea(write_enable),      // input wire [0 : 0] wea
      .addra(write_address),  // input wire [9 : 0] addra
      .dina(rx_data),    // input wire [7 : 0] dina
      .clkb(CLK100MHZ),    // input wire clkb
      .addrb(read_address),  // input wire [9 : 0] addrb
      .doutb(tx_data)  // output wire [7 : 0] doutb
    );

    //UART
    uart_basic#(
        .CLK_FREQUENCY(100000000),
        .BAUD_RATE(115200)
    )
    UART(
    .clk(CLK100MHZ),
    .reset(reset),
    .rx(UART_TXD_IN),
    .rx_data(rx_data),
    .rx_ready(rx_ready),
    .tx(UART_RXD_OUT),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx_busy(tx_busy)
    );

    always_ff @ (posedge CLK100MHZ) begin
      if(reset) begin
        LED[0] <= 1'b0;
        LED[1] <= 1'b0;
      end
      else begin
        if(write_done) begin
          LED[0] <= 1'b1;
          LED[1] <= LED[1];
        end
        else if(pr_state == READ) begin
          LED[0] <= LED[0];
          LED[1] <= 1'b1;
        end
        else begin
          LED[0] <= LED[0];
          LED[1] <= LED[1];
        end
      end
    end
endmodule
