`timescale 1ns/1ps

module RippleCarryAdder_t(Port, Dp);
output [6:0] Port;
output Dp;

reg [3:0] a, b;
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

assign Dp = cout;

initial begin
  a = 4;
  b = 4;
  cin = 1;

  #3 begin
    a = 2;
    b = 5;
    cin = 0;
  end
  #3 begin
    a = 3;
    b = 1;
    cin = 1;
  end
  #3 begin
    a = 14;
    b = 2;
    cin = 1;
   end
  #1 $finish;
end

endmodule
