`timescale 1ns/1ps

module Comparator_3bits (a, b, a_lt_b, a_gt_b, a_eq_b);
input [3-1:0] a, b;
output a_lt_b, a_gt_b, a_eq_b;

// Wire Declaration.
wire less_bit1, less_bit2, less_bit3, less_flag1, less_flag2, less_flag3, less_ans_bit1, less_ans_bit2 less_ans_bit3;
wire greater_bit1, greater_bit2, greater_bit3, greater_flag1, greater_flag2, greater_flag3, greater_ans_bit1, greater_ans_bit2, greater_ans_bit3;
wire equal_bit1, equal_bit2, equal_bit3;

// Implement a_lt_b.
Less less_gate1(.a(a[2]), .b(b[2]), .out(less_bit1), .flag(less_flag1));
Less less_gate2(.a(a[1]), .b(b[1]), .out(less_bit2), .flag(less_flag2));
Less less_gate3(.a(a[0]), .b(b[0]), .out(less_bit3), .flag(less_flag3));

and less_gate5(less_ans_bit1, less_flag1, less_bit2);
and less_gate6(less_ans_bit2, less_ans_bit3, less_bit3);
and less_gate7(less_ans_bit3, less_flag1, less_flag2);

or less_gate4(a_lt_b, less_bit1, less_ans_bit1, less_ans_bit2);

// Implement a_gt_b.
Greater greater_gate1(.a(a[2]), .b(b[2]), .out(greater_bit1), .flag(greater_flag1));
Greater greater_gate2(.a(a[1]), .b(b[1]), .out(greater_bit2), .flag(greater_flag2));
Greater greater_gate3(.a(a[0]), .b(b[0]), .out(greater_bit3), .flag(greater_flag3));

and greater_gate5(greater_ans_bit1, greater_flag1, greater_bit2);
and greater_gate6(greater_ans_bit2, greater_ans_bit3, greater_bit3);
and greater_gate7(greater_ans_bit3, greater_flag1, greater_flag2);

or greater_gate4(a_gt_b, greater_bit1, greater_ans_bit1, greater_ans_bit2);

// Implement a_eq_b.
Equal equal_gate1(.a(a[2]), .b(b[2]), .out(equal_bit1));
Equal equal_gate2(.a(a[1]), .b(b[1]), .out(equal_bit2));
Equal equal_gate3(.a(a[0]), .b(b[0]), .out(equal_bit3));

and equal_gate4(a_eq_b, equal_bit1, equal_bit2, equal_bit3);

endmodule

module Greater (a, b, out, flag);
input a, b;
output out, flag;

wire xor1;

XOR gate1(.in1(a), .in2(b), .out(xor1));
and gate2(out, xor1, a);

not gate3 (flag, xor1);

endmodule

module Less (a, b, out, flag);
input a, b;
output out, flag;

wire xor1;

XOR gate1(.in1(a), .in2(b), .out(xor1));
and gate2(out, xor1, b);

not gate3 (flag, xor1);

endmodule

module Equal (a, b, out);
input a, b;
output out;

wire xor1;

XOR gate1(.in1(a), .in2(b), .out(xor1));
not gate2(out, xor1);

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
