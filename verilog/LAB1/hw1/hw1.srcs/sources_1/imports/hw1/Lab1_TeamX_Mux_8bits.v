`timescale 1ns/1ps

module Mux_8bits (a, b, sel, f);
input [8-1:0] a, b;
input sel;
output [8-1:0] f;

Selector sel1(a[7], b[7], sel, f[7]);
Selector sel2(a[6], b[6], sel, f[6]);
Selector sel3(a[5], b[5], sel, f[5]);
Selector sel4(a[4], b[4], sel, f[4]);
Selector sel5(a[3], b[3], sel, f[3]);
Selector sel6(a[2], b[2], sel, f[2]);
Selector sel7(a[1], b[1], sel, f[1]);
Selector sel8(a[0], b[0], sel, f[0]);

endmodule


module Selector (a, b, sel, f);
input a, b, sel;
output f;

not not1(nSel, sel);
and andTop(topStream, a, nSel);
and andBottom(bottomStream, b, sel);
or or1(f, topStream, bottomStream);

endmodule
