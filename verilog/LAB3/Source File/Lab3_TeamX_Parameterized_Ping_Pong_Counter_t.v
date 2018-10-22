`timescale .5s/1ps

module Parameterized_Ping_Pong_Counter_t ();

    reg clk;
    reg rst_n, enable, flip,
    reg [3:0] max, min;
    wire direction;
    wire [3:0] out;

    Parameterized_Ping_Pong_Counter gate1(.clk(clk),
                                          .rst_n(rst_n),
                                          .enable(.enable),
                                          .flip(flip),
                                          .max(max),
                                          .min(min),
                                          .direction(direction),
                                          .out(out));


    always #(1)clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 1;
        #3 rst_n = 0;
        #4 rst_n = 1;
        #100 $finish;
    end

endmodule // Parameterized_Ping_Pong_Counter_t
