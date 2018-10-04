`timescale 1ns/1ps

module RippleCarryAdder_FPGA(a, b, Port, Dp, control);
output [6:0] Port;
output Dp;
output [3:0] control;

input [3:0] a, b;
wire [3:0] sum;
wire cout;
reg cin;

Carry_Look_Ahead_Adder fa (
  .a (a),
  .b (b),
  .cin(cin),
  .cout(cout),
  .sum(sum)
);

Segment_7_bit_display segment (
    .Sel(sum),
    .Port(Port)
);

not gate102(Dp, cout);
assign control = 4'b1110;

endmodule
