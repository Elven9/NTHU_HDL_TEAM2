// Not in use.
// 步進馬達 testing code
module step_controller (
  input clk,
  input rst,
  output [3:0] step
  );

  wire counter_clk;
  reg [3:0] dir, nextDir;
  // Direction of output: A B A- B-
  parameter [3:0] outFlow [7:0] = {
    4'b1000,
    4'b1100,
    4'b0100,
    4'b0110,
    4'b0010,
    4'b0011,
    4'b0001,
    4'b1001
  };

  clock_divider cd(.rst(rst), .clk(clk), out_clk(counter_clk));
  always @ (posedge counter_clk) begin
    if (rst) begin
      step <= outFlow[0];
      dir <= 4'd0;
    end
    else begin
      step <= outFlow[dir];
      dir <= (dir >= 4'd7) ? 4'd0 : dir + 1;
    end
  end

  assign step = dir;
endmodule