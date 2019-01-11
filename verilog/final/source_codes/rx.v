module UART_rs232_rx (
  input clk,
  input rst_n,
  input rxEn,
  input rx,
  input tick,
  input [3:0] NBits   // Define my module as UART_rs232_rx
  output reg [7:0] rxData, // Define 8 bits output (this will eb the 1byte received data)
  output reg rxDone
);

  //Variabels used for state machine...
  parameter IDLE = 1'b0, READ = 1'b1;  // We haev 2 states for the state Machine state 0 and 1 (READ adn IDLE)

  reg [1:0] state, next;   // Create some registers for the states
  reg read_enable;         // Variable that will enable or NOT the data in read
  reg start_bit;           // Variable used to notify when the start bit was detected (first falling edge of rX)
  reg [4:0] Bit;           // Variable used for the bit by bit read loop (in this case 8 bits so 8 loops)
  reg [3:0] counter;       // Counter variable used to count the tick pulses up to 16
  reg [7:0] read_data;     // Register where we store the rx input bits before assigning it to the rxData output

  // Designate reset signal
  always @ (posedge clk or posedge rst_n) begin    //It is good to always have a reset always
    if (rst_n)  state <= IDLE;        //If reset pin is low, we get to the initial state which is IDLE
    else    state <= next;        //If not we go to the next state
  end


  /* This is easy. Each time "state or rx or rxEn or rxDone" will change their value
  we decide which is the next step. 
    - Obviously we get to IDLE only when rxDone is high, meaning that the read process is done.
    - Also, while we are into IDEL, we get to READ state only if rx input gets low meaning, we've detected a start bit */
  always @ (state or rx or rxEn or rxDone) begin
    case(state) 
      IDLE:
        if(!rx & rxEn) next = READ;   // If rx is low (Start bit detected) we start the read process
        else next = IDLE;
      READ:
        if(rxDone) next = IDLE;       // If rxDone is high, than we get back to IDLE and wait for rx input to go low (start bit detect)
        else next = READ;
      default next = IDLE;
    endcase
  end


  ///////////////////////////ENABLE READ OR NOT///////////////////////////////
  always @ (state or rxDone) begin
    case (state)
      READ: begin
        read_enable <= 1'b1;      //If we are in the Read state, we enable the read process so in the "tick always" we start getting the bits
      end
        
      IDLE: begin
        read_enable <= 1'b0;      //If we get back to IDLE, we desable the read process so the "tick always" could continue without geting rx bits
      end
    endcase
  end

  ///////////////////////////Read the input data//////////////////////////////
  /*Finally, each time we detect a tick pulse,we increase a couter.
  - When the counter is 8 (4'b1000) we are in the middle of the start bit
  - When the counter is 16 (4'b1111) we are in the middle of one of the bits
  - We store the data by shifting the rx input bit into the read_data register 
  using this line of code: read_data <= {rx,read_data[7:1]};
  */
  always @ (posedge tick) begin
    if (read_enable) begin
      rxDone <= 1'b0;             // Set the rxDone register to low since the process is still going
      counter <= counter+1;           // Increase the counter by 1 with each tick detected
      
      if ((counter == 4'b1000) & (start_bit)) begin // Counter is 8? Then we set the start bit to 1. 
        start_bit <= 1'b0;
        counter <= 4'b0000;
      end
      
      if ((counter == 4'b1111) & (!start_bit) & (Bit < NBits)) begin // We make a loop (8 loops in this case) and we read all 8 bits
        Bit <= Bit+1;
        read_data <= {rx,read_data[7:1]};
        counter <= 4'b0000;
      end

      if ((counter == 4'b1111) & (Bit == NBits)  & (rx)) begin   // Then we count to 16 once again and detect the stop bit (rx input must be high)
        Bit <= 4'b0000;
        rxDone <= 1'b1;
        rxData[7:0] <= read_data[7:0];
        read_data[7:0] <= 8'd0;
        counter <= 4'b0000;
        start_bit <= 1'b1;            // We reset all values for next data input and set rxDone to high
      end
    end
    else begin
      rxDone <= 1'b0;
      counter <= 4'd0;
      Bit <= 4'b0000;
      start_bit <= 1'b1;
    end
  end

//End of the rX mdoule
endmodule

