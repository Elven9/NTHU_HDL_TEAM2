`timescale 1ns/1ps

module Parameterized_Ping_Pong_Counter (clk, rst_n, enable, flip, max, min, direction, out);
    input clk, rst_n;
    input enable;
    input flip;
    input [4-1:0] max;
    input [4-1:0] min;
    output direction;
    output [4-1:0] out;

    reg [3:0] counter, next_counter;
    reg dir, next_dir;
    wire count_clk;

    always @(posedge clk) begin
      if (rst_n == 1'b0) begin
        counter <= min;
        dir <= 1'b0;
      end
      else begin
        counter <= nextCounter;
        dir <= next_dir;
      end
    end

    always @(*) begin
      nextCounter = counter;
      nextDirection = direction;

      if (enable && max > min && counter <= max && counter >= min) begin
        if (flip || (counter >= max && dir == 0) || (counter <= min && dir == 1) ) next_dir = !dir;
        else next_dir = dir;
        next_counter = next_dir == 1'b0 ? counter + 1 : counter - 1;
      end
      else begin
        nextCounter = counter;
        nextDirection = direction;
      end
    end

    assign direction = dir;
    assign out = counter;

endmodule