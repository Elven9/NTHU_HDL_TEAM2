

module arm_wrapper (
  input clk,
  input buttonMiddle,
  inout wire PS2_DATA,
  inout wire PS2_CLK,
  output servo
);

  // Reset Button
  wire rst;
  switch_pulse pulse3 (.clk(clk), .inSignal(buttonMiddle), .filteredSignal(rst));

  // Keyboard
  wire [511:0] key_down;
  wire [8:0] last_change;
  wire been_ready;
  KeyboardDecoder key_de (
    .key_down(key_down),
    .last_change(last_change),
    .key_valid(been_ready),
    .PS2_DATA(PS2_DATA),
    .PS2_CLK(PS2_CLK),
    .rst(rst),
    .clk(clk)
  );

  // Check ClockWise or CounterClock, which depend on pressed button
  wire isClockWise, isCounterClock;
  parameter buttonUp = 9'b001110101;
  parameter buttonDown = 9'b001110010;

  assign isClockWise = key_down[buttonUp];
  assign isCounterClock = key_down[buttonDown];

  // Connect to servo_controller
  servo_controller ser (
    .clk(clk),
    .rst(rst),
    .isClockWise(isClockWise),
    .isCounterClock(isCounterClock),
    .servo(servo)
  );

endmodule

