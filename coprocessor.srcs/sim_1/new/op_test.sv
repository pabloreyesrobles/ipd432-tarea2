`timescale 1ns / 1ps

module op_testbench ();
  logic [7:0] data_a, data_b;
  logic [15:0] data_c;

  initial begin
    data_a = 8'd127;
    data_b = 8'd255;
    
    #10 data_c = data_a - data_b;
    #10 if (data_c[15] == 1) data_c = -data_c;
    #10 data_a = -8'd13;
    #10 if (data_a[7] == 1) data_c = (-data_a[7:0]) * (-data_a[7:0]);
        else data_c = data_a * data_a;
  end

endmodule