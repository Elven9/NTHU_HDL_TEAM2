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