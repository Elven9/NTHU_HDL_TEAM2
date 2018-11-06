`timescale 1ns/1ps

`define CYC 4

module Mealy_t;
  reg clk = 1'b1;
  reg rst_n = 1'b1;
  reg start = 1'b0;
  reg [7:0] a, b;
  wire done;
  wire [7:0] gcd;

  Greatest_Common_Divisor gcdM(
    .clk (clk),
    .rst_n (rst_n),
    .start (start),
    .a (a),
    .b (b),
    .done (done),
    .gcd (gcd)
  );

  always #(`CYC / 2) clk = ~clk;

  initial begin
    a = 8'd0;
    b = 8'd0;
    @ (negedge clk) rst_n = 1'b0;
    @ (posedge clk) // reset to S0
    @ (negedge clk) rst_n = 1'b1;
    @ (posedge clk)
    @ (negedge clk) begin
      a = 8'd20;
      b = 8'd15;
      start = 1'b1;
    end
    @ (negedge clk) start = 1'b0;
    @ (negedge clk)
    @ (negedge done)
    @ (negedge clk)
    @ (negedge clk)
    @ (negedge clk) begin
      start = 1'b1;
      a = 8'd56;
      b = 8'd49;
    end
    @ (negedge clk) start = 1'b0;
    @ (posedge clk)
    @ (negedge done)
    @ (negedge clk)
    @ (negedge clk) $finish;
  end

endmodule
