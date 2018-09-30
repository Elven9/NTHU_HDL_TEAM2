`timescale 1ns/1ps

module DecoderTest;
  reg [3-1:0] code = 3'd0;
  reg [3:0] rs, rt;
  wire [3:0] rd;

  Decode_and_Execute test (
      .op_code(code),
      .rs(rs),
      .rt(rt),
      .rd(rd)
      );

  initial begin
    rs = 2;
    rt = 4;
    repeat (2 ** 3) begin
      #1 code = code + 1'b1;
    end
    #1 $finish;
  end
endmodule
