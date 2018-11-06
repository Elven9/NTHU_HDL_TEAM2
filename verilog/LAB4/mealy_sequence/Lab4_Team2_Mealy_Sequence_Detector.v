`timescale 1ns/1ps

module Mealy_Sequence_Detector (clk, rst_n, in, dec);
  input clk, rst_n;
  input in;
  output reg dec;

  parameter S0 = 3'b000;
  parameter S1 = 3'b001;
  parameter S2 = 3'b010;
  parameter S3 = 3'b011;
  parameter nS1 = 3'b100;
  parameter nS2 = 3'b101;
  parameter nS3 = 3'b110;

  reg [2:0] state, nextState;

  always @ ( posedge clk ) begin
    if (rst_n == 1'b0) begin
      state <= S0;
    end
    else begin
      state <= nextState;
    end
  end

  always @ ( * ) begin
    case (state)
      S0:
        if (in == 1'b1) begin
          nextState = S1;
          dec = 1'b0;
        end
        else begin
          nextState = nS1;
          dec = 1'b0;
        end
      S1:
        if (in == 1'b0) begin
          nextState = S2;
          dec = 1'b0;
        end
        else begin
          nextState = nS2;
          dec = 1'b0;
        end
      S2:
        if (in == 1'b0) begin
          nextState = S3;
          dec = 1'b0;
        end
        else begin
          nextState = nS3;
          dec = 1'b0;
        end
      S3:
        if (in == 1'b1) begin
          nextState = S0;
          dec = 1'b1;
        end
        else begin
          nextState = S0;
          dec = 1'b0;
        end
      nS1: begin
        nextState = nS2;
        dec = 1'b0;
      end
      nS2: begin
        nextState = nS3;
        dec = 1'b0;
      end
      nS3: begin
        nextState = S0;
        dec = 1'b0;
      end
    endcase
  end

endmodule
