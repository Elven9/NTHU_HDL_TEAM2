module UART_BaudRate_generator(
  input clk,             // Clock input
  input rst_n,           // Reset input
  input [15:0] baudRate, // Value to divide the generator by
  output tick            // Each "BaudRate" pulses we create a tick pulse
);

  reg [15:0] baudRateReg; // Register used to count

  always @(posedge clk or posedge rst_n) begin
    if (rst_n) baudRateReg <= 16'd1;
    else if (tick) baudRateReg <= 16'd1;
    else baudRateReg <= baudRateReg + 1'b1;
  end

  assign tick = (baudRateReg == baudRate);
endmodule
