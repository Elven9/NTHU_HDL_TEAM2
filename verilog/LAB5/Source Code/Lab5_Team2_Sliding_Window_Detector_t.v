`timescale 1ns/1ps

`define CYC 4

module Mealy_t;
  reg clk = 1'b1;
  reg rst_n = 1'b1;
  reg in = 1'b0;
  wire dec1, dec2;

  Sliding_Window_Detector sliding(
    .clk (clk),
    .rst_n (rst_n),
    .in (in),
    .dec1 (dec1),
    .dec2 (dec2)
  );

  always #(`CYC / 2) clk = ~clk;

  initial begin
    @ (negedge clk) rst_n = 1'b0;
    @ (posedge clk) // reset to S0
    // 1. Both should display correct answer
    @ (negedge clk) begin
      rst_n = 1'b1;
      in = 1'b0;
    end
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b0;
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b0;
    // 2. Sliding
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b0;
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b1;
    // --- dec1 close
    // Below check whether dec1
    // 3. Sliding correct dec2
    @ (negedge clk) in = 1'b0;
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b0;
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b0;
    // 4. Check whether in nS2
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b0;
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) in = 1'b0;
    @ (negedge clk) in = 1'b1;
    @ (negedge clk) $finish;
  end

endmodule
