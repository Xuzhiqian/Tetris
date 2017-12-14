`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:50:03 12/07/2017 
// Design Name: 
// Module Name:    slowclk 
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
module slowclk(input clk,
					output reg hclk
    );
always @(posedge clk)
	hclk=~hclk;

endmodule
