`timescale 1ns/1ps

module Parameterized_Ping_Pong_Counter (clk, rst_n, enable, flip, max, min, direction, out);
    input clk, rst_n;
    input enable;
    input flip;
    input [4-1:0] max;
    input [4-1:0] min;
    output direction;
    output [4-1:0] out;

    reg [3:0] counter, next_counter;
    reg dir, next_dir;
    wire count_clk;

    
    always @ ( posedge clk ) begin
        if (rst_n == 0) begin
            counter <= min;
            dir <= 0;
        end
        else begin
            counter <= next_counter;
            dir <= next_dir;
        end
    end

    always @ ( * ) begin
        next_counter = counter;
        next_dir = dir;
        if (max > min && counter <= max && counter >= min && enable) begin
            if (flip == 1 || (counter == max && dir == 0) || (counter == min && dir == 1)) begin
                next_dir = !dir;
            end
            else begin
                next_dir = dir;
            end
            next_counter = next_dir ? counter - 1 : counter + 1;
        end
        else begin
            next_counter = counter;
            next_dir = dir;
        end
    end

    assign out = counter;
    assign direction = dir;

endmodule