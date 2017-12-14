`include "vga_conf.v"
module data(input clk,
				input rst,
 					 input [11:0] lcd_x,
 					 input [11:0] lcd_y,
 					 output reg [7:0] lcd_data,
					 input u,
					 input d,
					 input l,
					 input r,
					 output reg [3:0] score4,
					 output reg [3:0] score3,
					 output reg [3:0] score2,
					 output reg [3:0] score1
            );
reg [26:0] cnt_max;
parameter width=10;
parameter height=20;  
parameter [width-1:0] full_row=10'b1111_1111_11;
reg [4:0] show_x;
reg [4:0] show_y;
reg [width-1:0] map[height+3:0];
reg [2:0] var;
reg [2:0] next_var;
reg [2:0] next_dir;
reg [2:0] dir;
reg [2:0] dir_new;
reg [4:0] x;
reg [4:0] y;
reg [4:0] x_new;
reg [4:0] y_new;



parameter S_idle=4'b1111;   //起始状态
parameter S_new=4'b0001;    //产生新方块
parameter S_hold=4'b0010;   //维持不动
parameter S_fall=4'b0011;   //准备下落
parameter S_movl=4'b0100;     //准备左移
parameter S_movr=4'b0101; 	 //右移
parameter S_rot=4'b0110; 	 //旋转
parameter S_shift=4'b0111;  //移动或旋转下落中的方块
parameter S_checkmap=4'b1000;
parameter S_fix=4'b1011;    //成为map一部分
parameter S_cut=4'b1101;    //消除行
parameter S_over=4'b1100;   //game over!


reg move_able;
reg ground_safe;
reg is_falling;
reg [2:0] shift_stat;
reg [32:0] counter=0;


reg [3:0] cur=S_idle;
reg [3:0] next;
reg [7:0] rand_num;

reg [5:0] i;
reg [5:0] row;
reg [5:0] j;

initial
begin
cnt_max=25000000;
score4=0;
score3=0;
score2=0;
score1=0;
  for (i=0;i<24;i=i+1) begin
	map[i]=0;
  end;
	rand_num=8'b10101101;
end

	
always @(posedge clk)
	if (rst)
		cur<=S_over;
	else
		cur<=next;
  
always @(posedge clk)
begin
  case (cur)
    S_idle:begin
             next_var=rand_num%7;
				 next_dir=0;
             next=S_new;
           end
    S_new:begin
				next=S_hold;
				begin
					var=next_var;
          next_var=rand_num%7;
					x=22;
					y=4;
					dir=next_dir;
					case (next_var)
						0:next_dir=0;
						1:next_dir=rand_num%2;
						2:next_dir=rand_num%2;
						3:next_dir=rand_num%2;
						4:next_dir=rand_num%4;
						5:next_dir=rand_num%4;
						6:next_dir=rand_num%4;
						default:next_dir=0;
					endcase
				end
			 end
			 
    S_hold:begin
             counter=counter+1;
             if (counter>=cnt_max) begin
               next=S_fall;
               counter=0;
             end
             else begin
									if (d==1) next=S_fall;
									else if (l==1) next=S_movl;
									else if (r==1) next=S_movr;
									else if (u==1) next=S_rot;
									else next=S_hold;
						end			
           end
    S_fall:begin
            if (x==0) next=S_fix;
				else begin
						y_new=y;
						x_new=x-1;
						dir_new=dir;
						is_falling=1;
						next=S_checkmap;
				   end
				end
	 S_movl:begin
				if (y==0) next=S_hold;
				else begin
						x_new=x;
						y_new=y-1;
						dir_new=dir;
						is_falling=0;
						next=S_checkmap;
				   end
				end
	 S_movr:begin
				if (y==width-1) next=S_hold;
				else begin
						x_new=x;
						y_new=y+1;
						dir_new=dir;
						is_falling=0;
						next=S_checkmap;
				   end
				end
    S_rot:begin
            x_new=x;
            y_new=y;
				is_falling=0;
            case (var)
              0:dir_new=dir;
              1:dir_new=(dir+1)%2;
              2:dir_new=(dir+1)%2;
              3:dir_new=(dir+1)%2;
              4:dir_new=(dir+1)%4;
              5:dir_new=(dir+1)%4;
              6:dir_new=(dir+1)%4;
              default:dir_new=dir;
            endcase
						next=S_checkmap;
			    end
    S_checkmap:begin
      					move_able=0;
                ground_safe=0;
                case (var)
                  0:ground_safe=(x_new>0 && y_new>0 && y_new<width)?1:0;
                  1:if (dir_new==0)
                      ground_safe=(x_new>=0 && y_new>1 && y_new<width-1)?1:0;
                    else
                      ground_safe=(x_new>1 && y_new>=0 && y_new<width)?1:0;
                  2:if (dir_new==0)
                      ground_safe=(x_new>0 && y_new>0 && y_new<width-1)?1:0;
                    else
                      ground_safe=(x_new>0 && y_new>=0 && y_new<width-1)?1:0;
                  3:if (dir_new==0)
                      ground_safe=(x_new>0 && y_new>0 && y_new<width-1)?1:0;
                    else
                      ground_safe=(x_new>0 && y_new>=0 && y_new<width-1)?1:0;
                  4:if (dir_new==0)
                      ground_safe=(x_new>0 && y_new>0 && y_new<width-1)?1:0;
                    else if (dir_new==1)
                      ground_safe=(x_new>0 && y_new>=0 && y_new<width-1)?1:0;
                    else if (dir_new==2)
                      ground_safe=(x_new>=0 && y_new>0 && y_new<width-1)?1:0;
                    else
                      ground_safe=(x_new>0 && y_new>0 && y_new<width)?1:0;
                  5:if (dir_new==0)
                      ground_safe=(x_new>0 && y_new>0 && y_new<width-1)?1:0;
                    else if (dir_new==1)
                      ground_safe=(x_new>0 && y_new>=0 && y_new<width-1)?1:0;
                    else if (dir_new==2)
                      ground_safe=(x_new>=0 && y_new>0 && y_new<width-1)?1:0;
                    else
                      ground_safe=(x_new>0 && y_new>0 && y_new<width)?1:0;
                  6:if (dir_new==0)
                      ground_safe=(x_new>0 && y_new>0 && y_new<width-1)?1:0;
                    else if (dir_new==1)
                      ground_safe=(x_new>0 && y_new>=0 && y_new<width-1)?1:0;
                    else if (dir_new==2)
                      ground_safe=(x_new>=0 && y_new>0 && y_new<width-1)?1:0;
                    else
                      ground_safe=(x_new>0 && y_new>0 && y_new<width)?1:0;
                endcase
                if (ground_safe==0) begin
							if (is_falling)
								next=S_fix;
							else
								next=S_hold;
							end
                else begin
                  
      						case (var)
      							0:if (!map[x_new][y_new] && !map[x_new][y_new-1] && !map[x_new-1][y_new] && !map[x_new-1][y_new-1])
      								move_able=1;
      							1:if (dir_new==0) begin
      									if (!map[x_new][y_new] && !map[x_new][y_new-1] && !map[x_new][y_new-2] && !map[x_new][y_new+1])
      											move_able=1;
      								end
      								else if (!map[x_new+1][y_new] && !map[x_new][y_new] && !map[x_new-1][y_new] && !map[x_new-2][y_new])
      										move_able=1;
      							2:if (dir_new==0) begin
      									if (!map[x_new][y_new] && !map[x_new-1][y_new] && !map[x_new-1][y_new-1] && !map[x_new][y_new+1])
      										move_able=1;
      								end
      								else if (!map[x_new][y_new] && !map[x_new+1][y_new] && !map[x_new][y_new+1] && !map[x_new-1][y_new+1])
      										move_able=1;
              
      							3:if (dir_new==0) begin
      									if (!map[x_new][y_new] && !map[x_new-1][y_new] && !map[x_new][y_new-1] && !map[x_new-1][y_new+1])
      										move_able=1;
      								end
      								else if (!map[x_new][y_new] && !map[x_new-1][y_new] && !map[x_new][y_new+1] && !map[x_new+1][y_new+1])
      										move_able=1;
              
      							4:if (dir_new==0) begin
      									if (!map[x_new][y_new] && !map[x_new][y_new-1] && !map[x_new-1][y_new-1] && !map[x_new][y_new+1])
      										move_able=1;
      								end
      								else if (dir_new==1) begin
      									if (!map[x_new][y_new] && !map[x_new-1][y_new] && !map[x_new+1][y_new] && !map[x_new-1][y_new+1])
      										move_able=1;
      								end
      								else if (dir_new==2) begin
      									if (!map[x_new][y_new] && !map[x_new][y_new-1] && !map[x_new+1][y_new+1] && !map[x_new][y_new+1])
      										move_able=1;
      								end
      								else if (dir_new==3) begin
      									if (!map[x_new][y_new] && !map[x_new+1][y_new] && !map[x_new-1][y_new] && !map[x_new+1][y_new-1])
      										move_able=1;
      								end
      							5:if (dir_new==0) begin
      									if (!map[x_new][y_new] && !map[x_new][y_new-1] && !map[x_new-1][y_new+1] && !map[x_new][y_new+1])
      										move_able=1;
      								end
      								else if (dir_new==1) begin
      									if (!map[x_new][y_new] && !map[x_new-1][y_new] && !map[x_new+1][y_new] && !map[x_new+1][y_new+1])
      										move_able=1;
      								end
      								else if (dir_new==2) begin
      									if (!map[x_new][y_new] && !map[x_new][y_new-1] && !map[x_new+1][y_new-1] && !map[x_new][y_new+1])
      										move_able=1;
      								end
      								else if (dir_new==3) begin
      									if (!map[x_new][y_new] && !map[x_new+1][y_new] && !map[x_new-1][y_new] && !map[x_new-1][y_new-1])
      										move_able=1;
      								end
      							6:if (dir_new==0) begin
      									if (!map[x_new][y_new] && !map[x_new][y_new-1] && !map[x_new][y_new+1] && !map[x_new-1][y_new])
      										move_able=1;
      								end
      								else if (dir_new==1) begin
      									if (!map[x_new][y_new] && !map[x_new+1][y_new] && !map[x_new-1][y_new] && !map[x_new][y_new+1])
      										move_able=1;
      								end
      								else if (dir_new==2) begin
      									if (!map[x_new][y_new] && !map[x_new][y_new-1] && !map[x_new][y_new+1] && !map[x_new+1][y_new])
      										move_able=1;
      								end
      								else if (dir_new==3) begin
      									if (!map[x_new][y_new] && !map[x_new][y_new-1] && !map[x_new-1][y_new] && !map[x_new+1][y_new])
      										move_able=1;
      								end
      							default:move_able=0;
      					endcase
                if (move_able)
                  next=S_shift;
                else begin
						if (is_falling)
							next=S_fix;
						else
							next=S_hold;
						end
                end
                end
    
    
    S_shift:begin
					next=S_hold;
          x=x_new;
          y=y_new;
          dir=dir_new;
				end
				
    S_fix:begin
			case (var)
    0:begin
        map[x][y]=1; map[x-1][y]=1; map[x][y-1]=1; map[x-1][y-1]=1;
      end
    1:if (dir==0) begin
        map[x][y]=1; map[x][y-1]=1; map[x][y-2]=1; map[x][y+1]=1;
        end
      else if (dir==1) begin
              map[x][y]=1; map[x+1][y]=1; map[x-1][y]=1; map[x-2][y]=1;
              end
    2:if (dir==0) begin
        map[x][y]=1; map[x-1][y-1]=1; map[x-1][y]=1; map[x][y+1]=1;
        end
      else if (dir==1) begin
              map[x][y]=1; map[x+1][y]=1; map[x][y+1]=1; map[x-1][y+1]=1;
              end
    3:if (dir==0) begin
        map[x][y]=1; map[x][y-1]=1; map[x-1][y]=1; map[x-1][y+1]=1;
        end
      else if (dir==1) begin
              map[x][y]=1; map[x-1][y]=1; map[x][y+1]=1; map[x+1][y+1]=1;
              end
    4:if (dir==0) begin
            map[x][y]=1; map[x][y-1]=1; map[x-1][y-1]=1; map[x][y+1]=1;
            end
      else if (dir==1) begin
            map[x][y]=1; map[x-1][y]=1; map[x+1][y]=1; map[x-1][y+1]=1;
            end
      else if (dir==2) begin
            map[x][y]=1; map[x][y-1]=1; map[x+1][y+1]=1; map[x][y+1]=1;
            end
      else if (dir==3) begin
            map[x][y]=1; map[x+1][y]=1; map[x-1][y]=1; map[x+1][y-1]=1;
            end
    5:if (dir==0) begin
            map[x][y]=1; map[x][y-1]=1; map[x-1][y+1]=1; map[x][y+1]=1;
            end
      else if (dir==1) begin
            map[x][y]=1; map[x-1][y]=1; map[x+1][y]=1; map[x+1][y+1]=1;
            end
      else if (dir==2) begin
            map[x][y]=1; map[x][y-1]=1; map[x+1][y-1]=1; map[x][y+1]=1;
            end
      else if (dir==3) begin
            map[x][y]=1; map[x+1][y]=1; map[x-1][y]=1; map[x-1][y-1]=1;
            end
    6:if (dir==0) begin
            map[x][y]=1; map[x][y-1]=1; map[x][y+1]=1; map[x-1][y]=1;
            end
      else if (dir==1) begin
            map[x][y]=1; map[x+1][y]=1; map[x-1][y]=1; map[x][y+1]=1;
            end
      else if (dir==2) begin
            map[x][y]=1; map[x][y-1]=1; map[x][y+1]=1; map[x+1][y]=1;
            end
      else if (dir==3) begin
            map[x][y]=1; map[x][y-1]=1; map[x-1][y]=1; map[x+1][y]=1;
            end
	endcase
	
	row=0;
	j=0;
	
	next=S_cut;
	end
	 S_cut:begin
				if (map[row]!=full_row) begin
					map[j]=map[row];
					j=j+1;
				end else begin
							if (score1==5) begin
								score1=0;
								if (score2==9) begin
									score2=0;
									if (score3==9) begin
										score3=0;
										if (score4==9)
											score4=0;
										else
											score4=score4+1;
									end
									else score3=score3+1;
								end
								else score2=score2+1;
							end
							else score1=5;
	
							if (cnt_max>5000000)
								cnt_max<=cnt_max-500000;
						end
				if (row==height+3) begin
					if (map[height-1][3]==1 || map[height-1][4]==1 || map[height-1][5]==1 || map[height][4]==1 || map[height+1][4]==1)
						next=S_over;
					else
						next=S_new;
				end
				else begin
						 row=row+1;
						 next=S_cut;
					  end
		end
    S_over:begin
					score4=0;
					score3=0;
					score2=0;
					score1=0;
					for (i=0;i<24;i=i+1) map[i]=0;
					cnt_max<=25000000;
					next=S_idle;
				end
    default:next=S_idle;
  endcase
end

always @(posedge clk)       //random number
begin
  rand_num[0] <= rand_num[7];
  rand_num[1] <= rand_num[0];
  rand_num[2] <= rand_num[1];
  rand_num[3] <= rand_num[2];
  rand_num[4] <= rand_num[3]^rand_num[7];
  rand_num[5] <= rand_num[4]^rand_num[7];
  rand_num[6] <= rand_num[5]^rand_num[7];
  rand_num[7] <= rand_num[6];
end

//border
// x=40~440
// y=200~400

parameter a=20;
reg [5:0] lx;
reg [5:0] ly;

	
always @(posedge clk)
begin
    if (0<lcd_x-40 && lcd_x-40<=a)
        lx<=19;
    else if (a<lcd_x-40 && lcd_x-40<=2*a)
        lx<=18;
    else if (2*a<lcd_x-40 && lcd_x-40<=3*a)
        lx<=17;
    else if (3*a<lcd_x-40 && lcd_x-40<=4*a)
        lx<=16;
    else if (4*a<lcd_x-40 && lcd_x-40<=5*a)
        lx<=15;
    else if (5*a<lcd_x-40 && lcd_x-40<=6*a)
        lx<=14;
    else if (6*a<lcd_x-40 && lcd_x-40<=7*a)
        lx<=13;
    else if (7*a<lcd_x-40 && lcd_x-40<=8*a)
        lx<=12;
    else if (8*a<lcd_x-40 && lcd_x-40<=9*a)
        lx<=11;
    else if (9*a<lcd_x-40 && lcd_x-40<=10*a)
        lx<=10;
    else if (10*a<lcd_x-40 && lcd_x-40<=11*a)
        lx<=9;
    else if (11*a<lcd_x-40 && lcd_x-40<=12*a)
        lx<=8;
    else if (12*a<lcd_x-40 && lcd_x-40<=13*a)
        lx<=7;
    else if (13*a<lcd_x-40 && lcd_x-40<=14*a)
        lx<=6;
    else if (14*a<lcd_x-40 && lcd_x-40<=15*a)
        lx<=5;
    else if (15*a<lcd_x-40 && lcd_x-40<=16*a)
        lx<=4;
    else if (16*a<lcd_x-40 && lcd_x-40<=17*a)
        lx<=3;
    else if (17*a<lcd_x-40 && lcd_x-40<=18*a)
        lx<=2;
    else if (18*a<lcd_x-40 && lcd_x-40<=19*a)
        lx<=1;
    else if (19*a<lcd_x-40 && lcd_x-40<=20*a)
        lx<=0;
    else
        lx<=23;

    if (60<lcd_x && lcd_x<=70)
        show_x<=4;
    else if (70<lcd_x && lcd_x<=80)
        show_x<=3;
    else if (80<lcd_x && lcd_x<=90)
        show_x<=2;
    else if (90<lcd_x && lcd_x<=100)
        show_x<=1;
    else
        show_x<=0;
        
    if (0<lcd_y-200 && lcd_y-200<=a)
        ly<=0;
    else if (a<lcd_y-200 && lcd_y-200<=2*a)
        ly<=1;
    else if (2*a<lcd_y-200 && lcd_y-200<=3*a)
        ly<=2;
    else if (3*a<lcd_y-200 && lcd_y-200<=4*a)
        ly<=3;
    else if (4*a<lcd_y-200 && lcd_y-200<=5*a)
        ly<=4;
    else if (5*a<lcd_y-200 && lcd_y-200<=6*a)
        ly<=5;
    else if (6*a<lcd_y-200 && lcd_y-200<=7*a)
        ly<=6;
    else if (7*a<lcd_y-200 && lcd_y-200<=8*a)
        ly<=7;
    else if (8*a<lcd_y-200 && lcd_y-200<=9*a)
        ly<=8;
    else if (9*a<lcd_y-200 && lcd_y-200<=10*a)
        ly<=9;
    else
        ly<=19;
    
    if (460<lcd_y && lcd_y<=470)
        show_y<=1;
    else if (470<lcd_y && lcd_y<=480)
        show_y<=2;
    else if (480<lcd_y && lcd_y<=490)
        show_y<=3;
    else if (490<lcd_y && lcd_y<=500)
        show_y<=4;  
    else
        show_y<=0;
end


reg [2:0] var_v;
reg [2:0] dir_v;
reg [4:0] x_v;
reg [4:0] y_v;
reg [4:0] lx_v;
reg [4:0] ly_v;
always @(posedge clk)
begin
lcd_data<=`BLACK;
if ((lcd_x>40 && lcd_x<120 && ((lcd_y>440 && lcd_y<450)||(lcd_y>510 && lcd_y<520))) ||
    (lcd_y>440 && lcd_y<520 && ((lcd_x>40 && lcd_x<50)||(lcd_x>110 && lcd_x<120))))
      lcd_data<=`GREEN;
else
if ((lcd_x>=20 && lcd_x<=460 && ((lcd_y>=180 && lcd_y<=201)||(lcd_y>=400 && lcd_y<=420))) ||
    (lcd_y>=180 && lcd_y<=420 && ((lcd_x>=20 && lcd_x<=40)||(lcd_x>=440 && lcd_x<=460))))
      lcd_data<=`ROYAL;
else
if (lcd_x>40 && lcd_x<440 && lcd_y>200 && lcd_y<400 && map[lx][ly])
    lcd_data<=`WHITE;
else if (lx<20) begin
var_v=var;
dir_v=dir;
x_v=x;
y_v=y;
lx_v=lx;
ly_v=ly;

if (show_x>0 && show_y>0) begin
    var_v=next_var;
	 dir_v=next_dir;
    x_v=3;
    y_v=3;
    lx_v=show_x;
    ly_v=show_y;
end


  case (var_v)
   0:if (dir_v==0) begin
    if (x_v==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v-1==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v==lx_v && y_v-1==ly_v)
   lcd_data<=`WHITE;
  else if (x_v-1==lx_v && y_v-1==ly_v)
   lcd_data<=`WHITE;
  else lcd_data<=8'b0;
  end
    1:if (dir_v==0) begin
    if (x_v==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v==lx_v && y_v-1==ly_v)
   lcd_data<=`WHITE;
  else if (x_v==lx_v && y_v-2==ly_v)
   lcd_data<=`WHITE;
  else if (x_v==lx_v && y_v+1==ly_v)
   lcd_data<=`WHITE;
  else  lcd_data<=8'b0;
  end
   else if (dir_v==1) begin
    if (x_v==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v-1==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v-2==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v+1==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else  lcd_data<=8'b0;
  end
    2:if (dir_v==0) begin
    if (x_v==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v-1==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v-1==lx_v && y_v-1==ly_v)
   lcd_data<=`WHITE;
  else if (x_v==lx_v && y_v+1==ly_v)
   lcd_data<=`WHITE;
  else  lcd_data<=8'b0;
  end
   else if (dir_v==1) begin
    if (x_v==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v+1==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v==lx_v && y_v+1==ly_v)
   lcd_data<=`WHITE;
  else if (x_v-1==lx_v && y_v+1==ly_v)
   lcd_data<=`WHITE;
  else  lcd_data<=8'b0;
  end
    3:if (dir_v==0) begin
    if (x_v==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v-1==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v==lx_v && y_v-1==ly_v)
   lcd_data<=`WHITE;
  else if (x_v-1==lx_v && y_v+1==ly_v)
   lcd_data<=`WHITE;
  else  lcd_data<=8'b0;
  end
   else if (dir_v==1) begin
    if (x_v==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v-1==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v+1==lx_v && y_v+1==ly_v)
   lcd_data<=`WHITE;
  else if (x_v==lx_v && y_v+1==ly_v)
   lcd_data<=`WHITE;
  else  lcd_data<=8'b0;
  end
    4:if (dir_v==0) begin
    if (x_v==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v==lx_v && y_v-1==ly_v)
   lcd_data<=`WHITE;
  else if (x_v-1==lx_v && y_v-1==ly_v)
   lcd_data<=`WHITE;
  else if (x_v==lx_v && y_v+1==ly_v)
   lcd_data<=`WHITE;
  else  lcd_data<=8'b0;
  end
   else if (dir_v==1) begin
    if (x_v==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v+1==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v-1==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v-1==lx_v && y_v+1==ly_v)
   lcd_data<=`WHITE;
  else  lcd_data<=8'b0;
  end
   else if (dir_v==2) begin
    if (x_v==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v==lx_v && y_v-1==ly_v)
   lcd_data<=`WHITE;
  else if (x_v+1==lx_v && y_v+1==ly_v)
   lcd_data<=`WHITE;
  else if (x_v==lx_v && y_v+1==ly_v)
   lcd_data<=`WHITE;
  else  lcd_data<=8'b0;
  end
   else if (dir_v==3) begin
    if (x_v==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v+1==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v+1==lx_v && y_v-1==ly_v)
   lcd_data<=`WHITE;
  else if (x_v-1==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else  lcd_data<=8'b0;
  end
    5:if (dir_v==0) begin
    if (x_v==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v==lx_v && y_v-1==ly_v)
   lcd_data<=`WHITE;
  else if (x_v-1==lx_v && y_v+1==ly_v)
   lcd_data<=`WHITE;
  else if (x_v==lx_v && y_v+1==ly_v)
   lcd_data<=`WHITE;
  else  lcd_data<=8'b0;
  end
   else if (dir_v==1) begin
    if (x_v==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v+1==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v-1==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v+1==lx_v && y_v+1==ly_v)
   lcd_data<=`WHITE;
  else  lcd_data<=8'b0;
  end
   else if (dir_v==2) begin
    if (x_v==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v==lx_v && y_v-1==ly_v)
   lcd_data<=`WHITE;
  else if (x_v+1==lx_v && y_v-1==ly_v)
   lcd_data<=`WHITE;
  else if (x_v==lx_v && y_v+1==ly_v)
   lcd_data<=`WHITE;
  else  lcd_data<=8'b0;
  end
   else if (dir_v==3) begin
    if (x_v==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v+1==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v-1==lx_v && y_v-1==ly_v)
   lcd_data<=`WHITE;
  else if (x_v-1==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else  lcd_data<=8'b0;
  end
    6:if (dir_v==0) begin
    if (x_v==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v==lx_v && y_v-1==ly_v)
   lcd_data<=`WHITE;
  else if (x_v-1==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v==lx_v && y_v+1==ly_v)
   lcd_data<=`WHITE;
  else  lcd_data<=8'b0;
  end
   else if (dir_v==1) begin
    if (x_v==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v+1==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v-1==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v==lx_v && y_v+1==ly_v)
   lcd_data<=`WHITE;
  else  lcd_data<=8'b0;
  end
   else if (dir_v==2) begin
    if (x_v==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v==lx_v && y_v-1==ly_v)
   lcd_data<=`WHITE;
  else if (x_v+1==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v==lx_v && y_v+1==ly_v)
   lcd_data<=`WHITE;
  else  lcd_data<=8'b0;
  end
   else if (dir_v==3) begin
    if (x_v==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v==lx_v && y_v-1==ly_v)
   lcd_data<=`WHITE;
  else if (x_v+1==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else if (x_v-1==lx_v && y_v==ly_v)
   lcd_data<=`WHITE;
  else  lcd_data<=8'b0;
  end
  endcase

end

end
endmodule
