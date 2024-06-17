`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/12 14:30:08
// Design Name: 
// Module Name: fre_add
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


//此模块为了方便控制累加器的加减，并利用各种参数与各种波形来进行选择
module fre_add #(  
    parameter       P_WORD = 23'd0 ) 
    (
    input wire          sys_clk     ,
    input wire          sys_rst_n   ,
    input wire [5:0]    wave_sel    ,
    input wire [3:0]    mode_sel    ,
    input wire          judge       ,
    input wire          T_cnt_flag  ,
    input wire          T_cnt       ,
    input wire  [22:0]  rom_addr_bpsk,
    input wire  [22:0]  rom_addr_qpsk,
    input wire  [22:0]  dds_data_nflm,
    input wire  [31:0]  Fw1         ,
    
    output wire [22:0]   rom_addr    
);

reg [31:0] theta;

//LFM中的相位变化
always @(posedge sys_clk or negedge sys_rst_n) //相位值，如果参数发生变化则从零开始计数，否则就增加频率字的大小
    if(!sys_rst_n)
        theta <= 32'd0;
    else if(wave_sel != 6'b000100)
        theta <=  32'd0;      
    else if(judge)
        theta <=  32'd0;       
    else if(T_cnt_flag)
        theta <=  32'd0;       
    else
        theta <= theta + Fw1;
      
reg [31:0] fre_add;//累加器，第一次对于地址的改变

always @(posedge sys_clk or negedge sys_rst_n) //累加器，可以使用流水线进行优化
    if(!sys_rst_n)
        fre_add <= 32'd0;
    else if(judge)
        fre_add <= 32'd0;     
    else if((mode_sel != 4'd1)&&(T_cnt))//对于脉冲来说，占空时累加器需要置0，输出数据置0使得器件休息
         fre_add <= 32'd0;     
    else if(wave_sel == 6'b000100)//lfm
        if(T_cnt_flag)//每翻转一次，对其置0，这是因为在仿真时发现了LFM存在杂散的原因
             fre_add <= 32'd0;           
        else
            fre_add <= fre_add + theta;     
    else  if(wave_sel == 6'b100000)//nflm
                fre_add <= fre_add  + Fw1;      
    else
        fre_add <= fre_add + Fw1;

reg [22:0] rom_addr_theta;     //截断之后的地址改变量，第二次改变
always @(posedge sys_clk or negedge sys_rst_n) 
    if(!sys_rst_n)
        rom_addr_theta <= 23'd0;
    else if(wave_sel  == 6'b000010)//此处是对cos载波的处理，直接加上pi/2的相位即可
        rom_addr_theta <=  P_WORD + 21'd2097151; 
    else if(wave_sel == 6'b000100)//LFM需加入相位调制，使之成为实部
        rom_addr_theta <=  P_WORD + 21'd2097151;//输出实部需要加上该项21'd2097151,2^23 / 4 - 1
    else if(wave_sel == 6'b001000)//此处是对BPSK的处理
        rom_addr_theta <=  P_WORD +  rom_addr_bpsk;
    else if(wave_sel == 6'b010000) //此处是对QPSK的处理
        rom_addr_theta <=  P_WORD +  rom_addr_qpsk;
    else  if(wave_sel == 6'b100000)//nflm
        rom_addr_theta <=  P_WORD +  dds_data_nflm;
    else//对于sin直接加上即可
        rom_addr_theta <=  P_WORD;
    
assign rom_addr = rom_addr_theta + fre_add[31:9];
endmodule
