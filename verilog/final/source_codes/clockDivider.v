// Generate 20ms clock
module clock_divider (
  input rst,
  input clk,
  output out_clk
);

  reg [29:0] count, nextCount;
  reg outClk, nextOutClk;

  always @ ( posedge clk ) begin
    if (rst) begin
      count <= 0;
      outClk <= 0;
    end
    else begin
      count <= nextCount;
      outClk <= nextOutClk;
    end
  end

  always @ ( * ) begin
    if (count == 30'd5000000) begin
      nextCount = 0;
      nextOutClk = !outClk;
    end
    else begin
      nextCount = count + 1;
      nextOutClk = outClk;
    end
  end

  assign out_clk = outClk;
endmodule