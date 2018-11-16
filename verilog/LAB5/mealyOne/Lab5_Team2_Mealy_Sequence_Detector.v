`timescale 1ns/1ps

module Mealy_Sequence_Detector (clk, rst_n, in, dec);
input clk, rst_n;
input in;
output reg dec;

parameter S0 = 4'd0;
parameter S1 = 4'd1;
parameter S2 = 4'd2;
parameter S3 = 4'd3;
parameter nS2 = 4'd4;
parameter nS3 = 4'd5;
parameter rS1 = 4'd6;
parameter rS2 = 4'd7;
parameter rS3 = 4'd8;


reg [3:0] state, nextState;

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
        nextState = rS1;
        dec = 1'b0;
      end
    S1:
      if (in == 1'b1) begin
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
      if (in == 1'b0) begin
        nextState = S0;
        dec = 1'b1;
      end
      else begin
        nextState = S0;
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
    rS1: begin
      if (in == 1'b0) nextState = rS2;
      else nextState = nS2;
      dec = 1'b0;
    end
    rS2: begin
      if (in == 1'b1) nextState = rS3;
      else nextState = nS3;
      dec = 1'b0;
    end
    rS3: begin
      if (in == 1'b1) begin
        nextState = S0;
        dec = 1'b1;
      end
      else begin
        nextState = S0;
        dec = 1'b0;
      end
    end
  endcase
end

endmodule
