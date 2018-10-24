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
    reg out_flip;
    reg out_rst;
    wire inverse_rst;
    
    clock_divider_count gate_count_display(.rst(rst_n), .clk(clk), .out_clk(count_clk));
    
    always @ (posedge count_clk , posedge flip) begin
        if (flip == 1) out_flip = 1;
        else out_flip = 0;
    end
    
    assign inverse_rst = !rst_n;
    always @ (posedge count_clk ,  posedge inverse_rst) begin
        if (inverse_rst == 1) out_rst = 0;
        else out_rst = 1;
    end
    
    always @ ( posedge count_clk ) begin
        if (out_rst == 0) begin
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
            if (out_flip == 1 || (counter == max && dir == 0) || (counter == min && dir == 1)) begin
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

module clock_divider_count(rst, clk, out_clk);
    input clk;
    input rst;
    output out_clk;
    reg [24:0] count, next_count;
    reg outClk, nextOutClk;

    always @ ( posedge clk ) begin
        if (rst == 0) begin
            count <= 0;
            outClk <= 0;
        end
        else begin
            count <= next_count;
            outClk <= nextOutClk;
        end
    end

    always @ ( * ) begin
        if (count == 25'b1111111111111111111111111) begin
            next_count = 0;
            nextOutClk = !outClk;
        end
        else begin
            next_count = count + 1;
            nextOutClk = outClk;
        end
    end
    assign out_clk = outClk;
endmodule