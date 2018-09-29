`timescale 1ns/1ps

module DecoderTest;
  reg [4-1:0] din = 4'd0;
  wire [16-1:0] dout;

  Decoder d1 (
    .din (din),
    .dout (dout)
  );

  initial begin
    repeat (2 ** 4) begin
      #1 din = din + 1'b1;
    end
    #1 $finish;
  end
endmodule
