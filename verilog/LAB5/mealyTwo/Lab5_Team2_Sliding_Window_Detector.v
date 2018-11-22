`timescale 1ns/1ps

module Sliding_Window_Detector (clk, rst_n, in, dec1, dec2);
  input clk, rst_n;
  input in;
  output reg dec1, dec2;

  parameter S0 = 2'd0;
  parameter S1 = 2'd1;
  parameter S2 = 2'd2;
  parameter S3 = 2'd3; // Trapped State

  reg [1:0] stateOne, nextStateOne;
  reg [1:0] tripleOneCounter, nextCounter;

  parameter rS0 = 2'd0;
  parameter rS1 = 2'd1;
  parameter rS2 = 2'd2;
  parameter rS3 = 2'd3;

  reg [1:0] stateTwo, nextStateTwo;

  always @ ( posedge clk ) begin
    if (rst_n == 1'b0) begin
      stateOne <= S0;
      tripleOneCounter <= 2'd0;
      nextCounter <= 2'd0;
      stateTwo <= rS0;
    end
    else begin
      stateOne <= nextStateOne;
      tripleOneCounter <= nextCounter;
      stateTwo <= nextStateTwo;
    end
  end

  // dec1
  always @ ( * ) begin
    if (tripleOneCounter == 2'd3) begin
      nextStateOne = S3;
      nextCounter = 0;
      dec1 = 1'b0;
    end
    else begin
      case (stateOne)
        S0:
          if (in == 1'b1) begin
            nextStateOne = S1;
            dec1 = 1'b0;
            nextCounter = tripleOneCounter + 1;
          end
          else begin
            nextStateOne = S0;
            dec1 = 1'b0;
            nextCounter = 0;
          end
        S1:
          if (in == 1'b0) begin
            nextStateOne = S2;
            dec1 = 1'b0;
            nextCounter = 0;
          end
          else begin
            nextStateOne = S1;
            dec1 = 1'b0;
            nextCounter = tripleOneCounter + 1;
          end
        S2:
          if (in == 1'b1) begin
            nextStateOne = S1;
            dec1 = 1'b1;
            nextCounter = tripleOneCounter + 1;
          end
          else begin
            nextStateOne = S0;
            dec1 = 1'b0;
            nextCounter = 0;
          end
        S3: begin
          dec1 = 1'b0;
          nextStateOne = S3;
        end
      endcase
    end
  end

  always @ ( * ) begin
    case (stateTwo)
      rS0:
        if (in == 1'b0) begin
          nextStateTwo = rS1;
          dec2 = 1'b0;
        end
        else begin
          nextStateTwo = rS0;
          dec2 = 1'b0;
        end
      rS1:
        if (in == 1'b1) begin
          nextStateTwo = rS2;
          dec2 = 1'b0;
        end
        else begin
          nextStateTwo = rS0;
          dec2 = 1'b0;
        end
      rS2:
        if (in == 1'b1) begin
          nextStateTwo = rS3;
          dec2 = 1'b0;
        end
        else begin
          nextStateTwo = rS1;
          dec2 = 1'b0;
        end
      rS3:
        if (in == 1'b0) begin
          nextStateTwo = rS1;
          dec2 = 1'b1;
        end
        else begin
          nextStateTwo = rS0;
          dec2 = 1'b0;
        end
    endcase
  end

endmodule
