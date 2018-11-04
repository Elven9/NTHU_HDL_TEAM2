module Lab4_TeamX_Stopwatch_fpga (clk, start, reset, an, out, dp);
  input clk, start, reset;
  output [3:0] an;
  output [6:0] out;
  output dp;

  wire counter_clk, display_clk;
  reg relay_start, relay_reset;

  wire [3:0] min, ten_sec, seg_min, seg_ten_sec;
  wire [7:0] sec, seg_sec_d1, seg_sec_d2;

  reg [6:0] cur_out, next_out;
  reg [3:0] cur_an, next_an;
  reg cur_dp, next_dp;

  wire [3:0] sec_d1, sec_d2;

  // Counter Clock
  clock_divider_count counter_clk_gate(.rst(reset), .clk(clk), .out_clk(counter_clk));

  // Display Clock
  clock_divider display_gate (.rst(reset), .clk(clk), .out_clk(display_clk));

  // Reset, Start Relay.
  always @ (posedge counter_clk , posedge reset) begin
    if (reset == 1) relay_reset = 1;
    else relay_reset = 0;
  end
  
  always @ (posedge counter_clk ,  posedge start) begin
    if (start == 1) relay_start = 1;
    else relay_start = 0;
  end

  // Counter
  Time_Counter time_counter(.clk(counter_clk),
                            .reset(relay_reset),
                            .start(relay_start),
                            .minute(min),
                            .second(sec),
                            .ten_second(ten_sec));

  // Digit Process:
  assign sec_d1 = sec[3:0] >= 10 ? sec - 10 : sec;
  divide_tenth tenth(.num(sec - sec_d1), .out_num(sec_d2));

  // Segment Convert
  segament_display ten_sec_gate (.display_number(ten_sec), .outport(seg_ten_sec));
  segament_display sec_d1_gate (.display_number(sec_d1), .outport(seg_sec_d1));
  segament_display sec_d2_gate (.display_number(sec_d2), .outport(seg_sec_d2));
  segament_display min_gate (.display_number(min), .outport(seg_min));
  
  // Process Display
  always @ ( posedge display_clk ) begin
    if (rst_n == 0) begin
        cur_out <= 7'b1111111;
        cur_an <= 4'b1110;
        cur_dp <= 1;
    end
    else begin
        cur_out <= next_out;
        cur_an <= next_an;
        cur_dp <= next_dp;
    end
  end

  always @ ( * ) begin
    case (cur_an)
        4'b1110:begin
            next_out = seg_sec_d1;
            next_an = 4'b1101;
            next_dp = 0;
        end
        4'b1101:begin
            next_out = seg_sec_d2;
            next_an = 4'b1011;
            next_dp = 1;
        end
        4'b1011:begin
            next_out = seg_min;
            next_an = 4'b0111;
            next_dp = 1;
        end
        4'b0111:begin
            next_out = seg_ten_sec;
            next_an = 4'b1110;
            next_dp = 1;
        end
        default: begin
            next_out = cur_out;
            next_an = cur_an;
            next_dp = cur_dp;
        end
    endcase
  end

  assign an = cur_an;
  assign out = cur_out;
  assign dp = cur_dp;

endmodule

module Time_Counter(clk, reset, start, minute, second, ten_second);
  input clk, reset, start;
  output [3:0] minute, ten_second;
  output [7:0] second;

  // DFF Definition
  reg [3:0] cur_min, next_min, cur_ten_sec, next_ten_sec;
  reg [7:0] cur_sec, next_sec;
  
  // State Definition
  reg cur_state, next_state;

  // DFF
  always @(posedge clk) begin
    if (reset == 1) begin
      cur_state <= 0;
      cur_min <= 0;
      cur_sec <= 0;
      cur_ten_sec <= 0;
    end
    else begin
      cur_state <= next_state;
      cur_min <= next_min;
      cur_sec <= next_sec;
      cur_ten_sec <= next_ten_sec;
    end
  end

  always @(*) begin
    case (cur_state)
      1'b0: begin
        // RESET / WAIT
        next_min = 0;
        next_sec = 0;
        next_ten_sec = 0;

        // State Determination
        next_state = start ? 1'b1 : 1'b0;
      end
      1'b1: begin
        // COUNT
        // Main Logic
        next_state = cur_state;
        next_min = cur_min;
        next_sec = cur_sec;
        next_ten_sec = cur_ten_sec;

        next_ten_sec = cur_ten_sec == 4'b1001 ? 0 : cur_ten_sec + 1;
        if (cur_ten_sec == 4'b1001) begin
          next_sec = cur_sec == 8'd59 ? 0 : cur_sec + 1;

          if (cur_sec == 8'd59) begin
            next_min = cur_min == 4'b1001 ? 0 : cur_min + 1;

            if (cur_min == 4'b1001) begin
              next_state = 0;
            end
            else begin
              next_state = cur_state;
            end
          end
          else begin
            next_min = cur_min;
          end
        end
        else begin
          next_sec = cur_sec;
        end
      end 
      default: begin
        next_state <= cur_state;
        next_min <= cur_min;
        next_sec <= cur_sec;
        next_ten_sec <= cur_ten_sec;
      end
    endcase
  end

endmodule

module divide_tenth(num, out_num);
  input [7:0] num;
  output reg [3:0] out_num;

  always @(*) begin
    case (num)
      0: out_num = 0;
      10: out_num = 1;
      20: out_num = 2;
      30: out_num = 3;
      40: out_num = 4;
      50: out_num = 5;
      default: out_num = 6;
    endcase
  end
endmodule

module clock_divider_count(rst, clk, out_clk);
    input clk;
    input rst;
    output out_clk;
    reg [22:0] count, next_count;
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
        if (count == 25'b1111111111111111111111111) begin
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