`timescale 1ns/1ps

module Comparator_t;
reg [2:0] a, b;
wire [3-1:0] out;

Comparator_3bits fa (
  .a (a),
  .b (b),
  .a_lt_b(out[2]),
  .a_gt_b(out[1]),
  .a_eq_b(out[0])
);

initial begin
  a = 0;
  b = 2;
  repeat (4) begin
    #1 begin
        a = a + 1;
    end
  end
  #1 $finish;
end

endmodule