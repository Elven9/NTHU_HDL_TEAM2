`timescale 1ns/1ps

module Mealy_Sequence_Detector (clk, rst_n, in, dec);
  input clk, rst_n;
  input in;
  output reg dec;

  parameter S0 = 2'b00;
  parameter S1 = 2'b01;
  parameter S2 = 2'b10;
  parameter S3 = 2'b11;

  reg [1:0] state, nextState;

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
        if (in == 1'b0) begin
          nextState = S0;
          dec = 1'b0;
        end
        else begin
          nextState = S1;
          dec = 1'b0;
        end
      S1:
        if (in == 1'b0) begin
          nextState = S2;
          dec = 1'b0;
        end
        else begin
          nextState = S1;
          dec = 1'b0;
        end
      S2:
        if (in == 1'b0) begin
          nextState = S3;
          dec = 1'b0;
        end
        else begin
          nextState = S1;
          dec = 1'b0;
        end
      S3:
        if (in == 1'b0) begin
          nextState = S0;
          dec = 1'b0;
        end
        else begin
          nextState = S0;
          dec = 1'b1;
        end
    endcase
  end

endmodule
