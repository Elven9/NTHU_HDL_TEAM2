`timescale 10ns/1ps

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
                                          .out(out),
                                          .direction(direction));

    always #(1)clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 1;
        max = 15;
        min = 0;
        flip = 0;
        enable = 1;
        
        #2 rst_n = 0;
        #3 rst_n = 1;
        
        #5 flip = 1;
        #2 flip = 0;
        
        #8 rst_n = 0;
        #2 rst_n = 1;
        
        #10 enable = 0;
        #10 enable = 1;
        
        #500 $finish;
    end

endmodule // Parameterized_Ping_Pong_Counter_t