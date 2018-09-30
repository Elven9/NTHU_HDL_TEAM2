`timescale 1ns/1ps

module Decode_and_Execute (op_code, rs, rt, rd);
    input [3-1:0] op_code;
    input [4-1:0] rs, rt;
    output [4-1:0] rd;

    // Variable
    wire [4-1:0] func1_rd;
    wire [4-1:0] func2_not_rt, func2_rd;
    wire [4-1:0] func3_rd, func4_rd, func5_rd, func6_rd, func7_rd;
    wire [8-1:0] func8_rd;

    // Functionality
    // 000
    Carry_Look_Ahead_Adder gate11(.a(rs), .b(rt), .cin(0), .sum(func1_rd));
    // 001
    not gate21(func2_not_rt, rt);
    Carry_Look_Ahead_Adder gate22(.a(rs), .b(func2_not_rt), .cin(0), .sum(func2_rd));
    // 010
    Carry_Look_Ahead_Adder gate31(.a(rs), .b(1), .cin(0), .sum(func3_rd));
    // 011
    NOR gate41(.in1(rs[0]), .in2(rt[0]), .out(func4_rd[0]));
    NOR gate42(.in1(rs[1]), .in2(rt[1]), .out(func4_rd[1]));
    NOR gate43(.in1(rs[2]), .in2(rt[2]), .out(func4_rd[2]));
    NOR gate44(.in1(rs[3]), .in2(rt[3]), .out(func4_rd[3]));
    // 100
    NAND gate51(.in1(rs[0]), .in2(rt[0]), .out(func5_rd[0]));
    NAND gate52(.in1(rs[1]), .in2(rt[1]), .out(func5_rd[1]));
    NAND gate53(.in1(rs[2]), .in2(rt[2]), .out(func5_rd[2]));
    NAND gate54(.in1(rs[3]), .in2(rt[3]), .out(func5_rd[3]));
    // 101
    and gate61(func6_rd[0], 1, rs[2]);
    and gate62(func6_rd[1], 1, rs[3]);
    and gate63(func6_rd[2], 0, 0);
    and gate64(func6_rd[3], 0, 0);
    // 110
    and gate71(func7_rd[0], 1, 0);
    and gate72(func7_rd[1], 1, rs[0]);
    and gate73(func7_rd[2], 1, rs[1]);
    and gate74(func7_rd[3], 1, rs[2]);
    // 111
    Multiplier gate81(.a(rs), .b(rt), .p(func8_rd));

    // Mux Definition
    Mux_8bit gate_mux1(op_code, func1_rd[0], func2_rd[0], func3_rd[0], func4_rd[0], func5_rd[0], func6_rd[0], func7_rd[0], func8_rd[0], rd[0]);
    Mux_8bit gate_mux2(op_code, func1_rd[1], func2_rd[1], func3_rd[1], func4_rd[1], func5_rd[1], func6_rd[1], func7_rd[1], func8_rd[1], rd[1]);
    Mux_8bit gate_mux3(op_code, func1_rd[2], func2_rd[2], func3_rd[2], func4_rd[2], func5_rd[2], func6_rd[2], func7_rd[2], func8_rd[2], rd[2]);
    Mux_8bit gate_mux4(op_code, func1_rd[3], func2_rd[3], func3_rd[3], func4_rd[3], func5_rd[3], func6_rd[3], func7_rd[3], func8_rd[3], rd[3]);

endmodule

module Mux_8bit (sel, in1, in2, in3, in4, in5, in6, in7, in8, out);
    input in1, in2, in3, in4, in5, in6, in7, in8;
    input [2:0] sel;
    output out;

    wire nSel_2, nSel_1, nSel_0;
    wire out1, out2, out3, out4, out5, out6, out7, out8;

    // Not operation.
    not gate_not1(nSel_2, sel[2]);
    not gate_not2(nSel_1, sel[1]);
    not gate_not3(nSel_0, sel[2]);

    // Mux operation.
    and gate_and1(out1, nSel_0, nSel_1, nSel_2, in1);
    and gate_and2(out2, sel[0], nSel_1, nSel_2, in2);
    and gate_and3(out3, nSel_0, sel[1], nSel_2, in3);
    and gate_and4(out4, sel[0], sel[1], nSel_2, in4);
    and gate_and5(out5, nSel_0, nSel_1, sel[2], in5);
    and gate_and6(out6, sel[0], nSel_1, sel[2], in6);
    and gate_and7(out7, nSel_0, sel[1], sel[2], in7);
    and gate_and8(out8, sel[0], sel[1], sel[2], in8);

    or gate_or(out, out1, out2, out3, out4, out5, out6, out7, out8);


endmodule // Mux_8bit

module Carry_Look_Ahead_Adder (a, b, cin, cout, sum);
    input [4-1:0] a, b;
    input cin;
    output cout;
    output [4-1:0] sum;

    wire [4-1:0] g, p;
    wire c1, c2, c3;

    Carry_Look_Ahead_Adder_Cout_Module gate_cout(
            .c0(cin),
            .g1(g[0]),
            .g2(g[1]),
            .g3(g[2]),
            .g4(g[3]),
            .p1(p[0]),
            .p2(p[1]),
            .p3(p[2]),
            .p4(p[3]),
            .c1(c1),
            .c2(c2),
            .c3(c3),
            .c4(cout)
        );

        Carry_Look_Ahead_Adder_Single_Adder gate1(.in1(a[0]), .in2(b[0]), .cin(cin), .p(p[0]), .g(g[0]), .sum(sum[0]));
        Carry_Look_Ahead_Adder_Single_Adder gate2(.in1(a[1]), .in2(b[1]), .cin(c1), .p(p[1]), .g(g[1]), .sum(sum[1]));
        Carry_Look_Ahead_Adder_Single_Adder gate3(.in1(a[2]), .in2(b[2]), .cin(c2), .p(p[2]), .g(g[2]), .sum(sum[2]));
        Carry_Look_Ahead_Adder_Single_Adder gate4(.in1(a[3]), .in2(b[3]), .cin(c3), .p(p[3]), .g(g[3]), .sum(sum[3]));

endmodule

module Carry_Look_Ahead_Adder_Single_Adder (in1, in2, cin, p, g, sum);
    input in1, in2, cin;
    output p, g, sum;

    and gate_and(g, in1, in2);
    or gate_or(p, in1, in2);

    wire xor1;

    XOR gate1(.in1(in1), .in2(in2), .out(xor1));
    XOR gate2(.in1(xor1), .in2(cin), .out(sum));

endmodule

module Carry_Look_Ahead_Adder_Cout_Module (c0, g1, g2, g3, g4, p1, p2, p3, p4, c1, c2, c3 ,c4);
    input c0, g1, g2, g3, g4, p1, p2, p3, p4;
    output c1, c2, c3, c4;

    wire and1_0;
    wire and2_0, and2_1;
    wire and3_0, and3_1, and3_2;
    wire and4_0, and4_1, and4_2, and4_3;

    // c1
    and gate11(and1_0, p1, c0);
    or gate12(c1, g1, and1_0);

    // c2
    and gate21(and2_0, p1, p2, c0);
    and gate22(and2_1, g1, p2);
    or gate23(c2, and2_0, and2_1, g2);

    // c3
    and gate31(and3_0, p1, p2, p3, c0);
    and gate32(and3_1, p2, p3, g1);
    and gate33(and3_2, p3, g2);
    or gate34(c3, and3_0, and3_1, and3_2, g3);

    // c4
    and gate41(and4_0, p1, p2, p3, p4, c0);
    and gate42(and4_1, p2, p3, p4, g1);
    and gate43(and4_2, p3, p4, g2);
    and gate44(and4_3, p4, g3);
    or gate45(c4, and4_0, and4_1, and4_2, and4_3, g4);

endmodule // Carry_Look_Ahead_Adder_Cout_Module

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

module NAND (in1, in2, out);
    input in1, in2;
    output out;

    wire and_out;
    and gate1(and_out, in1, in2);
    not gate2(out, and_out);

endmodule // NANDin1, in2, out

module NOR (in1, in2, out);
    input in1, in2;
    output out;

    wire nand_a, nand_b;
    wire nand_ab;

    NAND gate1(.in1(in1), .in2(in1), .out(nand_a));
    NAND gate2(.in1(in2), .in2(in2), .out(nand_b));
    NAND gate3(.in1(nand_a), .in2(nand_b), .out(nand_ab));
    NAND gate2(.in1(nand_ab), .in2(nand_ab), .out(out));

endmodule

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
  Carry_Look_Ahead_Adder gate1(p1[0], p1[1], 0, p2[0], p[1]);

  and and4(p2[1], a[2], b[0]);
  and and5(p2[2], a[1], b[1]);
  and and6(p2[3], a[0], b[2]);
  Carry_Look_Ahead_Adder gate2(p2[1], p2[2], p2[0], p3[0], p2[4]);
  Carry_Look_Ahead_Adder gate3(p2[3], p2[4], 0, p3[1], p[2]);

  and and7(p3[2], a[3], b[0]);
  and and8(p3[3], a[2], b[1]);
  and and9(p3[4], a[1], b[2]);
  and and10(p3[5], a[0], b[3]);
  Carry_Look_Ahead_Adder gate4(p3[2], p3[3], p3[0], p4[0], p3[6]);
  Carry_Look_Ahead_Adder gate5(p3[4], p3[6], p3[1], p4[1], p3[7]);
  Carry_Look_Ahead_Adder gate6(p3[5], p3[7], 0, p4[2], p[3]);

  and and11(p4[3], a[3], b[1]);
  and and12(p4[4], a[2], b[2]);
  and and13(p4[5], a[1], b[3]);
  Carry_Look_Ahead_Adder gate7(p4[3], 0, p4[0], p5[0], p4[6]);
  Carry_Look_Ahead_Adder gate8(p4[4], p4[6], p4[1], p5[1], p4[7]);
  Carry_Look_Ahead_Adder gate9(p4[5], p4[7], p4[2], p5[2], p[4]);

  and and14(p5[3], a[3], b[2]);
  and and15(p5[4], a[2], b[3]);
  Carry_Look_Ahead_Adder gate10(p5[3], p5[0], p5[1], p6[0], p5[5]);
  Carry_Look_Ahead_Adder gate11(p5[4], p5[5], p5[2], p6[1], p[5]);

  and and16(p6[2], a[3], b[3]);
  Carry_Look_Ahead_Adder gate12(p6[2], p6[0], p6[1], p[7], p[6]);
endmodule
