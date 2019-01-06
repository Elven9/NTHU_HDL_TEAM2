module TOP(
  Clk,
  buttonMiddle,
  Rx,
	RxData,
);


input Clk; // Clock
input Rx; // RS232 RX line.
input buttonMiddle;
output [7:0] RxData; // Received data
wire Rst_n; // Reset
switch_pulse pulse3 (.clk(clk), .inSignal(buttonMiddle), .filteredSignal(Rst_n));

wire Tx; // RS232 TX line.
/////////////////////////////////////////////////////////////////////////////////////////
wire [7:0] TxData; // Data to transmit.
wire RxDone; // Reception completed. Data is valid.
wire TxDone; // Trnasmission completed. Data sent.
wire tick; // Baud rate clock
wire TxEn;
wire RxEn;
wire [3:0] NBits;
wire [15:0] BaudRate; //328; 162 etc... (Read comment in baud rate generator file)
/////////////////////////////////////////////////////////////////////////////////////////
assign RxEn = 1'b1;
assign TxEn = 1'b1;
assign BaudRate = 16'd650; //baud rate set to 9600 for the HC-06 bluetooth module. Why 325? (Read comment in baud rate generator file)
assign NBits = 4'b1000;	//We send/receive 8 bits
/////////////////////////////////////////////////////////////////////////////////////////

//Make connections between Rx module and TOP inputs and outputs and the other modules
UART_rs232_rx I_RS232RX(
  .Clk(Clk),
  .Rst_n(Rst_n),
  .RxEn(RxEn),
  .RxData(RxData),
  .RxDone(RxDone),
  .Rx(Rx),
  .Tick(tick),
  .NBits(NBits)
);

//Make connections between tick generator module and TOP inputs and outputs and the other modules
UART_BaudRate_generator I_BAUDGEN(
  .Clk(Clk),
  .Rst_n(Rst_n),
  .Tick(tick),
  .BaudRate(BaudRate)
);



endmodule
