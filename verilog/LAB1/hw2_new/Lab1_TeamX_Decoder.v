`timescale 1ns/1ps

module Decoder (din, dout);
  input [4-1:0] din;
  output [16-1:0] dout;

  wire [4-1:0] nDin;

  not n1(nDin[3], din[3]);
  not n2(nDin[2], din[2]);
  not n3(nDin[1], din[1]);
  not n4(nDin[0], din[0]);

  and and1 (dout[8] , nDin[3], nDin[2], nDin[1], nDin[0]);
  and and2 (dout[9] , nDin[3], nDin[2], nDin[1], din[0] );
  and and3 (dout[10], nDin[3], nDin[2], din[1] , nDin[0]);
  and and4 (dout[11], nDin[3], nDin[2], din[1] , din[0] );
  and and5 (dout[12], nDin[3], din[2] , nDin[1], nDin[0]);
  and and6 (dout[13], nDin[3], din[2] , nDin[1], din[0] );
  and and7 (dout[14], nDin[3], din[2] , din[1] , nDin[0]);
  and and8 (dout[15], nDin[3], din[2] , din[1] , din[0] );
  and and9 (dout[7] , din[3] , nDin[2], nDin[1], nDin[0]);
  and and10(dout[6] , din[3] , nDin[2], nDin[1], din[0] );
  and and11(dout[5] , din[3] , nDin[2], din[1] , nDin[0]);
  and and12(dout[4] , din[3] , nDin[2], din[1] , din[0] );
  and and13(dout[3] , din[3] , din[2] , nDin[1], nDin[0]);
  and and14(dout[2] , din[3] , din[2] , nDin[1], din[0] );
  and and15(dout[1] , din[3] , din[2] , din[1] , nDin[0]);
  and and16(dout[0] , din[3] , din[2] , din[1] , din[0] );

endmodule
