`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:08:38 12/05/2017 
// Design Name: 
// Module Name:    vga_display 
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
`include "vga_conf.v"
module vga_drive(
	input 					clk,
	input 					rst_n,
	output 	reg 			lcd_hs,//��ͬ���ź�
	output 	reg 			lcd_vs,//��ͬ���ź�
	output 			[11:0]	lcd_y,
	output 			[11:0]	lcd_x
    );				

	
			
 reg 			lcd_vsen;//��ɨ������źţ���ɨ��ʹ���ź�
 reg 			lcd_vidon;
 reg 	[11:0] 	hcnt;
 reg 	[11:0] 	vcnt;

 
 //��ɨ�����
 always @(posedge clk or posedge rst_n)begin
 	if (rst_n) begin
		hcnt <= 12'b0;
		lcd_vsen <= 1'b0;
	end
	else if (hcnt == `H_TOTAL - 1'b1) begin
 		hcnt <= 12'b0;
 		lcd_vsen <= 1'b1;
 	end
 	else begin
 		hcnt <= hcnt + 1'b1;
 		lcd_vsen <= 1'b0;
 	end
	
 end
 
 //����lcd_hs
 always @(*)begin
 	if (hcnt < `H_SYNC)
 		lcd_hs = 1'b0;
 	else 
 		lcd_hs = 1'b1;
 	end
 
 //��ɨ�����
 always @(posedge clk or posedge rst_n) begin
 if (rst_n)
		vcnt <= 12'd0;
else 	 if (lcd_vsen == 1)begin
 		if (vcnt == `V_TOTAL - 1'b1)
 			vcnt <= 12'd0;
 		else 
 			vcnt <= vcnt + 1'b1;
 		end
 end
 
 //����lcd_vs�ź�
 always @(*)begin
 	if (vcnt < `V_SYNC)
 		lcd_vs = 1'b0;
 	else 
 		lcd_vs = 1'b1;
 	end
 
 always @(*)begin
 	if (hcnt > (`H_BACK + `H_SYNC) &&
	hcnt < (`H_BACK + `H_SYNC + `H_DISP) && 
	vcnt > (`V_BACK + `V_SYNC) &&
	vcnt < (`H_BACK + `V_SYNC + `V_DISP))
 		lcd_vidon = 1'b1;
 	else 
 		lcd_vidon = 1'b0;
 	end
			
 //LCD��ʾ״̬���С��м���
 assign lcd_x = lcd_vidon?(hcnt - (`H_BACK + `H_SYNC)):12'b0;
 assign lcd_y = lcd_vidon?(vcnt - (`V_BACK + `V_SYNC)):12'b0;
        	                                
endmodule

