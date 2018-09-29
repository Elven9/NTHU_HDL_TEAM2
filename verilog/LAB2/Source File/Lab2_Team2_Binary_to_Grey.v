`timescale 1ns/1ps

module Binary_to_Grey (din, dout);
  input [4-1:0] din;
  output [4-1:0] dout;

  Xor xor1(dout[0], din[1], din[0]);
  Xor xor2(dout[1], din[2], din[1]);
  Xor xor3(dout[2], din[3], din[2]);
  Xor xor4(dout[3], 0, din[3]);
endmodule

module Xor (out, a, b);
  input a, b;
  output out;
  wire nA, nB, upper, lower;

  not not1(nA, a);
  not not2(nB, b);
  and and1(upper, nA, b);
  and and2(lower, a , nB);
  or or1(out, upper, lower);
endmodule
