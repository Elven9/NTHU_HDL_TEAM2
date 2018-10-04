`timescale 1ns/1ps

module Multiplier_t;
  reg [3:0] a = 4'd0;
  reg [3:0] b = 4'd0;
  wire [8-1:0] p;

  reg isValid = 0;

  Multiplier m (
    .a (a),
    .b (b),
    .p (p)
  );

  initial begin
    repeat (2**8) begin
      #1 begin
        if (a == 4'd15) begin
          a = 4'd0;
          b = b + 1;
        end
        else a = a + 1;
      end
      #1 begin
        if (a*b == p) isValid = 1;
        else begin
          isValid = 0;
          $display("Error Calculating a=%d  b=%d  moduleOut=%d", a, b, p);
        end
      end
    end
    #1 $finish;
  end
endmodule
