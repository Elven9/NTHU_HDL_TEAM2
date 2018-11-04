`timescale 10ns/1ps

module Parameterized_Ping_Pong_Counter_t ();

    reg clk;
    reg rst_n, enable, flip;
    reg [3:0] sec_ten, min;
    reg [7:0] sec
    wire direction;
    wire [3:0] out;

    Time_Counter gate1(.clk(clk),
                       .reset(rst_n),
                       .start(flip),
                       .minute(min), 
                       .second(sec), 
                       .ten_second(sec_ten));

    always #(1)clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        max = 15;
        min = 0;
        flip = 0;
        enable = 0;
        
        #2 rst_n = 1;
        #3 rst_n = 0;
        
        #5 flip = 1;
        #2 flip = 0;
        
        #8 rst_n = 1;
        #2 rst_n = 0;
        
        #10 enable = 1;
        #10 enable = 0;
        
        #500 $finish;
    end

endmodule // Parameterized_Ping_Pong_Counter_t