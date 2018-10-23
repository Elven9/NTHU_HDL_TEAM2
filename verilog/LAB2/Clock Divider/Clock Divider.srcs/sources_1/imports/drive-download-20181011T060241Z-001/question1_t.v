`timescale 1ns/1ps

module Clock_Divider_t;
  reg CLK, RESET;
  reg [2-1:0] SEL;
  wire DCLK;
  
  parameter cyc = 10;
  
  Clock_Divider C1 (
	.CLK(CLK),
	.RESET(RESET),
	.SEL(SEL),
	.DCLK(DCLK)
  );
  
  always #(cyc/2) CLK = ~CLK;
  
  initial
    begin
	  CLK = 1;
	  RESET = 0;
	  
	  SEL = 2'b00;
//	  #(cyc);
	  RESET = 1;
	  #(cyc);
	  RESET = 0;
	  #(cyc*24)
	  
	  SEL = 2'b01;
//	  #(cyc);
      RESET = 1;      
      #(cyc);
      RESET = 0;	   
	  #(cyc*24)
	  
	  SEL = 2'b10;
//	  #(cyc);
      RESET = 1;      
      #(cyc);
      RESET = 0;       
      #(cyc*24)
            
      SEL = 2'b11;
//      #(cyc);
      RESET = 1;      
      #(cyc);
      RESET = 0;       
      #(cyc*24)
      
	  $finish;
	end
endmodule