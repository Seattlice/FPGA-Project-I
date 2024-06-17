`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/14 19:36:56
// Design Name: 
// Module Name: mode
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mode
(
    input wire          sys_clk     ,
    input wire          sys_rst_n   ,
    input wire  [5:0]   wave_sel,
    input wire  [3:0]   mode_sel,    
    input wire  [10:0]  T,//脉冲时间
    input wire  [6:0]   Z,//占空比1 = 1：1   5=1：5   1为信号，N为空白
    input wire  [8:0]   F,
    input wire          judge,

    output reg          T_cnt        ,//该计数器用来计数是否在脉冲上
    output wire         T_cnt_dp       ,//用来计数第几个脉冲
    output reg  [31:0]  F_WORD        ,//频率控制字
    output reg  [31:0]  FW1          ,//存放要加入的结果
    output wire  [22:0] rom_addr_bpsk,
    output wire  [22:0] rom_addr_qpsk  
    );
reg  [3:0]   T_cnt1;
reg [18:0]  TIME;        //计数器用来计数的时间
reg [25:0]  cnt;         //计数器
wire [31:0]  F_in;       //存放要计算的结果
reg [25:0] TIME_1;      //储存占空比的波形长度

assign  F_in = F_WORD;
always @(posedge sys_clk or negedge sys_rst_n) //频率控制字的计算
    if(!sys_rst_n)
        F_WORD <= 32'd0;
    else if (judge)
        if(wave_sel != 6'b000100)
            F_WORD <= 32'd8589934 * F;//22.16.15.13.8.5.4.2.1//50MHZ---32'd8589934-----100MHZ:4294967----1GHZ:429497
        else 
            F_WORD <= 32'd858993 * F / T ;//22.16.15.13.8.5.4.2.1//50MHZ---32'd858993----100MHZ:429497----1GHZ:42949
    else
        F_WORD <= F_WORD; 
 
always @(posedge sys_clk or negedge sys_rst_n) //计数器用来计数的时间
    if(!sys_rst_n)
        TIME <= 19'd0;
    else if(judge)
        TIME <=  ((T << 6)+ ( T << 5 ) +( T << 2));//100*T
    else
        TIME <= TIME;

always @(posedge sys_clk or negedge sys_rst_n) //计数器用来计数的时间
    if(!sys_rst_n)
        TIME_1 <=26'd0;
    else if(wave_sel == 6'b000100)//LFM需要进行改变
        if(mode_sel == 4'd1)
            TIME_1 <= TIME - 2'd2;
        else
            TIME_1 <= (TIME* Z)  - 2'd2;    
    else 
        TIME_1 <= (TIME* Z) -1'd1;

always @(posedge sys_clk or negedge sys_rst_n) //计数器
    if(!sys_rst_n)
        cnt <= 25'd0;
    else if(judge)
        cnt <= 25'd0;        
    else if( cnt == TIME_1 )
        cnt <= 25'd0;
    else if(wave_sel == 6'b000100)
        cnt <= cnt + 2'd2;
    else
        cnt <= cnt + 2'd1;        

always @(posedge sys_clk or negedge sys_rst_n) //该计数器用来计数是否在脉冲上
    if(!sys_rst_n)
        T_cnt <= 1'd0;
    else if(judge)
        T_cnt <= 4'd0;        
    else if(( cnt == TIME -1'd1 )&&(wave_sel != 6'b000100))//对于波形的控制，防止其过多或者过少，引发一两个时间单位的杂波
        T_cnt <= 1'd1;
    else if(( cnt == TIME -2'd2 )&&(wave_sel == 6'b000100))
        if(mode_sel == 4'd1)
            T_cnt <= ~T_cnt;            
        else
            T_cnt <= 1'd1;
    else if( cnt == TIME_1)
        T_cnt <= 1'd0;    
    else 
        T_cnt <= T_cnt;  

always @(posedge sys_clk or negedge sys_rst_n) //连续波为0、脉冲波为两次、步进频率波为4次，跳变为4次
    if(!sys_rst_n)
        T_cnt1 <= 4'd0;
    else if(judge)
        T_cnt1 <= 4'd0;           
    else if(mode_sel == 4'b0001)//连续波计数
        T_cnt1 <= 4'd0;
    else if(mode_sel == 4'b0010)//普通脉冲计数
        if(cnt == TIME )
            T_cnt1 <=  4'd1;
        else if( cnt == TIME_1)
            T_cnt1 <=  4'd0;
        else
            T_cnt1 <= T_cnt1;
    else if(mode_sel == 4'b0100)      //步进脉冲计数  
         if((T_cnt1 == 4'd7) &&((cnt == TIME_1)))
            T_cnt1 <= 4'd0;  
        else if((cnt == TIME )||(cnt == TIME_1))
            T_cnt1 <= T_cnt1 + 1'd1;
        else
            T_cnt1 <= T_cnt1;               
    else if(mode_sel == 4'b1000)//跳变脉冲波计数
         if((T_cnt1 == 4'd7) && ( (cnt == TIME_1)))
            T_cnt1 <= 4'd0;  
        else if((cnt == TIME )||(cnt == TIME_1))
            T_cnt1 <= T_cnt1 + 1'd1;
        else
            T_cnt1 <= T_cnt1;
    else
        T_cnt1 <= T_cnt1;


always @(posedge sys_clk or negedge sys_rst_n) //用来对脉冲进行频率字的改变，脉冲模式的确定，此处步进为1.2.3.4倍，跳变为1.3.2.4倍
    if(!sys_rst_n)
        FW1 <= 32'd0;
    else if(mode_sel == 4'b0001)
        FW1 <= F_in;
    else if(mode_sel == 4'b0010)
        FW1 <= F_in;
    else if(mode_sel == 4'b0100)        
        case(T_cnt1)
            4'b0:FW1 <= F_in;
            4'd2:FW1 <= F_in<<1;//步进频率变为原来的n倍
            4'd4:FW1 <=(F_in*3);
            4'd6:FW1 <= F_in<<2;
        default:FW1 <=32'd0;
        endcase
    else if(mode_sel == 4'b1000)
        case(T_cnt1)
            4'b0:FW1 <= F_in;
            4'd2:FW1 <= F_in*3;
            4'd4:FW1 <= F_in<<1;
            4'd6:FW1 <= F_in<<2;
        default:FW1 <=32'd0;
        endcase
        
reg  [8:0]  F0;//输入m_data的频率
reg         FW_flag;      
reg  [8:0]  F1;

always @(posedge sys_clk or negedge sys_rst_n) //用来对输入相位调制信号的改变
    if(!sys_rst_n)  
        F1 <= 9'd0;
    else
        F1 <= F0;
    
always @(posedge sys_clk or negedge sys_rst_n) //用来对输入相位调制信号的改变
    if(!sys_rst_n)        
        F0 <= 9'd0;
    else if((wave_sel != 6'b001000)&&(wave_sel != 6'b010000))
        F0 <= 9'd0;    
    else if((mode_sel == 4'b0001)||(mode_sel == 4'b0010))
        F0 <= F;
    else if(mode_sel == 4'b0100)
        case(T_cnt1)
            4'b0:F0 <= F;
            4'd2:F0 <= F*3;
            4'd4:F0 <= F<<1;
            4'd6:F0 <= F<<2;        
        default:F0 <= F;
        endcase
    else if(mode_sel == 4'b1000)
        case(T_cnt1)
            4'b0:F0 <= F;
            4'd2:F0 <= F*3;
            4'd4:F0 <= F<<1;
            4'd6:F0 <= F<<2;        
        default:F0 <= F;
        endcase    
    else
        F0 <= 9'd0;

always @(posedge sys_clk or negedge sys_rst_n) //用来对输入相位调制信号的改变
    if(!sys_rst_n)        
        FW_flag <= 1'd0;
    else if(F1 != F0)
        FW_flag <= 1'd1;
    else
        FW_flag <=1'd0;
         
m_data m_data_inst
(
  .clk      (sys_clk),          // 时钟信号
  .rst_n    (sys_rst_n),        // 复位信号
  .F0       (F0),
  .FW_flag  (FW_flag),
  .mode_sel (mode_sel),
  .wave_sel (wave_sel),
  .T_cnt    (T_cnt),
  .judge    (judge),
  
  .rom_addr_bpsk (rom_addr_bpsk),
  .rom_addr_qpsk (rom_addr_qpsk)
);

//进行打拍，用来进行防止脉冲的不同步
//因为进行载波计算时有计算步骤的时间,加入流水线之前位为5个累加器
//进行打拍，用来进行防止脉冲的不同步
//因为进行载波计算时有计算步骤的时间
reg T_cnt_1;
reg T_cnt_2;
reg T_cnt_3;
reg T_cnt_4;
reg T_cnt_5;
reg T_cnt_6;
reg T_cnt_7;
reg T_cnt_8;
reg T_cnt_9;
reg T_cnt_10;
//reg T_cnt_11;
//reg T_cnt_12;
//reg T_cnt_13;
//reg T_cnt_14;
//reg T_cnt_15;

always @(posedge sys_clk or negedge sys_rst_n) 
    if(!sys_rst_n)
        begin
            T_cnt_1 <= 1'd0;
            T_cnt_2 <= 1'd0;
            T_cnt_3 <= 1'd0;
            T_cnt_4 <= 1'd0;
            T_cnt_5 <= 1'd0;
            T_cnt_6 <= 1'd0;
            T_cnt_7 <= 1'd0;
    //        T_cnt_8 <= 1'd0;
     //       T_cnt_9 <= 1'd0;
    //        T_cnt_10 <= 1'd0;
//            T_cnt_11 <= 1'd0;     
        end
    else
        begin
            T_cnt_1 <= T_cnt;
            T_cnt_2 <= T_cnt_1;
            T_cnt_3 <= T_cnt_2;
            T_cnt_4 <= T_cnt_3;
            T_cnt_5 <= T_cnt_4;
            T_cnt_6 <= T_cnt_5;   
            T_cnt_7 <= T_cnt_6;
  //          T_cnt_8 <= T_cnt_7;
   //         T_cnt_9 <= T_cnt_8;
 //           T_cnt_10 <= T_cnt_9;
//            T_cnt_11 <= T_cnt_10;                                
        end
        
assign T_cnt_dp = T_cnt_5;//为五个延迟，打了五拍传出


endmodule
