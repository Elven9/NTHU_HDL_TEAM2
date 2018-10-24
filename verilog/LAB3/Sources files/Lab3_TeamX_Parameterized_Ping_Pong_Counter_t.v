`timescale 10ns/1ps

module Parameterized_Ping_Pong_Counter_t ();

    reg clk;
    reg rst_n, enable, flip;
    reg [3:0] max, min;
    wire direction;
    wire [3:0] out;
    wire flip_out;

    Lab3_TeamX_Parameterized_Ping_Pong_Counter_fpga gate1(.clk(clk),
                                          .rst(rst_n),
                                          .enable(enable),
                                          .flip(flip),
                                          .max(max),
                                          .min(min),
                                          .out(out));

    always #(1)clk = ~clk;
    
    reg [3:0] delay;
        wire debounceSignal;
    
        reg pulse1, pulse2;
    
        // Debounce;
        always @ ( posedge clk ) begin
            delay[3:1] <= delay[2:0];
            delay[0] <= rst_n;
        end
        assign debounceSignal = delay == 4'b1111 ? 1 : 0;
    
        // One Pulse;
        always @ ( posedge clk ) begin
            pulse1 <= debounceSignal;
            pulse2 <= (!pulse1) & debounceSignal;
        end

    initial begin
        clk = 0;
        rst_n = 0;
        max = 15;
        min = 0;
        flip = 0;
        enable = 1;
        #50 rst_n = 1;
        #1 rst_n = 0;
        #1 rst_n = 1;
                #1 rst_n = 0;
                #1 rst_n = 1;
                        #1 rst_n = 0;
                        #1 rst_n = 1;
                                #1 rst_n = 0;
                                #1 rst_n = 1;
                                        #1 rst_n = 0;
                                        #1 rst_n = 1;
                                                #1 rst_n = 0;
                                             #1 rst_n = 1;
        #50 rst_n = 0;
        #1 flip = 1;
        #2 flip = 0;
        #2 flip = 1;
                #2 flip = 0;
                #2 flip = 1;
                        #2 flip = 0;
                        #2 flip = 1;
                                #2 flip = 0;
                                #2 flip = 1;
                                        #2 flip = 0;
                                        #2 flip = 1;
                                                #2 flip = 0;
                                                #2 flip = 1;
                                                        #2 flip = 0;
                                                        #2 flip = 1;
                                                        #100 flip = 0;
        
        #1000000000 $finish;
    end

endmodule // Parameterized_Ping_Pong_Counter_t
