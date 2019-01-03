module servo_controller (
  input clk,
  input rst,
  input isClockWise,
  input isCounterClock,
  output reg servo
  );

  parameter START_POS = 30'd10_0000, END_POS = 30'd20_0000, WAVE_LENGTH = 30'd200_0000;
  parameter ONE_MOVE = 30'd5000;
  reg [29:0] count;
  reg [29:0] currentPos, nextPos;

  wire slow_clk;
  clock_divider cd1(.clk(clk), .rst(rst), .out_clk(slow_clk));

  // Use default 100MHZ to count
  // Generate appropriate waveform
  always @(posedge clk) begin
    if (rst) begin
      count <= 30'd0;
      servo <= 1'b0;
    end
    else begin
      count <= (count < WAVE_LENGTH) ? count + 1'b1 : 30'd0;
      servo <= (count < currentPos) ? 1'b1 : 1'b0;
    end
  end

  // Generate slower rst signal
  reg relay_rst;
  always @(posedge slow_clk, posedge rst) begin
    if (rst) relay_rst = 1'b1;
    else relay_rst = 1'b0;
  end

  // Use Slower Clock (about .1s) to count
  // Make moter move slower
  always @(posedge slow_clk) begin
    if (relay_rst) begin
      currentPos <= START_POS;
    end
    else begin
      currentPos <= nextPos;
    end
  end

  // Depend on what button we pressed, we change the current degree.
  always @(isClockWise, isCounterClock) begin
    if (isClockWise) begin
      if (currentPos + ONE_MOVE <= END_POS) nextPos = currentPos + ONE_MOVE;
      else nextPos = currentPos;
    end
    else if (isCounterClock) begin
      if (currentPos - ONE_MOVE >= START_POS) nextPos = currentPos - ONE_MOVE;
      else nextPos = currentPos;
    end
    else begin
      nextPos = currentPos;
    end
  end

endmodule