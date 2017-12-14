

module segshow(clk, sel, seg,s4,s3,s2,s1);  
input clk;  
input [3:0] s4;
input [3:0] s3;
input [3:0] s2;
input [3:0] s1;
output reg [3:0] sel;  
output reg [6:0] seg;   //a~g,dp  
  
//扫描频率:50Hz  
parameter update_interval = 10000;  
  
reg [7:0] dat;  
  
reg [1:0] cursel;  
integer selcnt;  
  
//扫描计数，选择位  
always @(posedge clk)  
begin  
    selcnt <= selcnt + 1;  
          
    if (selcnt == update_interval)  
    begin  
        selcnt <= 0;  
        cursel <= cursel + 1;  
    end  
end  
  
//切换扫描位选线和数据  
always @(*)  
begin  
    sel = 4'b0000;  
    case (cursel)  
        2'b00: begin dat = s4; sel = 4'b0111; end  
        2'b01: begin dat = s3; sel = 4'b1011; end  
        2'b10: begin dat = s2; sel = 4'b1101; end  
        2'b11: begin dat = s1; sel = 4'b1110; end  
    endcase  
end  
  
//更新段码  
always @(*)  
begin  
    case (dat[6:0])  
        7'h00   : seg[6:0] <= 7'b0000001;    //0  
        7'h01   : seg[6:0] <= 7'b1001111;    //1  
        7'h02   : seg[6:0] <= 7'b0010010;    //2  
        7'h03   : seg[6:0] <= 7'b0000110;    //3  
        7'h04   : seg[6:0] <= 7'b1001100;    //4  
        7'h05   : seg[6:0] <= 7'b0100100;    //5  
        7'h06   : seg[6:0] <= 7'b0100000;    //6  
        7'h07   : seg[6:0] <= 7'b0001111;    //7  
        7'h08   : seg[6:0] <= 7'b0000000;    //8  
        7'h09   : seg[6:0] <= 7'b0000100;    //9  
        default : seg[6:0] <= 7'b0110000;    //E-rror  
    endcase  
end  
      
endmodule 