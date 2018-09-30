`timescale 1ns/1ps

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
