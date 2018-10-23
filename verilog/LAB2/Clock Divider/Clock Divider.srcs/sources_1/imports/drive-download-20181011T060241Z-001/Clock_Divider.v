module Clock_Divider (CLK, RESET, SEL, DCLK);
    input CLK, RESET;
    input [1:0] SEL;
    output DCLK;

    reg CLK_2, CLK_4, CLK_8;
    reg CLK_3, CLK_3_next;
    reg [1:0] counter, counter_next;

    wire [3:0] out_clk;

    // CLK_2
    Single_divider gate_d(.clk(CLK), .out_clk(CLK_2), .RESET(RESET));

    // CLK_4
    Single_divider gate_c(.clk(CLK_2), .out_clk(CLK_4), .RESET(RESET));

    // CLK_8
    Single_divider gate_b(.clk(CLK_4), .out_clk(CLK_8), .RESET(RESET));

    // CLK_3
    always @ ( CLK or posedge RESET ) begin
        if (RESET == 1) begin
            counter_next <= 1;
        end
        else begin
            counter <= counter_next;
            counter_next <= counter == 3 ? 1 : counter + 1;
        end
    end

    always @ ( counter or posedge RESET ) begin
        if (RESET == 1) begin
            CLK_3 <= 0;
        end
        else begin
            CLK_3 <= CLK_3_next;
        end
    end

    always @ ( * ) begin
        if (RESET == 1) begin
            CLK_3_next <= 1;
        end
        else begin
            if (counter == 2) begin
                CLK_3_next <= !CLK_3;
            end
            else begin
                CLK_3_next <= CLK_3;
            end
        end
    end

    assign out_clk = {CLK_3, CLK_8, CLK_4, CLK_2};
    assign DCLK = out_clk[SEL];

endmodule // Clock_Divider

module Single_divider(clk, out_clk, RESET);

    input clk, RESET;
    output out_clk;

    reg CLK, CLK_next;
    always @ ( posedge clk or posedge RESET ) begin
        if (RESET == 1) begin
            CLK_next <= 1;
        end
        else begin
            CLK <= CLK_next;
        end
    end

    always @ ( * ) begin
        if (RESET == 1) begin
            CLK <= 0;
        end
        else begin
            CLK_next <= !CLK;
        end
    end

    assign out_clk = CLK;
endmodule
