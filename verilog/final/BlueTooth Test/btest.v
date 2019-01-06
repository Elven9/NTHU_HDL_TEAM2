`define bluetooth_idle 2'b00
`define bluetooth_start 2'b01
`define bluetooth_recv 2'b10
`define bluetooth_end 2'b11

module mainModule(rx, data_out, clk, in_rst, state_out);
  input rx, clk, in_rst;
  output [7:0] data_out;
  output [3:0] state_out;

  wire rst;

  // Btest
  btest bluetooth_module(
    .rx(rx),
    .clk(clk),
    .data(data_out), 
    .rst(rst),
    .state_out(state_out)
  );

  // buttom
  switch_pulse pulse1 (.clk(clk), .inSignal(in_rst), .filteredSignal(rst));

endmodule

module btest(rx, clk, data, rst, state_out);
  input rx, clk, rst;
  output reg [7:0] data;
  output reg [3:0] state_out;

  // State
  reg [1:0] state, next_state;

  // Data Buffer
  reg next_data;
  reg [7:0] data_buffer;
  reg [7:0] n_data;

  // Data bit count
  reg [2:0] d_count, n_d_count;

  // Check Counter
  reg [13:0] b_count, n_b_count;
  reg [9:0] c_count, n_c_count;

  // Initial Count
  reg [3:0] i_count, n_i_count;
  
  // flag
  reg toSample, n_toSample;

  // DFF
  always @ (posedge clk) begin
    if (rst == 1) begin
      state <= `bluetooth_idle;
      d_count <= 0;
      b_count <= 0;
      c_count <= 0;
      i_count <= 0;
      toSample <= 0;
      data <= 8'd0;
    end
    else begin
      state <= next_state;
      b_count <= n_b_count;
      c_count <= n_c_count;
      d_count <= n_d_count;
      i_count <= n_i_count;
      toSample <= n_toSample;
      data <= n_data;
    end
  end

  // Sequencial
  always @ (*) begin
    if (rst) n_data = 8'd0;
    case (state)
      `bluetooth_idle:begin
        state_out = 4'b0001;
        data_buffer = 8'd0;
        next_state = rx == 0 ? `bluetooth_start : state;
      end
      `bluetooth_start:begin
        state_out = 4'b0010;
        if (toSample) begin
          next_state = rx == 0 && i_count == 4'd15 ? `bluetooth_recv : state;
        end
        else begin
          next_state = state;
        end
      end
      `bluetooth_recv:begin
        state_out = 4'b0100;
        if (toSample) begin
          data_buffer[d_count] = rx;
          if (d_count == 3'd7) begin
            next_state = `bluetooth_end;
          end
          else begin
            next_state = state;
          end
        end
        else begin
          next_state = state;
        end
      end
      `bluetooth_end:begin
        state_out = 4'b1000;
        n_data = data_buffer;
        next_state = `bluetooth_idle;
      end 
      default:
        next_state = state;
    endcase
  end
  
  always @ (*) begin
    if (state == `bluetooth_recv) begin
      if (b_count == 14'd10417) begin
        n_b_count = 0;
        n_d_count = d_count + 1;
      end
      else begin
        n_b_count = b_count + 1;
        n_d_count = d_count;
      end

      if (c_count == 10'd652) begin
        n_c_count = 0;
      end
      else begin
        n_c_count = c_count + 1;
        n_toSample = c_count == 10'd326 ? 1 : 0;
      end
    end
    else if (state == `bluetooth_start) begin
      if (c_count == 10'd652) begin
        n_c_count = 0;
        n_i_count = i_count + 1;
      end
      else begin
        n_c_count = c_count + 1;
        n_toSample = c_count == 10'd326 ? 1 : 0;
      end
    end
    else begin
      n_b_count = 0;
      n_c_count = 0;
      n_d_count = 0;
      n_i_count = 0;
    end
  end

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