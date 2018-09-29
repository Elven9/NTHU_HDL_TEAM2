`timescale 1ns/1ps

module RippleCarryAdder (a, b, cin, cout, sum);
input [4-1:0] a, b;
input cin;
output [4-1:0] sum;
output cout;

wire cout12, cout23, cout34;
wire cin12, cin23, cin34;

Adder gate1(.a(a[0]), .b(b[0]), .cin(cin), .cout(cin12), .sum(sum[0]));
Adder gate2(.a(a[1]), .b(b[1]), .cin(cin12), .cout(cin23), .sum(sum[1]));
Adder gate3(.a(a[2]), .b(b[2]), .cin(cin23), .cout(cin34), .sum(sum[2]));
Adder gate4(.a(a[3]), .b(b[3]), .cin(cin34), .cout(cout), .sum(sum[3]));

endmodule

module Adder(a, b, cin, cout, sum);
input a, b, cin;
output cout, sum;

wire xor1;
wire and1, and2, and3;

XOR gate1(.in1(a), .in2(b), .out(xor1));
XOR gate2(.in1(xor1), .in2(cin), .out(sum));

and gate3(and1, a, b);
and gate4(and2, a, cin);
and gate5(and3, b, cin);

or gate6(cout, and1, and2, and3);

endmodule

module XOR (in1, in2, out);
input in1, in2;
output out;

wire not1, not2;
wire and1, and2;

not gate1(not1, in1);
not gate2(not2, in2);

and gate3(and1, not1, in2);
and gate4(and2, in1, not2);

or gate5(out, and1, and2);

endmodule