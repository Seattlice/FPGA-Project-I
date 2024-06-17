`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/12 10:18:32
// Design Name: 
// Module Name: judge
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



//此模块为判断外界参数是否进行了改变，若是进行了改变，就对所有的内容进行清空，使之利用新的参数重新加载
module judge (
    input wire      sys_clk     ,
    input wire      sys_rst_n   ,
    input wire  [5:0]   wave_sel,
    input wire  [3:0]   mode_sel,    
    input wire  [8:0]   F,// 1 对应0.1MHZ
    input wire  [10:0]  T,//脉冲时间
    input wire  [6:0]   Z,//占空比，为0-100，意味脉冲信号占总信号的1/Z  
    input wire  T_cnt,

//    output reg wave_flag,
//    output reg f_flag,    
    output reg T_cnt_flag,
//    output reg T_flag,
//    output reg Z_flag,
//    output reg mode_flag,
    output wire judge
);
    
    reg T_flag;//根据需要选择使用即可
    reg Z_flag;
    reg mode_flag;
    reg wave_flag;
    reg f_flag;  
    
    
    
reg  [5:0]   wave_sel1;//判断wave_sel是否发生了变化

always @(posedge sys_clk or negedge sys_rst_n) //位选信号
    if(!sys_rst_n)
        wave_sel1 <= 6'd0;
    else 
        wave_sel1 <= wave_sel;

always @(posedge sys_clk or negedge sys_rst_n) //用来判断位选信号是否变化
    if(!sys_rst_n)
        wave_flag <= 1'd0;
    else if(wave_sel1 != wave_sel)
        wave_flag <= 1'd1;
    else
        wave_flag <= 1'd0;

reg [8:0] F0;          //判断F是否发生了变化

always @(posedge sys_clk or negedge sys_rst_n) //频率
    if(!sys_rst_n)
        F0  <= 9'd0;
    else
        F0  <=  F;

always @(posedge sys_clk or negedge sys_rst_n) //用来判断F是否改变 
    if(!sys_rst_n)
        f_flag <= 1'd0;
    else if (F0 != F)
        f_flag <= 1'd1;
    else
        f_flag <= 1'd0;

reg T_cnt_f;//判断控制翻转变量是否发生了变化

always @(posedge sys_clk or negedge sys_rst_n) 
    if(!sys_rst_n)
        T_cnt_f <= 1'b0;
    else
        T_cnt_f <= T_cnt;


always @(posedge sys_clk or negedge sys_rst_n) 
    if(!sys_rst_n)
        T_cnt_flag <= 1'b0;
    else if(T_cnt_f != T_cnt)
        T_cnt_flag <= 1'b1;
    else
        T_cnt_flag <= 1'b0;

reg [6:0]      Z1;     

always @(posedge sys_clk or negedge sys_rst_n) //用来检测判断占空比是否发生变化
    if(!sys_rst_n)
        Z1 <= 7'd0;
    else
        Z1 <= Z;

always @(posedge sys_clk or negedge sys_rst_n) //用来判断占空比是否发生变化
    if(!sys_rst_n)
        Z_flag <= 1'd0;
    else if (Z1 != Z)
        Z_flag <= 1'd1;
    else 
        Z_flag <= 1'd0;

reg [3:0]   mode_sel1;    //用来检测模式选择信号是否发生变化

always @(posedge sys_clk or negedge sys_rst_n) //用来检测模式选择信号是否发生变化
    if(!sys_rst_n)
        mode_sel1 <= 4'd0;
    else
        mode_sel1 <= mode_sel;

always @(posedge sys_clk or negedge sys_rst_n) //用来检测模式选择信号是否发生变化
    if(!sys_rst_n)
        mode_flag <= 1'd0;
    else if (mode_sel != mode_sel1)
        mode_flag <= 1'd1;
    else 
        mode_flag <= 1'd0;

reg [10:0]  T_1;
always @(posedge sys_clk or negedge sys_rst_n)  //判断脉冲时间是否发生改变
    if(!sys_rst_n)
        T_1<= 11'd0;
    else 
        T_1 <= T;
   
always @(posedge sys_clk or negedge sys_rst_n)  //判断脉冲时间是否发生改变
    if(!sys_rst_n)
        T_flag<= 1'd0;
    else if(T_1 != T) 
        T_flag <= 1'd1;
    else
        T_flag <= 1'd0;     

assign judge = T_flag | mode_flag | Z_flag | f_flag | wave_flag;

endmodule

