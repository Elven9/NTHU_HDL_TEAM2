

module arm_wrapper (
  input clk,
  input buttonMiddle,
  input rx,
  inout wire PS2_DATA,
  inout wire PS2_CLK,
  output [3:0] servo,
  output [7:0] rxData
);

  // Reset Button
  wire rst;
  switch_pulse pulse3 (.clk(clk), .inSignal(buttonMiddle), .filteredSignal(rst));

  // ------------------------------------------- Keyboard
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
  parameter [8:0] buttonUp [0:3] = {
    9'b0_0001_0101, // Q
    9'b0_0001_1101, // W
    9'b0_0010_0100, // E
    9'b0_0010_1101 // R
  };

  parameter [8:0] buttonDown [0:3] = {
    9'b0_0001_1100, // A
    9'b0_0001_1011, // S
    9'b0_0010_0011, // D
    9'b0_0010_1011 // F
  };

  // -----------------------------  keyboard END

  // -----------------------------  Bluetooth Module

  wire rxEn;
  wire tick; // Baud rate clock
  wire rxDone; // Reception completed. Data is valid.
  wire [3:0] NBits;
  wire [15:0] baudRate; // Calculate for appropriate read baudrate

  assign rxEn = 1'b1; // Enable bluetooth read
  assign baudRate = 16'd650; //baud rate set to 9600 for the HC-06 bluetooth module.
  assign NBits = 4'b1000;	//We send/receive 8 bits

  // Make connections between Rx module and TOP inputs and outputs and the other modules
  UART_rs232_rx I_RS232RX(
    .Clk(clk),
    .Rst_n(rst),
    .RxEn(rxEn),
    .RxData(rxData),
    .RxDone(rxDone),
    .Rx(rx),
    .Tick(tick),
    .NBits(NBits)
  );

  // Make connections between tick generator module and TOP inputs and outputs and the other modules
  UART_BaudRate_generator I_BAUDGEN(
    .Clk(clk),
    .Rst_n(rst),
    .Tick(tick),
    .BaudRate(baudRate)
  );

  // -----------------------------  Bluetooth End

  assign isClockWiseQ = key_down[buttonUp[0]] || rxData == 8'd1;
  assign isClockWiseW = key_down[buttonUp[1]] || rxData == 8'd3;
  assign isClockWiseE = key_down[buttonUp[2]] || rxData == 8'd5;
  assign isClockWiseR = key_down[buttonUp[3]] || rxData == 8'd7;

  assign isCounterClockA = key_down[buttonDown[0]] || rxData == 8'd2;
  assign isCounterClockS = key_down[buttonDown[1]] || rxData == 8'd4;
  assign isCounterClockD = key_down[buttonDown[2]] || rxData == 8'd6;
  assign isCounterClockF = key_down[buttonDown[3]] || rxData == 8'd8;

  // Connect to servo_controller
  servo_controller ser1 (
    .clk(clk),
    .rst(rst),
    .isClockWise(isClockWiseQ),
    .isCounterClock(isCounterClockA),
    .servo(servo[0])
  );

  servo_controller ser2 (
    .clk(clk),
    .rst(rst),
    .isClockWise(isClockWiseW),
    .isCounterClock(isCounterClockS),
    .servo(servo[1])
  );

  servo_controller ser3 (
    .clk(clk),
    .rst(rst),
    .isClockWise(isClockWiseE),
    .isCounterClock(isCounterClockD),
    .servo(servo[2])
  );

  servo_controller ser4 (
    .clk(clk),
    .rst(rst),
    .isClockWise(isClockWiseR),
    .isCounterClock(isCounterClockF),
    .servo(servo[3])
  );

endmodule

