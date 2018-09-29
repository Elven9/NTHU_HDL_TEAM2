`timescale 1ns/1ps

module NOR_Implement_t;
  reg [4-1:0] din = 4'd0;
  wire [4-1:0] dout;
  Binary_to_Grey b1 (
    .din (din),
    .dout (dout)
  );

  initial begin
    repeat (2 ** 4) begin
      #1 {din} = {din} + 1'b1;
    end
    #1 $finish;
  end
endmodule
