module top(
  input clk,
  input rst,
  output [3:0] vgaRed,
  output [3:0] vgaGreen,
  output [3:0] vgaBlue,
  output hsync,
  output vsync,
  // Keyboard
  inout wire PS2_DATA;
  inout wire PS2_CLK;
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
  wire been_ready;
  KeyboardDecoder key_de (
    .key_down(key_down),
    .last_change(last_change),
    .key_valid(been_ready),
    .PS2_DATA(PS2_DATA),
    .PS2_CLK(PS2_CLK),
    .rst(RESET),
    .clk(clk)
  );

  wire right, left, up, down;
  OnePulse pulse6 (.clock(clk), .signal(key_down[9'b011001011]), .signal_single_pulse(left));
  OnePulse pulse7 (.clock(clk), .signal(key_down[9'b001110100]), .signal_single_pulse(right));
  OnePulse pulse8 (.clock(clk), .signal(key_down[9'b001110101]), .signal_single_pulse(up));
  OnePulse pulse9 (.clock(clk), .signal(key_down[9'b001110010]), .signal_single_pulse(down));

  clock_divisor clk_wiz_0_inst(
    .clk(clk),
    .clk1(clk_25MHz),
    .clk22(clk_22)
  );

  mem_addr_gen mem_addr_gen_inst(
    .clk(clk_22),
    .rst(rst),
    .h_cnt(h_cnt),
    .v_cnt(v_cnt),
    .pixel_addr(pixel_addr),
    .left(left),
    .right(right),
    .up(up),
    .down(down)
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
    .reset(rst),
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
  output [16:0] pixel_addr
  );
  
  reg [7:0] position;

  assign pixel_addr = ((h_cnt>>1)+320*(v_cnt>>1)+ position*320 )% 76800;  //640*480 --> 320*240 

  reg [7:0] pos_y, next_pos_y;
  reg [7:0] pos_x, next_pos_x;
  
  always @ (posedge clk or posedge rst) begin
    if(rst) begin
      pos_x <= 0;
      pos_y <= 0;
    else begin
      pos_x <= next_pos_x;
      pos_y <= next_pos_y;
    end
  end
  
  reg dir_x, dir_y;
  always @(*) begin
    if (rst) begin
      dir_x = 0;
      dir_y = 0;
    end
    if (left) dir_x = 1;
    if (right) dir_x = -1;
    if (up) dir_y = 1;
    if (down) dir_y = -1;

    
    if (dir_x == 1) next_pos_x = pos_x + 1;
    else if (dir_x == -1) next_pos_x = pos_x - 1;
    else next_pos_x = pos_x;

    if (dir_y == 1) next_pos_y = pos_y + 1;
    else if (dir_y == -1) next_pos_y = pos_y - 1;
    else next_pos_y = pos_y;

  end
    
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