`timescale 1ns/1ps

module Greatest_Common_Divisor (clk, rst_n, start, a, b, done, gcd);
  input clk, rst_n;
  input start;
  input [8-1:0] a;
  input [8-1:0] b;
  output reg done;
  output reg [8-1:0] gcd;

  parameter WAIT = 2'b00;
  parameter CAL = 2'b01;
  parameter FINISH = 2'b10;

  reg [1:0] state, nextState;
  reg [7:0] regA, regB, nextA, nextB, ans;

  always @ ( posedge clk ) begin
    if (rst_n == 1'b0) begin
      state <= WAIT;
    end
    else begin
      state <= nextState;
      regA <= nextA;
      regB <= nextB;

      if (state == FINISH) begin
        gcd <= ans;
        done <= 1'b1;
      end
      else begin
        gcd <= 8'd0;
        done <= 1'b0;
      end
    end
  end

  always @ ( * ) begin
    case (state)
      WAIT: begin
        nextA = a;
        nextB = b;
        regA = a;
        regB = b;
        if (start == 1'b1) nextState = CAL;
        else nextState = WAIT;
      end
      CAL: begin
        if (regA == 8'd0) begin
          ans = regB;
          nextState = FINISH;
        end
        else begin
          if (regB != 8'd0) begin
            if (regA > regB) nextA = regA - regB;
            else nextB = regB - regA;
          end
          else begin
            ans = regA;
            nextState = FINISH;
          end
        end
      end
      FINISH: begin
        nextState = WAIT;
      end
    endcase
  end

endmodule
