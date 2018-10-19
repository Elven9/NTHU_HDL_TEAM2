`timescale 1ns/1ps

module LFSR_t;
  reg clk, rst_n;
  wire out;

  LFSR lfsr(
    .clk(clk),
    .rst_n(rst_n),
    .out(out)
  );

  always #2 clk = ~clk;

  initial begin
    clk = 1'b1;

    @(negedge clk) rst_n = 1'b0;

    @(negedge clk) rst_n = 1'b1;

    @(negedge clk)
    repeat(2 ** 4) begin
      #4;
    end
    #1 $finish;
  end
endmodule
