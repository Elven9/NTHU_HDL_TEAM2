`timescale 1ns/1ps

module Multiplier (a, b, p);
  input [4-1:0] a, b;
  output [8-1:0] p;

  wire [2-1:0] p1;
  wire [5-1:0] p2;
  wire [8-1:0] p3;
  wire [8-1:0] p4;
  wire [6-1:0] p5;
  wire [3-1:0] p6;
  and and1(p[0], a[0], b[0]);

  and and2(p1[0], a[1], b[0]);
  and and3(p1[1], a[0], b[1]);
  Adder gate1(p1[0], p1[1], 0, p2[0], p[1]);

  and and4(p2[1], a[2], b[0]);
  and and5(p2[2], a[1], b[1]);
  and and6(p2[3], a[0], b[2]);
  Adder gate2(p2[1], p2[2], p2[0], p3[0], p2[4]);
  Adder gate3(p2[3], p2[4], 0, p3[1], p[2]);

  and and7(p3[2], a[3], b[0]);
  and and8(p3[3], a[2], b[1]);
  and and9(p3[4], a[1], b[2]);
  and and10(p3[5], a[0], b[3]);
  Adder gate4(p3[2], p3[3], p3[0], p4[0], p3[6]);
  Adder gate5(p3[4], p3[6], p3[1], p4[1], p3[7]);
  Adder gate6(p3[5], p3[7], 0, p4[2], p[3]);

  and and11(p4[3], a[3], b[1]);
  and and12(p4[4], a[2], b[2]);
  and and13(p4[5], a[1], b[3]);
  Adder gate7(p4[3], 0, p4[0], p5[0], p4[6]);
  Adder gate8(p4[4], p4[6], p4[1], p5[1], p4[7]);
  Adder gate9(p4[5], p4[7], p4[2], p5[2], p[4]);

  and and14(p5[3], a[3], b[2]);
  and and15(p5[4], a[2], b[3]);
  Adder gate10(p5[3], p5[0], p5[1], p6[0], p5[5]);
  Adder gate11(p5[4], p5[5], p5[2], p6[1], p[5]);

  and and16(p6[2], a[3], b[3]);
  Adder gate12(p6[2], p6[0], p6[1], p[7], p[6]);
endmodule

module Adder(a, b, cin, cout, sum);
  input a, b, cin;
  output cout, sum;

  wire xor1;
  wire and1, and2, and3;

  Xor gate1(.a(a), .b(b), .out(xor1));
  Xor gate2(.a(xor1), .b(cin), .out(sum));

  and gate3(and1, a, b);
  and gate4(and2, a, cin);
  and gate5(and3, b, cin);

  or gate6(cout, and1, and2, and3);
endmodule

module Xor (a, b, out);
  input a, b;
  output out;

  wire nA, nB;
  wire and1, and2;

  not gate1(nA, a);
  not gate2(nB, b);

  and gate3(and1, nA, b);
  and gate4(and2, a, nB);

  or gate5(out, and1, and2);
endmodule
