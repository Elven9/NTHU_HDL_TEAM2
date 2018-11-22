`timescale 1ns/1ps

`define CYC 4

module Mealy_t;
  reg clk = 1'b1;
  reg rst_n = 1'b1;
  reg in = 1'b0;
  wire dec;

  Mealy_Sequence_Detector mealy(
    .clk (clk),
    .rst_n (rst_n),
    .in (in),
    .dec (dec)
  );

  always #(`CYC / 2) clk = ~clk;

  initial begin
    @ (negedge clk) rst_n = 1'b0;
    @ (posedge clk) // reset to S0
    // 1. Correct Answer One
    @ (negedge clk) begin
      rst_n = 1'b1;
      in = 1'b1;
    end
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b0;
    @ (negedge clk) in = 1'b0;
    // 2. Correct Answer Two
    @ (negedge clk) in = 1'b0;
    @ (negedge clk) in = 1'b0;
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b1;
    // 2. Mock Set (previous one bits)
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b0;
    @ (negedge clk) in = 1'b0;
    @ (negedge clk) in = 1'b0;
    // 3. Correct Ans after Mock Set
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b0;
    @ (negedge clk) in = 1'b0;
    // 4. Check whether in nS2
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b0;
    @ (negedge clk) in = 1'b0;
    @ (negedge clk) in = 1'b1;
    // ---
    @ (negedge clk) in = 1'b0;
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b1;
    // 5. Check whether in nS3
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b0;
    // ---
    @ (negedge clk) in = 1'b0;
    @ (negedge clk) in = 1'b0;
    @ (negedge clk) in = 1'b0;
    @ (negedge clk) in = 1'b1;
    // 7. Final Correct Answer
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b0;
    @ (negedge clk) in = 1'b0;
    // ---
    @ (negedge clk) in = 1'b0;
    @ (negedge clk) in = 1'b0;
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) $finish;
  end

endmodule
