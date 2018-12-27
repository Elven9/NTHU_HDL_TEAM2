module top(
  input clk,
  input rst,
  output [3:0] vgaRed,
  output [3:0] vgaGreen,
  output [3:0] vgaBlue,
  output hsync,
  output vsync,
  output [3:0] light,
  // Keyboard
  inout wire PS2_DATA,
  inout wire PS2_CLK
);

  wire [11:0] data;
  wire clk_25MHz;
  wire clk_22;
  wire [16:0] pixel_addr;
  wire [11:0] pixel;
  wire valid;
  wire [9:0] h_cnt; //640
  wire [9:0] v_cnt;  //480

  assign {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel:12'h0;

  // Keyboard
  wire [511:0] key_down;
  wire [8:0] last_change;
  wire been_ready, filtered_rst;

  switch_pulse sw1 (.clk(clk), .inSignal(rst), .filteredSignal(filtered_rst));

  KeyboardDecoder key_de (
    .key_down(key_down),
    .last_change(last_change),
    .key_valid(been_ready),
    .PS2_DATA(PS2_DATA),
    .PS2_CLK(PS2_CLK),
    .rst(filtered_rst),
    .clk(clk)
  );

  reg right, left, up, down;
  wire f_v, f_h;

  parameter keyH = 9'b000110011;
  parameter keyV = 9'b000101010;
  parameter keyP = 9'b001001101;


  OnePulse pulse1 (.clock(clk), .signal(key_down[keyP]), .signal_single_pulse(f_p));
  OnePulse pulse2 (.clock(clk), .signal(key_down[keyV]), .signal_single_pulse(f_v));
  OnePulse pulse3 (.clock(clk), .signal(key_down[keyH]), .signal_single_pulse(f_h));

  assign light = {key_down[9'b001101011], key_down[9'b001110100], key_down[9'b001110101], key_down[9'b001110010]};

  reg relay_v, relay_h, relay_p;
  always @ ( posedge clk_22, posedge f_v ) begin
    if (f_v) relay_v = 1'b1;
    else relay_v = 1'b0;
  end

  always @ ( posedge clk_22, posedge f_h ) begin
    if (f_h) relay_h = 1'b1;
    else relay_h = 1'b0;
  end

  always @ ( posedge clk_22, posedge f_p ) begin
    if (f_p) relay_p = 1'b1;
    else relay_p = 1'b0;
  end

  clock_divisor clk_wiz_0_inst(
    .clk(clk),
    .clk1(clk_25MHz),
    .clk22(clk_22)
  );

  mem_addr_gen mem_addr_gen_inst(
    .clk(clk_22),
    .rst(filtered_rst),
    .h_cnt(h_cnt),
    .v_cnt(v_cnt),
    .pixel_addr(pixel_addr),
    .left(key_down[9'b001101011]),
    .right(key_down[9'b001110100]),
    .up(key_down[9'b001110101]),
    .down(key_down[9'b001110010]),
    .pause(relay_p),
    .v_flip(relay_v),
    .h_flip(relay_h)
  );


  blk_mem_gen_0 blk_mem_gen_0_inst(
    .clka(clk_25MHz),
    .wea(0),
    .addra(pixel_addr),
    .dina(data[11:0]),
    .douta(pixel)
  );

  vga_controller   vga_inst(
    .pclk(clk_25MHz),
    .reset(filtered_rst),
    .hsync(hsync),
    .vsync(vsync),
    .valid(valid),
    .h_cnt(h_cnt),
    .v_cnt(v_cnt)
  );

endmodule

module mem_addr_gen(
  input clk,
  input rst,
  input [9:0] h_cnt,
  input [9:0] v_cnt,
  input left,
  input right,
  input up,
  input down,
  input pause,
  input v_flip,
  input h_flip,
  output reg [16:0] pixel_addr
  );

  reg [7:0] pos_y, next_pos_y;
  reg [8:0] pos_x, next_pos_x;
  reg [1:0] dir_x, n_dir_x, dir_y, n_dir_y, keep_dir_x, keep_dir_y, n_keep_dir_x, n_keep_dir_y;

  parameter WIDTH = 320;
  parameter HEIGHT = 240;

  wire [8:0] addr_h, addr_v;
  assign addr_h = ((h_cnt>>1) + pos_x) % WIDTH;
  assign addr_v = ((v_cnt>>1) + pos_y) % HEIGHT;

  reg [1:0] flip_dir, next_flip_dir;
  always @ ( * ) begin
    if (v_flip) next_flip_dir[0] = !flip_dir[0];
    else next_flip_dir[0] = flip_dir[0];

    if (h_flip) next_flip_dir[1] = !flip_dir[1];
    else next_flip_dir[1] = flip_dir[1];
  end


  always @ ( * ) begin
    case (flip_dir)
      2'b00: pixel_addr = (addr_h + (addr_v)*WIDTH) % 76800;
      2'b01: pixel_addr = (addr_h + (HEIGHT - addr_v)*WIDTH) % 76800;
      2'b10: pixel_addr = ((WIDTH - addr_h) + addr_v*WIDTH) % 76800;
      2'b11: pixel_addr = ((WIDTH - addr_h) + (HEIGHT - addr_v)*WIDTH) % 76800;
      default: pixel_addr = (addr_h + (addr_v)*WIDTH) % 76800;
    endcase
  end

  always @ (posedge clk or posedge rst) begin
    if(rst) begin
      pos_x <= 0;
      pos_y <= 0;
      dir_x <= 0;
      dir_y <= 0;
      flip_dir <= 2'b00;
      state <= INITIAL;
      keep_dir_x <= 0;
      keep_dir_y <= 0;
    end
    else begin
      pos_x <= next_pos_x;
      pos_y <= next_pos_y;
      dir_x <= n_dir_x;
      dir_y <= n_dir_y;
      flip_dir <= next_flip_dir;
      state <= next_state;
      keep_dir_x <= n_keep_dir_x;
      keep_dir_y <= n_keep_dir_y;
    end
  end

  parameter INITIAL = 2'b00;
  parameter STOP = 2'b01;
  parameter MOVE = 2'b10;

  reg [1:0] state, next_state;

  always @ ( * ) begin
    case (state)
      INITIAL: begin
        // Direction
        n_dir_x = dir_x;
        n_dir_y = dir_y;
        if (left) begin
          n_dir_x = 1;
          n_keep_dir_x = 1;
          n_dir_y = 0;
          n_keep_dir_y = 0;
          next_state = MOVE;
        end
        else if (right) begin
          n_dir_x = 2;
          n_keep_dir_x = 2;
          n_dir_y = 0;
          n_keep_dir_y = 0;
          next_state = MOVE;
        end
        else if (up || pause) begin
          n_dir_y = 1;
          n_keep_dir_y = 1;
          n_dir_x = 0;
          n_keep_dir_x = 0;
          next_state = MOVE;
        end
        else if (down) begin
          n_dir_y = 2;
          n_keep_dir_y = 2;
          n_dir_x = 0;
          n_keep_dir_x = 0;
          next_state = MOVE;
        end
        else if (v_flip || h_flip) begin
          n_dir_x = dir_x;
          n_dir_y = dir_y;
          n_keep_dir_x = keep_dir_x;
          n_keep_dir_y = keep_dir_y;
          next_state = MOVE;
        end
        else begin
          n_dir_x = dir_x;
          n_dir_y = dir_y;
          n_keep_dir_x = keep_dir_x;
          n_keep_dir_y = keep_dir_y;
          next_state = state;
        end
      end
      STOP: begin
        if (pause) begin
          next_state = MOVE;
          n_dir_x = keep_dir_x;
          n_dir_y = keep_dir_y;
        end
        else begin
          next_state = state;
          if (left) begin
            n_keep_dir_x = 1;
            n_keep_dir_y = 0;
          end
          else if (right) begin
            n_keep_dir_x = 2;
            n_keep_dir_y = 0;
          end
          else if (up) begin
            n_keep_dir_y = 1;
            n_keep_dir_x = 0;
          end
          else if (down) begin
            n_keep_dir_y = 2;
            n_keep_dir_x = 0;
          end
          else begin // here
            n_keep_dir_x = keep_dir_x;
            n_keep_dir_y = keep_dir_y;
          end
          n_dir_x = 0;
          n_dir_y = 0;
        end
      end
      MOVE: begin
        if (pause) next_state = STOP;
        else next_state = state;

        // Direction
        n_dir_x = dir_x;
        n_dir_y = dir_y;
        if (left) begin
          n_dir_x = 1;
          n_keep_dir_x = 1;
          n_dir_y = 0;
          n_keep_dir_y = 0;
        end
        else if (right) begin
          n_dir_x = 2;
          n_keep_dir_x = 2;
          n_dir_y = 0;
          n_keep_dir_y = 0;
        end
        else if (up) begin
          n_dir_y = 1;
          n_keep_dir_y = 1;
          n_dir_x = 0;
          n_keep_dir_x = 0;
        end
        else if (down) begin
          n_dir_y = 2;
          n_keep_dir_y = 2;
          n_dir_x = 0;
          n_keep_dir_x = 0;
        end
        else begin
          n_dir_x = dir_x;
          n_dir_y = dir_y;
          n_keep_dir_x = keep_dir_x;
          n_keep_dir_y = keep_dir_y;
        end
      end
    endcase
  end

  always @(*) begin
    if (dir_x == 1) next_pos_x = pos_x == 319 ? 0 : pos_x + 1;
    else if (dir_x == 2) next_pos_x = pos_x == 0 ? 319 : pos_x - 1;
    else next_pos_x = pos_x;

    if (dir_y == 1) next_pos_y = pos_y == 239 ? 0 : pos_y + 1;
    else if (dir_y == 2) next_pos_y = pos_y == 0 ? 239 : pos_y - 1;
    else next_pos_y = pos_y;
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

module vga_controller
  (
    input wire pclk,reset,
    output wire hsync,vsync,valid,
    output wire [9:0]h_cnt,
    output wire [9:0]v_cnt
    );

    reg [9:0]pixel_cnt;
    reg [9:0]line_cnt;
    reg hsync_i,vsync_i;
    wire hsync_default, vsync_default;
    wire [9:0] HD, HF, HS, HB, HT, VD, VF, VS, VB, VT;


    assign HD = 640;
    assign HF = 16;
    assign HS = 96;
    assign HB = 48;
    assign HT = 800;
    assign VD = 480;
    assign VF = 10;
    assign VS = 2;
    assign VB = 33;
    assign VT = 525;
    assign hsync_default = 1'b1;
    assign vsync_default = 1'b1;

    always@(posedge pclk)
        if(reset)
            pixel_cnt <= 0;
        else if(pixel_cnt < (HT - 1))
                pixel_cnt <= pixel_cnt + 1;
             else
                pixel_cnt <= 0;

    always@(posedge pclk)
        if(reset)
            hsync_i <= hsync_default;
        else if((pixel_cnt >= (HD + HF - 1))&&(pixel_cnt < (HD + HF + HS - 1)))
                hsync_i <= ~hsync_default;
            else
                hsync_i <= hsync_default;

    always@(posedge pclk)
        if(reset)
            line_cnt <= 0;
        else if(pixel_cnt == (HT -1))
                if(line_cnt < (VT - 1))
                    line_cnt <= line_cnt + 1;
                else
                    line_cnt <= 0;

    always@(posedge pclk)
        if(reset)
            vsync_i <= vsync_default;
        else if((line_cnt >= (VD + VF - 1))&&(line_cnt < (VD + VF + VS - 1)))
            vsync_i <= ~vsync_default;
        else
            vsync_i <= vsync_default;

    assign hsync = hsync_i;
    assign vsync = vsync_i;
    assign valid = ((pixel_cnt < HD) && (line_cnt < VD));

    assign h_cnt = (pixel_cnt < HD) ? pixel_cnt:10'd0;
    assign v_cnt = (line_cnt < VD) ? line_cnt:10'd0;

endmodule

module clock_divisor(clk1, clk, clk22);
  input clk;
  output clk1;
  output clk22;
  reg [21:0] num;
  wire [21:0] next_num;

  always @(posedge clk) begin
    num <= next_num;
  end

  assign next_num = num + 1'b1;
  assign clk1 = num[1];
  assign clk22 = num[21];
endmodule

module KeyboardDecoder(
  output reg [511:0] key_down,
  output wire [8:0] last_change,
  output reg key_valid,
  inout wire PS2_DATA,
  inout wire PS2_CLK,
  input wire rst,
  input wire clk
    );

  parameter [1:0] INIT      = 2'b00;
  parameter [1:0] WAIT_FOR_SIGNAL = 2'b01;
  parameter [1:0] GET_SIGNAL_DOWN = 2'b10;
  parameter [1:0] WAIT_RELEASE    = 2'b11;

  parameter [7:0] IS_INIT      = 8'hAA;
  parameter [7:0] IS_EXTEND    = 8'hE0;
  parameter [7:0] IS_BREAK    = 8'hF0;

  reg [9:0] key;    // key = {been_extend, been_break, key_in}
  reg [1:0] state;
  reg been_ready, been_extend, been_break;

  wire [7:0] key_in;
  wire is_extend;
  wire is_break;
  wire valid;
  wire err;

  wire [511:0] key_decode = 1 << last_change;
  assign last_change = {key[9], key[7:0]};

  KeyboardCtrl_0 inst (
  .key_in(key_in),
  .is_extend(is_extend),
  .is_break(is_break),
  .valid(valid),
  .err(err),
  .PS2_DATA(PS2_DATA),
  .PS2_CLK(PS2_CLK),
  .rst(rst),
  .clk(clk)
);

OnePulse op (
  .signal_single_pulse(pulse_been_ready),
  .signal(been_ready),
  .clock(clk)
);

  always @ (posedge clk, posedge rst) begin
    if (rst) begin
      state <= INIT;
      been_ready  <= 1'b0;
      been_extend <= 1'b0;
      been_break  <= 1'b0;
      key <= 10'b0_0_0000_0000;
    end else begin
      state <= state;
    been_ready  <= been_ready;
    been_extend <= (is_extend) ? 1'b1 : been_extend;
    been_break  <= (is_break ) ? 1'b1 : been_break;
    key <= key;
      case (state)
        INIT : begin
            if (key_in == IS_INIT) begin
              state <= WAIT_FOR_SIGNAL;
              been_ready  <= 1'b0;
            been_extend <= 1'b0;
            been_break  <= 1'b0;
            key <= 10'b0_0_0000_0000;
            end else begin
              state <= INIT;
            end
          end
        WAIT_FOR_SIGNAL : begin
            if (valid == 0) begin
              state <= WAIT_FOR_SIGNAL;
              been_ready <= 1'b0;
            end else begin
              state <= GET_SIGNAL_DOWN;
            end
          end
        GET_SIGNAL_DOWN : begin
          state <= WAIT_RELEASE;
          key <= {been_extend, been_break, key_in};
          been_ready  <= 1'b1;
          end
        WAIT_RELEASE : begin
            if (valid == 1) begin
              state <= WAIT_RELEASE;
            end else begin
              state <= WAIT_FOR_SIGNAL;
              been_extend <= 1'b0;
              been_break  <= 1'b0;
            end
          end
        default : begin
            state <= INIT;
          been_ready  <= 1'b0;
          been_extend <= 1'b0;
          been_break  <= 1'b0;
          key <= 10'b0_0_0000_0000;
          end
      endcase
    end
  end

  always @ (posedge clk, posedge rst) begin
    if (rst) begin
      key_valid <= 1'b0;
      key_down <= 511'b0;
    end else if (key_decode[last_change] && pulse_been_ready) begin
      key_valid <= 1'b1;
      if (key[8] == 0) begin
        key_down <= key_down | key_decode;
      end else begin
        key_down <= key_down & (~key_decode);
      end
    end else begin
      key_valid <= 1'b0;
    key_down <= key_down;
    end
  end

endmodule

module OnePulse (
	output reg signal_single_pulse,
	input wire signal,
	input wire clock
	);

	reg signal_delay;

	always @(posedge clock) begin
		if (signal == 1'b1 & signal_delay == 1'b0)
		  signal_single_pulse <= 1'b1;
		else
		  signal_single_pulse <= 1'b0;

		signal_delay <= signal;
	end
endmodule
