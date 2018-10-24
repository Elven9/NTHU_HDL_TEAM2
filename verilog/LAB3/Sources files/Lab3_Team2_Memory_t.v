`timescale 1ns/1ps

module memory_t;
  reg clk, ren, wen;
  reg [7:0] din;
  reg [5:0] addr;
  wire [7:0] dout;

  Memory memory(
    .clk(clk),
    .ren(ren),
    .wen(wen),
    .din(din),
    .addr(addr),
    .dout(dout)
  );

  always #2 clk = ~clk;

  initial begin
    clk = 1'b1;

    // 1.
    ren = 1'b1;
    wen = 1'b1;
    din = 8'd0;
    addr = 6'd0;

    // 2.
    #5
    wen = 1'b0;
    ren = 1'b1;
    din = 8'd11;
    addr = 6'd1;

    // 3.
    #5
    wen = 1'b0;
    ren = 1'b1;
    din = 8'd31;
    addr = 6'd31;

    // 4.
    #5
    wen = 1'b0;
    ren = 1'b1;
    din = 8'd32;
    addr = 6'd32;

    // 5.
    #5
    wen = 1'b0;
    ren = 1'b1;
    din = 8'd20;
    addr = 6'd17;

    // 6.
    #5
    wen = 1'b1;
    ren = 1'b0;
    din = 8'd0;
    addr = 6'd31;

    // 7.
    #5
    wen = 1'b1;
    ren = 1'b0;
    din = 8'd0;
    addr = 6'd17;

    // 8.
    #5
    wen = 1'b0;
    ren = 1'b0;
    din = 8'd0;
    addr = 6'd1;

    // 9.
    #5
    wen = 1'b0;
    ren = 1'b0;
    din = 8'd0;
    addr = 6'd32;

    // 10.
    #5
    wen = 1'b1;
    ren = 1'b1;
    din = 8'd0;
    addr = 6'd0;

    #1 $finish;
  end
endmodule
