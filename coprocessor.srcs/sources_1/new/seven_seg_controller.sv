module seven_seg_controller
#(parameter
  CLK_FREQUENCY = 'd100_000_000
)
(
  input   logic         clk,
  input   logic         resetN,
  input   logic [31:0]  data,
  output  logic [6:0]   cat_out,
  output  logic [7:0]   an_out
);
  
  logic [7:0]   segment_state;
  logic [31:0]  segment_counter;
  logic [3:0]   routed_vals;
  logic [6:0]   led_out;
  
  // assign cat_out = ~led_out;
  assign an_out = ~segment_state;
  
  localparam FRAME_CLK = (CLK_FREQUENCY >> 10) == 0 ? 1 : CLK_FREQUENCY >> 10;
  
  always_comb begin
    case(segment_state)
      8'b0000_0001: routed_vals = data[3:0];
      8'b0000_0010: routed_vals = data[7:4];
      8'b0000_0100: routed_vals = data[11:8];
      8'b0000_1000: routed_vals = data[15:12];
      8'b0001_0000: routed_vals = data[19:16];
      8'b0010_0000: routed_vals = data[23:20];
      8'b0100_0000: routed_vals = data[27:24];
      8'b1000_0000: routed_vals = data[31:28];
      default:      routed_vals = data[3:0];       
    endcase
  end

  binary_to_seven_seg my_converter (.val_in(routed_vals), .led_out(cat_out));
  
  always_ff @(posedge clk)begin
    if (~resetN) begin
      segment_state <= 8'b0000_0001;
      segment_counter <= 32'b0;
    end 
    else begin
      if (segment_counter >= FRAME_CLK) begin
        segment_counter <= 32'd0;
        segment_state <= {segment_state[6:0], segment_state[7]};
      end 
      else begin
        segment_counter <= segment_counter + 1;
      end
    end
  end
      
endmodule //seven_seg_controller

module binary_to_seven_seg
(
  input   logic [3:0] val_in,
  output  logic [6:0] led_out
);

  always_comb begin
    case (val_in)
      4'd0: led_out = 7'b1000000;
      4'd1: led_out = 7'b1111001;
      4'd2: led_out = 7'b0100100;
      4'd3: led_out = 7'b0110000;
      4'd4: led_out = 7'b0011001;
      4'd5: led_out = 7'b0010010;
      4'd6: led_out = 7'b0000010;
      4'd7: led_out = 7'b1111000;
      4'd8: led_out = 7'b0000000;
      4'd9: led_out = 7'b0010000;
      'hA:  led_out = 7'b0001000; // A
      'hB:  led_out = 7'b0001100; // P
      'hC:  led_out = 7'b1111111;
      'hD:  led_out = 7'b0001001; // H
      'hE:  led_out = 7'b1000111; // L
      'hF:  led_out = 7'b0001000; // A
      default: led_out = 7'b0000000; // U
    endcase    
  end

endmodule