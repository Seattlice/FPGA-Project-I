`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/23 19:46:50
// Design Name: 
// Module Name: NFLM
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


module NFLM
 #(  
    parameter       P_WORD = 23'd0 )
 (
    input wire clk,
    input wire rst_n,
    input wire [31:0] F_WORD,
    input wire judge,
    input wire  [5:0]   wave_sel,
    
    output reg [31:0] rom_addr_reg_car
    );
wire [21:0] dds_data_nflm;

reg [31:0]  fre_add1;
reg [22:0]  rom_addr_reg_car1;//用来进行载波的控制

always @(posedge clk or negedge rst_n) 
    if(!rst_n)
        fre_add1 <= 32'd0;
    else if(judge)
        fre_add1 <= 32'd0;   
    else if(wave_sel != 6'b100000)
        fre_add1 <= 32'd0;    
    else
        fre_add1 <= fre_add1 + (F_WORD>>2);

always @(posedge clk or negedge rst_n) 
    if(!rst_n)
        rom_addr_reg_car1 <= 23'd0;
    else if(judge)
        rom_addr_reg_car1 <= 32'd0;   
    else if(wave_sel != 6'b100000)
        rom_addr_reg_car1 <= 32'd0;  
    else 
        rom_addr_reg_car1 <= fre_add1[31:9]  + P_WORD ;

dds_ctrl dds_ctrl_inst 
(
    .sys_clk        (clk),
    .sys_rst_n      (rst_n),
    .rom_addr_reg   (rom_addr_reg_car1),

    .dds_data       (dds_data_nflm)
);
always @(posedge clk or negedge rst_n) 
    if(!rst_n)
        rom_addr_reg_car <= 32'd0;
    else if(judge)
        rom_addr_reg_car <= 32'd0;   
    else if(wave_sel != 6'b100000)
        rom_addr_reg_car <= 32'd0;        
    else //nflm
        rom_addr_reg_car <= (dds_data_nflm[21] == 0? dds_data_nflm + 21'd2097151 : dds_data_nflm -  21'd2097151)<<6;      
endmodule
