`timescale 1ns/1ps

module Memory (clk, ren, wen, addr, din, dout);
  input clk;
  input ren, wen;
  input [6-1:0] addr;
  input [8-1:0] din;
  output reg [8-1:0] dout;

  reg [7:0] mem [63:0];

  always @ ( posedge clk ) begin
    if (ren == 1'b0) begin
      dout <= mem[addr];
    end
    else begin
      if (wen == 1'b0) begin
        mem[addr] <= din;
        dout <= 8'd0;
      end
      else begin
        dout <= mem[addr];
      end
    end
  end
endmodule
