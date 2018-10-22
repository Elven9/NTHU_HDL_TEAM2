`timescale 1s/1ps

module Parameterized_Ping_Pong_Counter_t ();

    reg clk;
    reg rst_n, enable, flip;
    reg [3:0] max, min;
    wire direction;
    wire [3:0] out;

    Parameterized_Ping_Pong_Counter gate1(.clk(clk),
                                          .rst_n(rst_n),
                                          .enable(enable),
                                          .flip(flip),
                                          .max(max),
                                          .min(min),
                                          .direction(direction),
                                          .out(out));


    always #(1)clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 1;
        max = 15;
        min = 0;
        flip = 0;
        enable = 1;
        #3 rst_n = 0;
        #4 rst_n = 1;
        #51 begin
            flip = 1;
        end
        #2 begin
            flip = 0;
        end
        #100 $finish;
    end

endmodule // Parameterized_Ping_Pong_Counter_t
