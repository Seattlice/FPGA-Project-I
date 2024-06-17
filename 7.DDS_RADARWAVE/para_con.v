`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/17 12:03:30
// Design Name: 
// Module Name: para_con
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/13 18:33:31
// Design Name: 
// Module Name: key_led
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

//参数控制模块，来对承诺书进行合理的控制
module para_con(
    input wire clk, //模块工作时钟输入，50M
    input wire reset_n, //复位信号输入，低有效
    input wire key_wave,//wave_sel
    input wire key_mode,//mode_sel
    input wire key_F,//F
    input wire key_T,//T
    input wire key_Z,//Z
    
    output reg  [5:0]   wave_sel,
    output reg  [3:0]   mode_sel,    
    output reg  [8:0]   F,// 1 对应0.1MHZ
    output reg  [10:0]  T,//脉冲时间
    output reg  [6:0]   Z,//占空比，为0-100，意味脉冲信号占总信号的1/Z   
    output reg  [19:0]  disp_data,
    output reg  [2:0]  flag //用来控制现实的参数是什么      
    );
    
//对于波形选择wave_sel的控制
always@(posedge clk or negedge reset_n)
    if(!reset_n)
        wave_sel <= 6'b000_001;
    else if(key_wave)
        wave_sel <= wave_sel << 1;
    else if(wave_sel == 6'b000_000)
        wave_sel <= 6'b000_001;
    else
        wave_sel <= wave_sel;

//对于模式选择mode_sel的控制
always@(posedge clk or negedge reset_n)
    if(!reset_n)
        mode_sel <= 4'b0001;
    else if(key_mode)
        mode_sel <= mode_sel << 1;
    else if(mode_sel == 4'b0)
        mode_sel <= 4'b0001;
    else 
         mode_sel <= mode_sel;

//对于频率选择F的控制
always@(posedge clk or negedge reset_n)
    if(!reset_n)
        F <= 9'd1;
    else if(key_F)
        F <= F + 9'd1;
    else if(F == 9'd300)
        F <= 9'd10;
    else
        F <= F ;
          
//对于脉冲时间T的控制
always@(posedge clk or negedge reset_n)
    if(!reset_n)
        T <= 11'd10;
    else if(key_T)
        T <= T + 11'd10;
    else if(T == 11'd800)
        T <= 11'd10;
    else
        T <= T ;

//对于占空比Z的控制
always@(posedge clk or negedge reset_n)
    if(!reset_n)
        Z <= 7'd2;
    else if(key_Z)
        Z <= Z + 1'd1;
    else if(Z == 7'd20)
        Z <= 7'd2;
    else
        Z <= Z ;    

//参数转换生成数码管所需要计算的数据
//reg [2:0] flag;//用来控制现实的参数是什么
always@(posedge clk or negedge reset_n)
    if(!reset_n)
        flag <= 3'd0;
    else if(key_wave)
        flag <= 3'd0;
    else if(key_mode)
        flag <= 3'd1;
    else if(key_F)
        flag <= 3'd2;
    else if(key_T)
        flag <= 3'd3;
    else if(key_Z)
        flag <= 3'd4;
    else
        flag <= flag;

reg [2:0] cnt_wave;
always@(posedge clk or negedge reset_n)
    if(!reset_n)
        cnt_wave <= 3'd0;
    else 
        case (wave_sel)
            6'b000_001:cnt_wave <= 3'd1;
            6'b000_010:cnt_wave <= 3'd2;
            6'b000_100:cnt_wave <= 3'd3;
            6'b001_000:cnt_wave <= 3'd4;
            6'b010_000:cnt_wave <= 3'd5;
            6'b100_000:cnt_wave <= 3'd6;
            default: cnt_wave <= 3'b1;
        endcase

reg [2:0] cnt_mode;
always@(posedge clk or negedge reset_n)
    if(!reset_n)
        cnt_mode <= 3'd0;
    else 
        case (mode_sel)
            4'b0_001:cnt_mode <= 3'd1;
            4'b0_010:cnt_mode <= 3'd2;
            4'b0_100:cnt_mode <= 3'd3;
            4'b1_000:cnt_mode <= 3'd4;
            default: cnt_mode <= 3'b0;
        endcase

always@(posedge clk or negedge reset_n)
    if(!reset_n)
        disp_data <= 20'd0;
    else
        case (flag)
            3'd0: disp_data <= cnt_wave;
            3'd1: disp_data <= cnt_mode;
            3'd2: disp_data <= F;
            3'd3: disp_data <= T;
            3'd4: disp_data <= Z;
            default: disp_data <= 20'b0;
        endcase


endmodule
