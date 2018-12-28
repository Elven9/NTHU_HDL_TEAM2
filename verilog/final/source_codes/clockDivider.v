// Generate .1s clock
module clock_divider(rst, clk, out_clk);
    input clk;
    input rst;
    output out_clk;
    reg [29:0] count, next_count;
    reg outClk, nextOutClk;

    always @ ( posedge clk ) begin
        if (rst == 1) begin
            count <= 0;
            outClk <= 0;
        end
        else begin
            count <= next_count;
            outClk <= nextOutClk;
        end
    end

    always @ ( * ) begin
        if (count == 30'd5000000) begin
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