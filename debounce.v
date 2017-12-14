`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:19:32 12/04/2017 
// Design Name: 
// Module Name:    debounce 
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
module debounce(
        input clk,
        input u,d,l,r,
        output reg uout,dout,lout,rout);
reg [15:0] cu=0; parameter mu=50000;
reg [15:0] cl=0; parameter ml=50000;
reg [15:0] cr=0; parameter mr=50000;
reg [15:0] cd=0; parameter md=50000;

always @(posedge clk)
begin
  if (u==1) begin
    if (cu==mu) uout=0;
    else if (cu<mu) begin
            cu=cu+1;
            if (cu==mu) uout=1;
          end;
  end
  else cu=0;  
	if (r==1) begin
    if (cr==mr) rout=0;
    else if (cr<mr) begin
            cr=cr+1;
            if (cr==mr) rout=1;
          end;
  end
  else cr=0;
  if (l==1) begin
    if (cl==ml) lout=0;
    else if (cl<ml) begin
            cl=cl+1;
            if (cl==ml) lout=1;
          end;
  end
  else cl=0; 
  if (d==1) begin
    if (cd==md) dout=0;
    else if (cd<md) begin
            cd=cd+1;
            if (cd==md) dout=1;
          end;
  end
  else cd=0;
end
endmodule
