
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/13 18:38:45
// Design Name: 
// Module Name: led
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


module key_control(
input wire clk,
input wire reset_n,
input wire key_in0,//wave_sel
input wire key_in1,//mode_sel
input wire key_in2,//F
input wire key_in3,//T
input wire key_in4,//Z


output wire  [5:0]   wave_sel,
output wire  [3:0]   mode_sel,    
output wire  [8:0]   F,// 1 对应0.1MHZ
output wire  [10:0]  T,//脉冲时间
output wire  [6:0]   Z,//占空比，为0-100，意味脉冲信号占总信号的1/Z   
output wire         RCLK,
output wire         SRCLK,
output wire         DIO
);

wire key_wave,key_mode,key_F,key_T,key_Z;

parameter CNT_MAX = 20'd999_999;

key_fliter  #(
     .CNT_MAX(CNT_MAX)
)key_fliter_inst0
(
.sys_clk                    (clk),
.sys_rst_n                  (reset_n),
.key_in                     (key_in0),

.key_flag                    (key_wave)
);

key_fliter  #(
     .CNT_MAX(CNT_MAX)
)key_fliter_inst1
(
.sys_clk                    (clk),
.sys_rst_n                  (reset_n),
.key_in                     (key_in1),

.key_flag                    (key_mode)
);

key_fliter  #(
     .CNT_MAX(CNT_MAX)
)key_fliter_inst2
(
.sys_clk                    (clk),
.sys_rst_n                  (reset_n),
.key_in                     (key_in2),

.key_flag                    (key_F)
);

key_fliter  #(
     .CNT_MAX(CNT_MAX)
)key_fliter_inst3
(
.sys_clk                    (clk),
.sys_rst_n                  (reset_n),
.key_in                     (key_in3),

.key_flag                    (key_T)
);

key_fliter  #(
     .CNT_MAX(CNT_MAX)
)key_fliter_inst4
(
.sys_clk                    (clk),
.sys_rst_n                  (reset_n),
.key_in                     (key_in4),

.key_flag                    (key_Z)
);

wire [19:0] disp_data;
wire [2:0]  flag;
para_con para_con_inst(
.clk                (clk), //模块工作时钟输入，50M
.reset_n            (reset_n), //复位信号输入，低有效
.key_wave            (key_wave), 
.key_mode            (key_mode), 
.key_F               (key_F), 
.key_T               (key_T), 
.key_Z               (key_Z),  

.wave_sel                   (wave_sel),
.mode_sel                   (mode_sel),
.F                          (F),// 1 对应0.1MHZ
.T                          (T),//脉冲时间
.Z                          (Z),//占空比，为0-100，意味脉冲信号占总信号的1/Z   
.disp_data                  (disp_data),
.flag                       (flag)
    );


hex_top hex_top_inst(
    .clk                                (clk                       ),//50M
    .reset_n                            (reset_n                   ),
    .disp_data                          (disp_data                 ),
	.flag                               (flag                      ),   
	
    .RCLK                               (RCLK                      ),
    .SRCLK                              (SRCLK                     ),
    .DIO                                (DIO                       ) 
);



endmodule

