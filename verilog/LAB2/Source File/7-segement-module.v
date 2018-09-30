module Segment_7_bit_display (Sel, Port);
    input [3:0] Sel;
    output [6:0] Port;

    // Port : 6 5 4 3 2 1 0
    // map  : G F E D C B A

    // Sel  : 3 2 1 0
    // map  : d c b a

    // Not Select Wire declartion
    wire not_d, not_c, not_b, not_a;

    // Port Wire Declariton.
    wire wire_A_1, wire_A_2, wire_A_3, wire_A_4;
    wire wire_B_1, wire_B_2, wire_B_3, wire_B_4, wire_B_5;
    wire wire_C_1, wire_C_2, wire_C_3;
    wire wire_D_1, wire_D_2, wire_D_3, wire_D_4;
    wire wire_E_1, wire_E_2, wire_E_3;
    wire wire_F_1, wire_F_2, wire_F_3, wire_F_4;
    wire wire_G_1, wire_G_2, wire_G_3, wire_G_4;

    // Not Setting.
    not gate_not_1(not_d, Sel[3]);
    not gate_not_2(not_c, Sel[2]);
    not gate_not_3(not_b, Sel[1]);
    not gate_not_4(not_a, Sel[0]);

    // Port A.
    and gateA_1(wire_A_1, Sel[3], not_c, Sel[1], Sel[0]);
    and gateA_2(wire_A_2, Sel[3], Sel[2], not_b, Sel[0]);
    and gateA_3(wire_A_3, not_d, Sel[2], not_b, not_a);
    and gateA_4(wire_A_4, not_d, not_c, not_b, Sel[0]);
    or gateA_5(Port[0], wire_A_1, wire_A_2, wire_A_3, wire_A_4);

    // Port B.
    and gateB_1(wire_B_1, Sel[3], Sel[1], Sel[0]);
    and gateB_2(wire_B_2, Sel[3], Sel[2], Sel[1]);
    and gateB_3(wire_B_3, Sel[2], Sel[1], not_a);
    and gateB_4(wire_B_4, not_d, Sel[2], not_b, Sel[0]);
    and gateB_5(wire_B_5, Sel[3], Sel[2], not_a);
    or gateB_6(Port[1], wire_B_1, wire_B_2, wire_B_3, wire_B_4, wire_B_5);

    // Port C.
    and gateC_1(wire_C_1, Sel[3], Sel[2], Sel[1]);
    and gateC_2(wire_C_2, Sel[3], Sel[2], not_a);
    and gateC_3(wire_C_3, not_d, not_c, Sel[1], not_a);
    or gateC_4(Port[2], wire_C_1, wire_C_2, wire_C_3);

    // Port D.
    and gateD_1(wire_D_1, Sel[2], Sel[1], Sel[0]);
    and gateD_2(wire_D_2, not_d, Sel[2], Sel[1], Sel[0]);
    and gateD_3(wire_D_3, not_d, not_c, not_b, Sel[0]);
    and gateD_4(wire_D_4, Sel[3], not_c, Sel[1], not_a);
    or gate_D_5(Port[3], wire_D_1, wire_D_2, wire_D_3, wire_D_4);

    // Port E.
    and gate_E_1(wire_E_1, not_d, Sel[0]);
    and gate_E_2(wire_E_2, not_c, not_b, Sel[0]);
    and gate_E_3(wire_E_3, not_d, Sel[2], not_b);
    or gate_E_4(Port[4], wire_E_1, wire_E_2, wire_E_3);

    // Port F.
    and gate_F_1(wire_F_1, Sel[3], Sel[2], not_b, Sel[0]);
    and gate_F_2(wire_F_2, not_d, Sel[1], Sel[0]);
    and gate_F_3(wire_F_3, not_d, not_c, Sel[0]);
    and gate_F_4(wire_F_4, not_d, not_c, Sel[1]);
    or gate_F_5(Port[5], wire_F_1, wire_F_2, wire_F_3, wire_F_4);

    // Port G.
    and gate_G_1(wire_G_1, not_d, not_c, not_b);
    and gate_G_2(wire_G_2, not_d, Sel[2], Sel[1], Sel[0]);
    and gate_G_3(wire_G_3, Sel[3], Sel[2], not_b, not_a);
    and gate_G_4(wire_G_4, not_d, not_c, not_a);
    or gate_G_4(Port[6], wire_G_1, wire_G_2, wire_G_3, wire_G_4);

endmodule // Segment_7_bit_display
