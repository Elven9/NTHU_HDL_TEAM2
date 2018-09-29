`timescale 1ns/1ps

module RippleCarryAdder_t;
reg [3:0] a, b;
wire [3:0] sum;
wire cout;
reg cin;

RippleCarryAdder fa (
  .a (a),
  .b (b),
  .cin(cin),
  .cout(cout),
  .sum(sum)
);

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
  #1 $finish;
end

endmodule