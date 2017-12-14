`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:33:43 12/04/2017 
// Design Name: 
// Module Name:    top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module top(input clk,
				input rst,
				
			 input btnu,
			 input btnd,
			 input btnl,
			 input btnr,
			output Hsync,
			output Vsync,
			output [7:0] lcd_data,
			output [3:0] sel,
			output [6:0] seg
    );
wire clk_50m;
wire clk_25m;
wire [11:0] scan_x;
wire [11:0] scan_y;
wire u,d,l,r;

wire [3:0] score4;
wire [3:0] score3;
wire [3:0] score2;
wire [3:0] score1;

debounce de(clk_25m,btnu,btnd,btnl,btnr,u,d,l,r);
slowclk h(clk,clk_50m);
slowclk h2(clk_50m,clk_25m);

data p(clk_25m,rst,scan_x,scan_y,lcd_data,u,d,l,r,score4,score3,score2,score1);
segshow sh(clk_25m,sel,seg,score4,score3,score2,score1);
vga_drive vga(clk_25m,rst,Hsync,Vsync,scan_x,scan_y);

endmodule
