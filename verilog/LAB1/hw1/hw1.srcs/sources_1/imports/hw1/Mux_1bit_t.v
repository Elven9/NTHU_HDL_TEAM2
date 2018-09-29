`timescale 1ns/1ps

module Mux_8bits_t;
reg [7:0] a = 8'b10110010;
reg [7:0] b = 8'b01000111;
reg sel = 1'b0;
wire [7:0] f;

Mux_8bits m1 (
  .a (a),
  .b (b),
  .sel (sel),
  .f (f)
);

initial begin
  repeat (2 ** 3) begin
    #1 {sel, a, b} = {sel, a, b} + 1'b1;
  end
  #1 $finish;
end
endmodule
