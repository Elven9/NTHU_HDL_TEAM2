`timescale 1ns/1ps

// Define State Name
`define IDLE 3'b0000
`define HW_GREEN_25_CYCLE_PERIOD 3'b0001
`define HW_GREEN_FREE_PERIOD 3'b0010
`define HW_YELLOW_5_CYCLE_PERIOD 3'b0011
`define HW_RED_LR_RED 3'b0100
`define LR_GREEN_25_CYCLE_PERIOD 3'b0101
`define LR_YELLOW_5_CYCLE_PERIOD 3'b0110
`define LR_RED_HW_RED 3'b111

module Traffic_Light_Controller (clk, rst_n, lr_has_car, hw_light, lr_light, state);
  input clk, rst_n;
  input lr_has_car;
  output reg [2:0] state;
  output reg [3-1:0] hw_light;
  output reg [3-1:0] lr_light;

  // State
  reg [2:0] next_state;
  reg [2:0] next_hw_light, next_lr_light;

  // Counter
  reg [4:0] count, next_count;

  always @(posedge clk) begin
    if (rst_n == 0) begin
      state <= `IDLE;
      hw_light <= 3'b000;
      lr_light <= 3'b000;
      count <= 0;
    end
    else begin
      state <= next_state;
      hw_light <= next_hw_light;
      lr_light <= next_lr_light;
      count <= next_count;
    end
  end

  // Combinational Logic Circuit
  always @(*) begin
    next_state = state;
    next_hw_light = hw_light;
    next_lr_light = lr_light;
    next_count = count;

    case (state)
      `IDLE:begin
        next_state = `HW_GREEN_25_CYCLE_PERIOD;
        next_hw_light = 3'b001;
        next_lr_light = 3'b100;
        next_count = 0;
      end
      `HW_GREEN_25_CYCLE_PERIOD:begin
        if (count == 24) begin
          next_count = 0;
          next_state = lr_has_car ? `HW_YELLOW_5_CYCLE_PERIOD : `HW_GREEN_FREE_PERIOD;
          next_hw_light = lr_has_car ? 3'b010 : 3'b001;
        end
        else begin
          next_count = count + 1;
        end
      end 
      `HW_GREEN_FREE_PERIOD:begin
        if (lr_has_car) begin
          next_state = `HW_YELLOW_5_CYCLE_PERIOD;
          next_hw_light = 3'b010;
        end
        else begin
          next_state = state;
        end
      end
      `HW_YELLOW_5_CYCLE_PERIOD:begin
        if (count == 4) begin
          next_state = `HW_RED_LR_RED;
          next_count = 0;
          next_hw_light = 3'b100;
        end
        else begin
          next_count = count + 1;
        end
      end
      `HW_RED_LR_RED:begin
        next_state = `LR_GREEN_25_CYCLE_PERIOD;
        next_lr_light = 3'b001;
      end
      `LR_GREEN_25_CYCLE_PERIOD:begin
        if (count == 24) begin
          next_state = `LR_YELLOW_5_CYCLE_PERIOD;
          next_count = 0;
          next_lr_light = 3'b010;
        end
        else begin
          next_count = count + 1;
        end
      end
      `LR_YELLOW_5_CYCLE_PERIOD:begin
        if (count == 4) begin
          next_state = `LR_RED_HW_RED;
          next_lr_light = 3'b100;
        end
        else begin
          next_count = count + 1;
        end
      end
      `LR_RED_HW_RED:begin
        next_state = `HW_GREEN_25_CYCLE_PERIOD;
        next_hw_light = 3'b001;
      end
      default:begin
        next_state = state;
        next_count = count;
        next_hw_light = hw_light;
        next_lr_light = lr_light;
      end
    endcase
  end

endmodule
