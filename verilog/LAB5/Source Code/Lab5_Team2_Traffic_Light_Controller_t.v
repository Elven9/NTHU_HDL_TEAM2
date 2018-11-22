`timescale 1ns/1ps
`define CYC 2

module Traffic_Light_Controller_t ();

    reg clk, rst_n;
    wire [2:0] hw_light, lr_light;
    reg lr_has_car;
    wire [2:0] state;

    Traffic_Light_Controller controller(.clk(clk),
                                        .rst_n(rst_n),
                                        .lr_has_car(lr_has_car),
                                        .hw_light(hw_light),
                                        .lr_light(lr_light),
                                        .state(state));

    always #(1)clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 1;
        lr_has_car = 0;

        #`CYC rst_n = 0;
        #`CYC rst_n = 1;

        // Test In Free Period Has Car
        #(`CYC * 30 ) lr_has_car = 1;
        #`CYC lr_has_car = 0;

        #(`CYC * 20 ) lr_has_car = 1;
        #(`CYC * 15 ) lr_has_car = 0;

        #(`CYC * 10 ) lr_has_car = 1;
        #(`CYC * 30 ) lr_has_car = 0;

        #(`CYC * 100 ) $finish();

    end

endmodule // Parameterized_Ping_Pong_Counter_t