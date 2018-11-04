module Lab4_TeamX_Stopwatch_fpga (clk, start, reset, an, out);
  input clk, start, reset;
  output [3:0] an;
  output [6:0] out;

  

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