
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/23 15:55:28
// Design Name: 
// Module Name: dds_ctrl
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

module dds_ctrl 
(
    input wire      sys_clk     ,
    input wire      sys_rst_n   ,
    input wire  [22:0]   rom_addr_reg,

    output wire [21:0]    dds_data
);

wire [4:0] rom_taylor;      //泰勒修正位
wire [7:0] rom_fine;         //细表
wire [7:0] rom_corse;        //粗表
wire [7:0] rom_corse_cos;
wire [1:0] rom_quadrant;     // 象限

wire [21:0] sin_corse;//用来存储从ROM中导出的粗细表值
wire [21:0] cos_corse;
wire [13:0] sin_fine;
wire [3:0]  cos_fine;

reg signed [21:0] cos_car;//用来存储进行象限变换后的值
reg signed [21:0] sin_car;

reg [26:0] mul1;//用来存储乘法器的结果
reg [43:0] mul2;

reg [26:0] mul3;//cos结果
reg [43:0] mul4;

reg [21:0] sin_x0;//x0生成的结果
reg [21:0] cos_x0;//x0生成的结果

reg [6:0] taylor_hudu;//角度结果

reg signed [21:0] dac_sin;//最后的结果
reg signed [21:0] dac_cos;

//ROM的实例化
sin_corse rom_sin_corse_inst 
(
  .clka(sys_clk),    // input wire clka
  .addra(rom_corse),  // input wire [7 : 0] addra
  .douta(sin_corse)  // output wire [21 : 0] douta
);

sin_corse rom_sin_corse_inst2 
(
  .clka(sys_clk),    // input wire clka
  .addra(rom_corse_cos),  // input wire [7 : 0] addra
  .douta(cos_corse)  // output wire [21 : 0] douta
);

sin_fine rom_sin_fine_inst 
(
  .clka(sys_clk),    // input wire clka
  .addra(rom_fine),  // input wire [7 : 0] addra
  .douta(sin_fine)  // output wire [13: 0] douta
);

cos_fine rom_cos_fine_inst 
(
  .clka(sys_clk),    // input wire clka
  .addra(rom_fine),  // input wire [7 : 0] addra
  .douta(cos_fine)  // output wire [3: 0] douta
);



reg [1:0] cnt;    //用来打拍的计数器，因为象限改变与计算具有一定的延迟性
reg [1:0] cnt1;
reg [1:0] cnt2;
reg [1:0] cnt3;
always @(posedge sys_clk or negedge sys_rst_n) //因为乘法器需要进行分布计算，所以必须要打拍，一共打3拍
    if(!sys_rst_n)
        cnt <= 2'd0;
    else
        cnt <= rom_addr_reg[22:21];

always @(posedge sys_clk or negedge sys_rst_n) 
    if(!sys_rst_n)
        cnt1 <= 2'd0;
    else
        cnt1 <= cnt;

always @(posedge sys_clk or negedge sys_rst_n) 
    if(!sys_rst_n)
        cnt2 <= 2'd0;
    else
        cnt2 <= cnt1;

always @(posedge sys_clk or negedge sys_rst_n) 
    if(!sys_rst_n)
        cnt3 <= 2'd0;
    else
        cnt3 <= cnt2;

assign rom_quadrant  = cnt3;                            //象限赋值
assign rom_corse     = rom_addr_reg[20:13];              //粗表赋值
assign rom_corse_cos = 8'd255 - rom_addr_reg[20:13];     //粗表赋值
assign rom_fine      = rom_addr_reg[12:5];              //细表赋值
assign rom_taylor    = rom_addr_reg[4:0];               //泰勒修正位赋值

//reg [1:0] cnt;    //用来打拍的计数器，因为象限改变与计算具有一定的延迟性
// reg [1:0] cnt1;
// reg [1:0] cnt2;
// reg [1:0] cnt3;
// always @(posedge sys_clk or negedge sys_rst_n) //根据象限的不同来进行载波的选择
//     if(!sys_rst_n)
//         cnt <= 2'd0;
//     else
//         cnt <= rom_addr_reg[22:21];

// always @(posedge sys_clk or negedge sys_rst_n) //根据象限的不同来进行载波的选择
//     if(!sys_rst_n)
//         cnt1 <= 2'd0;
//     else
//         cnt1 <= cnt;

// always @(posedge sys_clk or negedge sys_rst_n) //根据象限的不同来进行载波的选择
//     if(!sys_rst_n)
//         cnt2 <= 2'd0;
//     else
//         cnt2 <= cnt1;

// always @(posedge sys_clk or negedge sys_rst_n) //根据象限的不同来进行载波的选择
//     if(!sys_rst_n)
//         cnt3 <= 2'd0;
//     else
//         cnt3 <= cnt2;

// // always @(posedge sys_clk or negedge sys_rst_n) //根据象限的不同来进行载波的选择
// //     if(!sys_rst_n)
// //         cnt4 <= 2'd0;
// //     else
// //         cnt4 <= cnt3;

// always @(posedge sys_clk or negedge sys_rst_n) //象限赋值
//     if(!sys_rst_n)
//         rom_quadrant <= 2'd0;
//     else
//         rom_quadrant <= cnt3;

// always @(posedge sys_clk or negedge sys_rst_n) //粗表赋值
//     if(!sys_rst_n)
//         rom_corse <= 8'd0;
//     else
//         rom_corse <= rom_addr_reg[20:13];

// always @(posedge sys_clk or negedge sys_rst_n) //粗表赋值
//     if(!sys_rst_n)
//         rom_corse_cos <= 8'd0;
//     else
//         rom_corse_cos <= 8'd255 - rom_addr_reg[20:13];


// always @(posedge sys_clk or negedge sys_rst_n) //细表赋值
//     if(!sys_rst_n)
//         rom_fine <= 8'd0;
//     else
//         rom_fine <= rom_addr_reg[12:5];

// always @(posedge sys_clk or negedge sys_rst_n) //泰勒修正位赋值
//     if(!sys_rst_n)
//         rom_taylor <= 5'd0;
//     else
//         rom_taylor <= rom_addr_reg[4:0];
//乘法器
always @(posedge sys_clk or negedge sys_rst_n) //用来存储粗表与细表之积的乘法器
    if(!sys_rst_n)
        mul1 <= 27'd0;
    else
        mul1 <= (sin_corse * cos_fine) ;

always @(posedge sys_clk or negedge sys_rst_n) //用来存储粗表与细表之积的乘法器
    if(!sys_rst_n)
        mul2 <= 44'd0;
    else
        mul2 <= (cos_corse * sin_fine) ;

always @(posedge sys_clk or negedge sys_rst_n)//用来存储粗表与细表之积的乘法器
    if(!sys_rst_n)
        mul3 <= 27'd0;
    else
        mul3 <= (cos_corse * cos_fine);

always @(posedge sys_clk or negedge sys_rst_n) //用来存储粗表与细表之积的乘法器
    if(!sys_rst_n)
        mul4 <= 44'd0;
    else
        mul4 <= (sin_corse * sin_fine);

//加法器
always @(posedge sys_clk or negedge sys_rst_n) //利用CARDARILLI结构进行计算的结果
    if(!sys_rst_n)   
        sin_x0 <= 22'd0;
    else
        sin_x0 <= (sin_corse + ( mul1 >> 21 ) + ( mul2 >> 22 ))>>1;

always @(posedge sys_clk or negedge sys_rst_n) //利用CARDARILLI结构进行计算的结果
    if(!sys_rst_n)
        cos_x0 <= 22'd0;
    else
        cos_x0 <= (cos_corse + ( mul3 >> 21 ) + ( mul4 >> 22 ))>>1;

//泰勒修正
always @(posedge sys_clk or negedge sys_rst_n) //泰勒修正位乘以6，近似的2pi
    if(!sys_rst_n)
        taylor_hudu <= 7'd0;
    else
        taylor_hudu <=  rom_taylor << 2 + rom_taylor << 1;

//给出最终的结果
always @(posedge sys_clk or negedge sys_rst_n) //最后的修正结果
    if(!sys_rst_n)
        sin_car <= 22'd0;
    else
        sin_car <= (sin_x0  + ((taylor_hudu * cos_x0 ) >> 22 ) -( sin_x0 * taylor_hudu * taylor_hudu >>31))>>1;


always @(posedge sys_clk or negedge sys_rst_n) //最后的修正结果
    if(!sys_rst_n)
        cos_car <= 22'd0;
    else
        cos_car <= (cos_x0 - ((taylor_hudu * sin_x0 )>> 22) + ((cos_x0 * taylor_hudu * taylor_hudu)>>31))>>1;

always @(posedge sys_clk or negedge sys_rst_n) //根据象限的不同来进行载波的选择
    if(!sys_rst_n)
        dac_sin <= 22'd0;
    else
        case(rom_quadrant)
            2'b00:dac_sin <= sin_car;
            2'b01:dac_sin <= cos_car;
            2'b10:dac_sin <= ~sin_car + 1'd1;
            2'b11:dac_sin <= ~cos_car + 1'd1;
        default:
            dac_sin <= sin_car;
        endcase      

always @(posedge sys_clk or negedge sys_rst_n) //根据象限的不同来进行载波的选择
    if(!sys_rst_n)
        dac_cos <= 22'd0;
    else
        case(rom_quadrant)
            2'b00:dac_cos <= cos_car;
            2'b01:dac_cos <= ~sin_car + 1'd1;
            2'b10:dac_cos <= ~cos_car + 1'd1;
            2'b11:dac_cos <= sin_car;
        default:dac_cos <= cos_car;
        endcase      


assign dds_data = dac_sin;

endmodule

