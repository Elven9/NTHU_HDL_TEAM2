`define IDLE 2'b00
`define OPERATION 2'b01
`define CANCEL 2'b10

module VendingMachineFPGA(clk, RESET_in, CANCEL_in, coin_5_in, coin_10_in, coin_50_in, segment_7, avaliable_drink, an, PS2_DATA, PS2_CLK, dp);
  input clk, RESET_in, CANCEL_in;
  input coin_5_in, coin_10_in, coin_50_in;
  output reg [6:0] segment_7;
  output [3:0] avaliable_drink;
  output reg [3:0] an;
  output dp;
  
  // DP assignment
  assign dp = 1'b1;

  // Keyboard
  inout wire PS2_DATA;
  inout wire PS2_CLK;

  // Input Debounce
  wire RESET, CANCEL, coin_5, coin_10, coin_50;
  wire coke, oolong, coffee, water;

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
    .rst(RESET),
    .clk(clk)
  );

  // Debounce Out 
  switch_pulse pulse1 (.clk(clk), .inSignal(RESET_in), .filteredSignal(RESET));
  switch_pulse pulse2 (.clk(clk), .inSignal(CANCEL_in), .filteredSignal(CANCEL));
  switch_pulse pulse3 (.clk(clk), .inSignal(coin_5_in), .filteredSignal(coin_5));
  switch_pulse pulse4 (.clk(clk), .inSignal(coin_10_in), .filteredSignal(coin_10));
  switch_pulse pulse5 (.clk(clk), .inSignal(coin_50_in), .filteredSignal(coin_50));
  OnePulse pulse6 (.clock(clk), .signal(key_down[9'b000011100]), .signal_single_pulse(coffee));
  OnePulse pulse7 (.clock(clk), .signal(key_down[9'b000011011]), .signal_single_pulse(coke));
  OnePulse pulse8 (.clock(clk), .signal(key_down[9'b000100011]), .signal_single_pulse(oolong));
  OnePulse pulse9 (.clock(clk), .signal(key_down[9'b000101011]), .signal_single_pulse(water));

  // Vending Machine
  wire [7:0] money;

  VendingMachine vm ( .clk(clk),
                      .RESET(RESET),
                      .CANCEL(CANCEL),
                      .coin_5(coin_5),
                      .coin_10(coin_10),
                      .coin_50(coin_50),
                      .coke(coke),
                      .oolong(oolong),
                      .water(water),
                      .coffee(coffee),
                      .money(money),
                      .avaliable_drink(avaliable_drink) );
  
  // Display
  wire [6:0] digit1, digit2;
  segament_display segment1(.display_number(money[3:0]), .outport(digit1));
  segament_display segment2(.display_number(money[7:4]), .outport(digit2));

  // AN
  reg [3:0] next_an;
  reg [6:0] next_segment;
  wire display_clk;

  // Divider
  clock_divider display (.rst(RESET), .clk(clk), .out_clk(display_clk));

  always @ ( posedge display_clk ) begin
    if (RESET) begin
        segment_7 <= 7'b1111111;
        an <= 4'b1110;
    end
    else begin
        segment_7 <= next_segment;
        an <= next_an;
    end
  end

  always @ ( * ) begin
    case (an)
        4'b1110:begin
            next_segment = digit2;
            next_an = 4'b1101;
        end
        4'b1101:begin
            next_segment = 7'b1111111;
            next_an = 4'b1011;
        end
        4'b1011:begin
            next_segment = 7'b1111111;
            next_an = 4'b0111;
        end
        4'b0111:begin
            next_segment = digit1;
            next_an = 4'b1110;
        end
        default: begin
            next_segment = segment_7;
            next_an = an;
        end
    endcase
  end

endmodule

module VendingMachine( clk, RESET, CANCEL, coin_5, coin_10, coin_50, coke, oolong, water, coffee, money, avaliable_drink );
  input clk, RESET, CANCEL;
  input coin_5, coin_10, coin_50;
  input coke, oolong, water, coffee;
  output [7:0] money;
  output reg [3:0] avaliable_drink;

  // Out Money Display
  reg [7:0] cur_m, next_m;
  reg [3:0] cur_ad, next_ad;
  
  assign money = cur_m;

  // State
  reg [1:0] state, next_state;

  // Counter
  reg [28:0] counter, next_counter;

  always @( posedge clk or posedge RESET) begin
    if (RESET) begin
      cur_m <= 0;
      cur_ad <= 0;
      state <= `IDLE;
      counter <= 0;
    end
    else begin
      cur_m <= next_m;
      cur_ad <= next_ad;
      state <= next_state;
      counter <= next_counter;
    end
  end

  always @(*) begin
    next_m = cur_m;
    next_state = state;
    next_ad = cur_ad;
    next_counter = counter;

    case (state)
      `IDLE:begin
        next_m = 0;
        next_ad = 0;
        next_state = `OPERATION;
        next_counter = 0;
      end
      `OPERATION:begin
        if (CANCEL) begin
          next_state = `CANCEL;
        end
        else begin
          next_state = `OPERATION;
          if (coke) begin
            if (cur_m >= 8'b00100000) begin
              next_m[7:4] = cur_m[7:4] - 2;
              next_m[3:0] = cur_m[3:0];
              next_state = `CANCEL;
            end
            else begin
              next_m = cur_m;
            end
          end
          else if (oolong) begin
            if (cur_m >= 8'b00100101) begin
              next_m = { cur_m[3:0] == 4'd5 ? cur_m[7:4] - 2 : cur_m[7:4] - 3, cur_m[3:0] == 4'd5 ? 4'd0 : 4'd5 };
              next_state = `CANCEL;
            end
            else begin
              next_m = cur_m;
            end
          end
          else if (water) begin
            if (cur_m >= 8'b00110000) begin
              next_m = { cur_m[7:4] - 3, cur_m[3:0] };
              next_state = `CANCEL;
            end
            else begin
              next_m = cur_m;
            end
          end
          else if (coffee) begin
            if (cur_m >= 8'b01010101) begin
              next_m = { cur_m[3:0] == 4'd5 ? cur_m[7:4] - 5 : cur_m[7:4] - 6, cur_m[3:0] == 4'd5 ? 4'd0 : 4'd5 };
              next_state = `CANCEL;
            end
            else begin
              next_m = cur_m;
            end
          end
          else begin
            next_m = cur_m;
             // Add Money
            if (coin_5) begin
              next_m[3:0] = cur_m[7:4] == 8 || cur_m[3:0] == 4'd5 ? 0 : 4'd5;
              if (cur_m[3:0] == 4'd5) begin
                next_m[7:4] = cur_m >= 8'b01110101 ? 4'd8 : cur_m[7:4] + 1;
              end
              else begin
                next_m[7:4] = cur_m[7:4];
              end
            end
            else if (coin_10) begin
              next_m[3:0] = cur_m >= 8'b01110000 ? 0 : cur_m[3:0];
              next_m[7:4] = cur_m >= 8'b01110000 ? 4'd8 : cur_m[7:4] + 1;
            end
            else if (coin_50) begin
              next_m[3:0] = cur_m >= 8'b00110000 ? 0 : cur_m[3:0];
              next_m[7:4] = cur_m >= 8'b00110000 ? 4'd8 : cur_m[7:4] + 5;
            end
            else begin
              next_m = cur_m;
            end
          end
        end
      end
      `CANCEL:begin
        next_counter = counter == 100000000 ? 0 : counter + 1;
        if (cur_m > 0) begin
          if (counter == 100000000) begin
            next_m[7:4] = cur_m[3:0] == 0 ? cur_m[7:4] - 4'b0001 : cur_m[7:4];
            next_m[3:0] = cur_m[3:0] == 0 ? 5 : 0;
            next_counter = 0;
          end
          else begin
            next_m = cur_m;
          end
        end
        else begin
          next_counter = 0;
          next_state = `OPERATION;
        end
      end
      default: state = next_state;
    endcase

    // Avaliable Drink
    if (cur_m[7:4] == 2 && cur_m[3:0] == 0) begin
      avaliable_drink = 4'b0100;
    end
    else if (cur_m[7:4] == 2 && cur_m[3:0] == 5) begin
      avaliable_drink = 4'b0110;
    end
    else if (cur_m[7:4] >= 3 && cur_m[7:4] <= 5 && !(cur_m[7:4] == 5 && cur_m[3:0] == 5)) begin
      avaliable_drink = 4'b0111;
    end
    else if (cur_m[7:4] >= 5) begin
      avaliable_drink = 4'b1111;
    end
    else begin
      avaliable_drink = 4'b0000;
    end
  end


endmodule // VendingMachine

module KeyboardDecoder(
  output reg [511:0] key_down,
  output wire [8:0] last_change,
  output reg key_valid,
  inout wire PS2_DATA,
  inout wire PS2_CLK,
  input wire rst,
  input wire clk
    );
    
  parameter [1:0] INIT      = 2'b00;
  parameter [1:0] WAIT_FOR_SIGNAL = 2'b01;
  parameter [1:0] GET_SIGNAL_DOWN = 2'b10;
  parameter [1:0] WAIT_RELEASE    = 2'b11;
    
  parameter [7:0] IS_INIT      = 8'hAA;
  parameter [7:0] IS_EXTEND    = 8'hE0;
  parameter [7:0] IS_BREAK    = 8'hF0;
  
  reg [9:0] key;    // key = {been_extend, been_break, key_in}
  reg [1:0] state;
  reg been_ready, been_extend, been_break;
  
  wire [7:0] key_in;
  wire is_extend;
  wire is_break;
  wire valid;
  wire err;
  
  wire [511:0] key_decode = 1 << last_change;
  assign last_change = {key[9], key[7:0]};
  
  KeyboardCtrl_0 inst (
  .key_in(key_in),
  .is_extend(is_extend),
  .is_break(is_break),
  .valid(valid),
  .err(err),
  .PS2_DATA(PS2_DATA),
  .PS2_CLK(PS2_CLK),
  .rst(rst),
  .clk(clk)
);

OnePulse op (
  .signal_single_pulse(pulse_been_ready),
  .signal(been_ready),
  .clock(clk)
);
  
  always @ (posedge clk, posedge rst) begin
    if (rst) begin
      state <= INIT;
      been_ready  <= 1'b0;
      been_extend <= 1'b0;
      been_break  <= 1'b0;
      key <= 10'b0_0_0000_0000;
    end else begin
      state <= state;
    been_ready  <= been_ready;
    been_extend <= (is_extend) ? 1'b1 : been_extend;
    been_break  <= (is_break ) ? 1'b1 : been_break;
    key <= key;
      case (state)
        INIT : begin
            if (key_in == IS_INIT) begin
              state <= WAIT_FOR_SIGNAL;
              been_ready  <= 1'b0;
            been_extend <= 1'b0;
            been_break  <= 1'b0;
            key <= 10'b0_0_0000_0000;
            end else begin
              state <= INIT;
            end
          end
        WAIT_FOR_SIGNAL : begin
            if (valid == 0) begin
              state <= WAIT_FOR_SIGNAL;
              been_ready <= 1'b0;
            end else begin
              state <= GET_SIGNAL_DOWN;
            end
          end
        GET_SIGNAL_DOWN : begin
          state <= WAIT_RELEASE;
          key <= {been_extend, been_break, key_in};
          been_ready  <= 1'b1;
          end
        WAIT_RELEASE : begin
            if (valid == 1) begin
              state <= WAIT_RELEASE;
            end else begin
              state <= WAIT_FOR_SIGNAL;
              been_extend <= 1'b0;
              been_break  <= 1'b0;
            end
          end
        default : begin
            state <= INIT;
          been_ready  <= 1'b0;
          been_extend <= 1'b0;
          been_break  <= 1'b0;
          key <= 10'b0_0_0000_0000;
          end
      endcase
    end
  end
  
  always @ (posedge clk, posedge rst) begin
    if (rst) begin
      key_valid <= 1'b0;
      key_down <= 511'b0;
    end else if (key_decode[last_change] && pulse_been_ready) begin
      key_valid <= 1'b1;
      if (key[8] == 0) begin
        key_down <= key_down | key_decode;
      end else begin
        key_down <= key_down & (~key_decode);
      end
    end else begin
      key_valid <= 1'b0;
    key_down <= key_down;
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

module OnePulse (
	output reg signal_single_pulse,
	input wire signal,
	input wire clock
	);
	
	reg signal_delay;

	always @(posedge clock) begin
		if (signal == 1'b1 & signal_delay == 1'b0)
		  signal_single_pulse <= 1'b1;
		else
		  signal_single_pulse <= 1'b0;

		signal_delay <= signal;
	end
endmodule

module segament_display (display_number, outport);
    input [3:0] display_number;
    output [6:0] outport;

    assign outport[0] = !(display_number == 0 || display_number == 2 || display_number == 3 || display_number == 5 || display_number == 6 || display_number == 7 || display_number == 8 || display_number == 9 || display_number == 10 || display_number == 12 || display_number == 14 || display_number == 15);
    assign outport[1] = !(display_number == 0 || display_number == 2 || display_number == 3 || display_number == 4 || display_number == 1 || display_number == 7 || display_number == 8 || display_number == 9 || display_number == 10 || display_number == 13);
    assign outport[2] = !(display_number == 0 || display_number == 1 || display_number == 3 || display_number == 5 || display_number == 6 || display_number == 7 || display_number == 8 || display_number == 9 || display_number == 10 || display_number == 11 || display_number == 13 || display_number == 4);
    assign outport[3] = !(display_number == 0 || display_number == 2 || display_number == 3 || display_number == 5 || display_number == 6 || display_number == 11 || display_number == 8 || display_number == 9 || display_number == 12 || display_number == 13 || display_number == 14);
    assign outport[4] = !(display_number == 0 || display_number == 2 || display_number == 6 || display_number == 8 || display_number == 10 || display_number == 11 || display_number == 12 || display_number == 13 || display_number == 14 || display_number == 15);
    assign outport[5] = !(display_number == 0 || display_number == 4 || display_number == 5 || display_number == 6 || display_number == 8 || display_number == 9 || display_number == 10 || display_number == 11 || display_number == 12 || display_number == 14 || display_number == 15);
    assign outport[6] = !(display_number == 4 || display_number == 2 || display_number == 3 || display_number == 5 || display_number == 6 || display_number == 11 || display_number == 8 || display_number == 9 || display_number == 10 || display_number == 13 || display_number == 14 || display_number == 15);

endmodule

module clock_divider(rst, clk, out_clk);
    input clk;
    input rst;
    output out_clk;
    reg [16:0] count, next_count;
    reg outClk, nextOutClk;

    always @ ( posedge clk ) begin
        if (rst == 1) begin
            count <= 0;
            outClk <= 0;
        end
        else begin
            count <= next_count;
            outClk <= nextOutClk;
        end
    end

    always @ ( * ) begin
        if (count == 17'b11111111111111111) begin
            next_count = 0;
            nextOutClk = !outClk;
        end
        else begin
            next_count = count + 1;
            nextOutClk = outClk;
        end
    end
    
    assign out_clk = outClk;
endmodule
