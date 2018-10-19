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
      $display("addr: %d ,dout: %d", addr, mem[addr]);
      dout <= mem[addr];
    end
    else if (ren == 1'b1 && wen == 1'b0) begin
      mem[addr] <= din;
      dout <= 8'd0;
    end
    else begin
      dout <= 8'd0;
    end
  end
endmodule
