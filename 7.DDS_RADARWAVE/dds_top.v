`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/17 13:48:57
// Design Name: 
// Module Name: dds_top
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
//****************************************VSCODE PLUG-IN**********************************//
//----------------------------------------------------------------------------------------
// IDE :                   VSCODE     
// VSCODE plug-in version: Verilog-Hdl-Format-1.9.20240413
// VSCODE plug-in author : Jiang Percy
//----------------------------------------------------------------------------------------
//****************************************Copyright (c)***********************************//
// Copyright(C)            Please Write Company name
// All rights reserved     
// File name:              
// Last modified Date:     2024/04/17 13:49:38
// Last Version:           V1.0
// Descriptions:           
//----------------------------------------------------------------------------------------
// Created by:             Please Write You Name 
// Created date:           2024/04/17 13:49:38
// Version:                V1.0
// TEXT NAME:              dds_top.v
// PATH:                   C:\Users\Administrator\Desktop\SORCE\verilog\stu\hc595\key_hc595.v\dds_top.v
// Descriptions:           
//                         
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module dds_top(
    input wire      sys_clk     ,
    input wire      sys_rst_n   ,
    input wire      key_in0,//wave_sel
    input wire      key_in1,//mode_sel
    input wire      key_in2,//F
    input wire      key_in3,//T
    input wire      key_in4,//Z
    
    input wire    [7:0] ad,//输入的转换后的信号
  
    output wire      da_clk,//DAC 50MHZ/135MHZMAX
    output wire      ad_clk,//ADC 50MHZ/35MHZMAX
    output wire   [7:0] da_data,//输出的转换前的信号
    

    output wire         RCLK,
    output wire         SRCLK,
    output wire         DIO
    //output wire [21:0]    dac_data

    );               

wire clk_25m;                                              
assign da_clk = ~sys_clk;
assign ad_clk = ~sys_clk;

     wire  [5:0]   wave_sel;//波形选择
     wire  [3:0]   mode_sel;//模式选择
     wire  [8:0]   F;// 1 对应0.1MHZ
     wire  [10:0]  T;//脉冲时间
     wire  [6:0]   Z;//占空比，为0-100，意味脉冲信号占总信号的1/Z   
    
    //wire   clk_1G;
   // wire   clk_100m;
    // wire [21:0]    dac_data;

key_control key_control_inst(
    .clk                                (sys_clk                       ),//模块工作时钟输入，50M
    .reset_n                            (sys_rst_n                   ),//复位信号输入，低有效
    .key_in0                            (key_in0                   ),
    .key_in1                            (key_in1                   ),
    .key_in2                            (key_in2                   ),
    .key_in3                            (key_in3                   ),
    .key_in4                            (key_in4                   ),


    .wave_sel                           (wave_sel                  ),
    .mode_sel                           (mode_sel                  ),
    .F                                  (F                         ),// 1 对应0.1MHZ
    .T                                  (T                         ),//脉冲时间
    .Z                                  (Z                         ),//占空比，为0-100，意味脉冲信号占总信号的1/Z   
    .RCLK                               (RCLK                      ),
    .SRCLK                              (SRCLK                     ),
    .DIO                                (DIO                       ) 
);
wire [7:0] dac_data_8bit;
dds dds_inst
(
    .sys_clk                            (clk_200m                  ),
    .sys_rst_n                          (sys_rst_n                 ),
    .wave_sel                           (wave_sel                  ),
    .mode_sel                           (mode_sel                  ),
    .F                                  (F                         ),// 1 对应0.1MHZ
    .T                                  (T                         ),//脉冲时间
    .Z                                  (Z                         ),//占空比，为0-100，意味脉冲信号占总信号的1/Z   

    //.dac_data                           (dac_data                  ),
    .dac_data_8bit                      (dac_data_8bit              )
    );


reg [7:0] ad_data;

always@(posedge ad_clk)
    ad_data <= ~ad;
    
assign da_data = ~dac_data_8bit;

wire clk_100m;

////用来生成大脉宽信号
  pll_ip pll_inst
   (
    // Clock out ports
    .clk_200m(clk_200m),     // output clk_100m
    .clk_25m(clk_25m),     // output clk_25m
    // Status and control signals
    .resetn(sys_rst_n), // input resetn
    .locked(locked),       // output locked
   // Clock in ports
    .sys_clk(sys_clk));      // input sys_clk
    
//用来查看波形
ila_adda ila_adda_inst(
	.clk(clk_200m), // input wire clk


	.probe0(da_data), // input wire [7:0]  probe0  
	.probe1(ad_data), // input wire [7:0]  probe1 
	.probe2(wave_sel), // input wire [5:0]  probe2 
	.probe3(mode_sel), // input wire [3:0]  probe3 
	.probe4(F), // input wire [8:0]  probe4 
	.probe5(T), // input wire [10:0]  probe5 
	.probe6(Z), // input wire [6:0]  probe6
	.probe7(sys_clk)
);


endmodule
