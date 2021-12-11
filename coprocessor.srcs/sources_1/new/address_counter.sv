`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/28/2021 01:17:15 AM
// Design Name:
// Module Name: address_counter
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


module address_counter  #(
    parameter MEMORY_DEPTH = 8,
    parameter ADDRESS_WIDTH = 3
    )(
    input logic clk,
    input logic reset,
    input logic enable,
    input logic clear,
    output logic[ADDRESS_WIDTH-1:0] address,
    output logic max_address,
    output logic over_address
    );

    always_ff @ (posedge clk) begin
      if(reset || clear) begin
        address <= 'd0;
        over_address <= 1'b0;
      end
      else begin
        if(enable) begin
          if(address == MEMORY_DEPTH -1) begin
            address <= 'd0;
            over_address <= 1'b1;
          end
          else begin
            address <= address + 'd1;
            over_address <= 1'b0;
          end
        end
        else begin
          address <= address;
          over_address <= 1'b0;
        end
      end
    end
    //  --> Address max flag
    always_comb begin
      if (address == MEMORY_DEPTH - 1) max_address = 1;
      else max_address = 0;
    end
endmodule
