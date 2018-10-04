`timescale 1ns/1ps

module RippleCarryAdder_t;
reg [3:0] a, b;
wire [3:0] sum;
wire cout;
reg cin;

Carry_Look_Ahead_Adder fa (
  .a (a),
  .b (b),
  .cin(cin),
  .cout(cout),
  .sum(sum)
);

initial begin
  a = 4;
  b = 4;
  cin = 1;

  if (sum != 8 && cout != 0) begin
      $display("Some Error Happen In your code. Test: a = 4, b = 4 ###### Failed ######");
  end
  else begin
      $display("Congratulation!! Test: a = 4, b = 4 ###### Passed ######");
  end

  #3 begin
    a = 2;
    b = 5;
    cin = 0;
    if (sum != 7 && cout != 0) begin
        $display("Some Error Happen In your code. Test: a = 2, b = 5 ###### Failed ######");
    end
    else begin
        $display("Congratulation!! Test: a = 2, b = 5 ###### Passed ######");
    end
  end
  #3 begin
    a = 3;
    b = 1;
    cin = 1;
    if (sum != 4 && cout != 0) begin
        $display("Some Error Happen In your code. Test: a = 3, b = 1 ###### Failed ######");
    end
    else begin
        $display("Congratulation!! Test: a = 3, b = 1 ###### Passed ######");
    end
  end
  #1 $finish;
end

endmodule
