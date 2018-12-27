

module arm_wrapper (
  input clk,
  input buttonMiddle,
  input buttonLeft,
  input buttonRight,
  output servo
);


  wire isClockWise, isCounterClock, rst;
  switch_pulse pulse1 (.clk(clk), .inSignal(buttonLeft), .filteredSignal(isClockWise));
  switch_pulse pulse2 (.clk(clk), .inSignal(buttonRight), .filteredSignal(isCounterClock));
  switch_pulse pulse3 (.clk(clk), .inSignal(buttonMiddle), .filteredSignal(rst));

  servo_controller servo (
    .clk(clk),
    .rst(rst),
    .isClockWise(isClockWise),
    .isCounterClock(isCounterClock),
    .servo(servo)
  );

endmodule

module servo_controller (
  input clk,
  input rst,
  input isClockWise,
  input isCounterClock,
  output reg servo
  );

  parameter START_POS = 30'd10_0000, MIDDLE_POS = 30'd15_0000, END_POS = 30'd20_0000, WAVE_LENGTH = 30'd200_0000;
  reg [29:0] count;
  reg [29:0] currentPos, nextPos;
  reg dir, nextDir;

  always @(posedge clk) begin
    if (rst) begin
      count <= 30'd0;
      currentPos <= START_POS;
      servo <= 1'b0;
      dir <= 1'b0;
    end
    else begin
      count <= (count < WAVE_LENGTH) ? count + 1'b1 : 30'd0;
      currentPos <= nextPos;
      servo <= (count < currentPos) ? 1'b1 : 1'b0;
      dir <= nextDir;
    end
  end

  always @(*) begin
    if (dir == 1'b0) begin
      if (currentPos >= END_POS) begin
        nextDir = 1'b1;
        nextPos = currentPos - 30'd10_0000;
      end
      else begin
        nextDir = 1'b0;
        nextPos = currentPos + 30'd10_0000;
      end
    end
    else begin
      if (currentPos <= START_POS) begin
        nextDir = 1'b0;
        nextPos = currentPos + 30'd10_0000;
      end
      else begin
        nextDir = 1'b1;
        nextPos = currentPos - 30'd10_0000;
      end
    end
  end

endmodule


module switch_pulse (clk, inSignal, filteredSignal);
    input inSignal;
    input clk;
    output filteredSignal;

    reg [3:0] delay;
    wire debounceSignal;

    reg pulse1, pulse2;

    // Debounce;
    always @ ( posedge clk ) begin
        delay[3:1] <= delay[2:0];
        delay[0] <= inSignal;
    end
    assign debounceSignal = delay == 4'b1111 ? 1 : 0;

    // One Pulse;
    always @ ( posedge clk ) begin
        pulse1 <= debounceSignal;
        pulse2 <= (!pulse1) & debounceSignal;
    end

    assign filteredSignal = pulse2;
endmodule
