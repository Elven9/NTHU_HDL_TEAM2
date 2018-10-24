`timescale 10ns/1ps

module  Lab3_TeamX_Parameterized_Ping_Pong_Counter_fpga (clk, rst, enable, flip, max, min, an, out);
    input clk, rst;
    input enable;
    input flip;
    input [4-1:0] max;
    input [4-1:0] min;
    output [3:0] an;
    output [6:0] out;

    wire filtered_rst, filterd_flip;
    wire rst_n;
    wire display_clk, count_clk;
    wire [3:0] digit1, digit2;
    wire [3:0] counter_out;
    wire direction;
    wire [6:0] dir_display, digit1_display, digit2_display;

    reg [6:0] current_out, next_out;
    reg [3:0] current_an, next_an;

    Parameterized_Ping_Pong_Counter gate1(.clk(clk),
                                          .rst_n(rst_n),
                                          .enable(enable),
                                          .flip(filterd_flip),
                                          .max(max),
                                          .min(min),
                                          .direction(direction),
                                          .out(counter_out));
    // Debounce Reset and Flip Siginal.
    switch_pulse pulse1 (.clk(clk), .inSignal(rst), .filteredSignal(filtered_rst));
    switch_pulse pulse2 (.clk(clk), .inSignal(flip), .filteredSignal(filterd_flip));

    assign rst_n = !filtered_rst;

    // clock_divider
    clock_divider display (.rst(rst_n), .clk(clk), .out_clk(display_clk));

    // 7 Segament
    assign digit1 = counter_out >= 10 ? counter_out - 10 : counter_out;
    assign digit2 = counter_out >= 10 ? 1 : 0;
    segament_display digit1_dis (.display_number(digit1), .outport(digit1_display));
    segament_display digit2_dis (.display_number(digit2), .outport(digit2_display));

    direction_display direction_display (.dir(direction), .outport(dir_display));

    always @ ( posedge display_clk ) begin
        if (rst_n == 0) begin
            current_out <= 7'b1111111;
            current_an <= 4'b1110;
        end
        else begin
            current_out <= next_out;
            current_an <= next_an;
        end
    end

    always @ ( * ) begin
        case (current_an)
            4'b1110:begin
                next_out = digit2_display;
                next_an = 4'b1101;
            end
            4'b1101:begin
                next_out = dir_display;
                next_an = 4'b1011;
            end
            4'b1011:begin
                next_out = dir_display;
                next_an = 4'b0111;
            end
            4'b0111:begin
                next_out = digit1_display;
                next_an = 4'b1110;
            end
            default: begin
                next_out = current_out;
                next_an = current_an;
            end
        endcase
    end
    
    assign an = current_an;
    assign out = current_out;

endmodule //  Lab3_TeamX_Parameterized_Ping_Pong_Counter_fpga

module direction_display (dir, outport);
    input dir;
    output [6:0] outport;

    assign outport = dir ? 7'b1100011 : 7'b1011100;

endmodule

module segament_display (display_number, outport);
    input [3:0] display_number;
    output [6:0] outport;

    assign outport[0] = !(display_number == 0 || display_number == 2 || display_number == 3 || display_number == 5 || display_number == 6 || display_number == 7 || display_number == 8 || display_number == 9 || display_number == 10 || display_number == 12 || display_number == 14 || display_number == 15);
    assign outport[1] = !(display_number == 0 || display_number == 2 || display_number == 3 || display_number == 4 || display_number == 1 || display_number == 7 || display_number == 8 || display_number == 9 || display_number == 10 || display_number == 13);
    assign outport[2] = !(display_number == 0 || display_number == 1 || display_number == 3 || display_number == 5 || display_number == 6 || display_number == 7 || display_number == 8 || display_number == 9 || display_number == 10 || display_number == 11 || display_number == 13 || display_number == 4);
    assign outport[3] = !(display_number == 0 || display_number == 2 || display_number == 3 || display_number == 5 || display_number == 6 || display_number == 11 || display_number == 8 || display_number == 9 || display_number == 12 || display_number == 13 || display_number == 14);
    assign outport[4] = !(display_number == 0 || display_number == 2 || display_number == 6 || display_number == 8 || display_number == 10 || display_number == 11 || display_number == 12 || display_number == 13 || display_number == 14 || display_number == 15);
    assign outport[5] = !(display_number == 0 || display_number == 4 || display_number == 5 || display_number == 6 || display_number == 8 || display_number == 9 || display_number == 10 || display_number == 11 || display_number == 12 || display_number == 14 || display_number == 15);
    assign outport[6] = !(display_number == 4 || display_number == 2 || display_number == 3 || display_number == 5 || display_number == 6 || display_number == 11 || display_number == 8 || display_number == 9 || display_number == 10 || display_number == 13 || display_number == 14 || display_number == 15);

endmodule

module clock_divider(rst, clk, out_clk);
    input clk;
    input rst;
    output out_clk;
    reg [16:0] count, next_count;
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
        if (count == 17'b11111111111111111) begin
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

module switch_pulse (clk, inSignal, filteredSignal);
    input inSignal;
    input clk;
    output filteredSignal;

    reg [3:0] delay;
    wire debounceSignal;

    reg pulse1, pulse2;

    // Debounce;
    always @ ( posedge clk ) begin
        delay[3:1] <= delay[2:0];
        delay[0] <= inSignal;
    end
    assign debounceSignal = delay == 4'b1111 ? 1 : 0;

    // One Pulse;
    always @ ( posedge clk ) begin
        pulse1 <= debounceSignal;
        pulse2 <= (!pulse1) & debounceSignal;
    end

    assign filteredSignal = pulse2;
endmodule
