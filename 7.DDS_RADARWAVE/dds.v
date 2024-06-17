
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/09 09:35:00
// Design Name: 
// Module Name: dds
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


module dds
(
    input wire      sys_clk     ,
    input wire      sys_rst_n   ,
    input wire  [5:0]   wave_sel,
    input wire  [3:0]   mode_sel,    
    input wire  [8:0]   F,// 1 对应0.1MHZ
    input wire  [10:0]  T,//脉冲时间
    input wire  [6:0]   Z,//占空比，为0-100，意味脉冲信号占总信号的1/Z   

    output reg [21:0]    dac_data,
    output wire [7:0] dac_data_8bit
    );
wire [21:0]    dds_data;
//parameter F_WORD = 32'd21474836;//d21474836对应5e5Hz
parameter P_WORD = 23'd0;
wire T_cnt;             //该计数器用来计数是否在脉冲上
wire         T_cnt_flag; //用来判断连续波要进行的时间
//此模块为判断外界参数是否进行了改变，若是进行了改变，就对所有的内容进行清空，使之利用新的参数重新加载
judge judge_inst(
    .sys_clk            (sys_clk),
    .sys_rst_n          (sys_rst_n),
    .wave_sel           (wave_sel),
    .mode_sel           (mode_sel),    
    .F                  (F),// 1 对应0.1MHZ
    .T                  (T),//脉冲时间
    .Z                  (Z),//占空比，为0-100，意味脉冲信号占总信号的1/Z  
    .T_cnt              (T_cnt),
  
    .T_cnt_flag         (T_cnt_flag),
    .judge              (judge)
);
        
wire [31:0]  F_WORD;
wire [31:0] dds_data_nflm;//NFLM地址的发生
NFLM#(
    .P_WORD(P_WORD)
    )
NFLM_inst(
    .clk        (sys_clk),
    .rst_n      (sys_rst_n),
    .F_WORD     (F_WORD),
    .judge      (judge),
    .wave_sel   (wave_sel),    
   
    .rom_addr_reg_car   (dds_data_nflm)
);

wire  [22:0] rom_addr_bpsk;
wire  [22:0] rom_addr_qpsk; 
wire T_cnt_dp;
wire [31:0] Fw1;
mode mode_inst//BPSK,QPSK，模式选择的实现
(
    .sys_clk            (sys_clk),
    .sys_rst_n          (sys_rst_n),
    .wave_sel           (wave_sel),
    .mode_sel           (mode_sel),       
    .T                  (T),//脉冲时间
    .Z                  (Z),
    .F                  (F),
    .judge              (judge),
    
    .T_cnt              (T_cnt),//该计数器用来计数是否在脉冲上
    .T_cnt_dp           (T_cnt_dp),  
    .F_WORD             (F_WORD),
    .FW1                (Fw1),//存放要加入的结果
    .rom_addr_bpsk      (rom_addr_bpsk),
    .rom_addr_qpsk      (rom_addr_qpsk)
);

wire  [22:0] rom_addr;     //地址

fre_add#(
    .P_WORD(P_WORD)
    ) 
fre_add_inst
(
    .sys_clk                (sys_clk),
    .sys_rst_n              (sys_rst_n),
    .wave_sel               (wave_sel),
    .mode_sel               (mode_sel),
    .judge                  (judge),
    .T_cnt_flag             (T_cnt_flag),
    .T_cnt                  (T_cnt),  
    .rom_addr_bpsk          (rom_addr_bpsk),
    .rom_addr_qpsk          (rom_addr_qpsk),
    .dds_data_nflm          (dds_data_nflm[27:5]),
    .Fw1                    (Fw1),

    .rom_addr               (rom_addr)
);

dds_ctrl dds_ctrl_inst 
(
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .rom_addr_reg   (rom_addr),

    .dds_data       (dds_data)
);

always @(posedge sys_clk or negedge sys_rst_n) //模式1直接为dds_data，其他为脉冲模式，需要对其赋予0
    if(!sys_rst_n)
        dac_data <= 22'd0;
    else if(mode_sel == 4'd1)
        dac_data <= dds_data;
    else if(mode_sel != 4'd1)
        if(!T_cnt_dp)
            dac_data <= dds_data;
        else
            dac_data <= 22'd0;

wire [11:0] dac_data_12bit ;  
//wire [7:0] dac_data_8bit ;   
            
assign dac_data_12bit = (dac_data[21]==0)?dac_data[21:10] + 11'd2047:dac_data[21:10] -11'd2047;   

//要进行有符号数到无符号数的处理
assign dac_data_8bit =  (dac_data[21]==0)?dac_data[21:14] + 7'd127:dac_data[21:14] - 7'd127;            
endmodule
