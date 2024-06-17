`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/17 11:43:56
// Design Name: 
// Module Name: hex8
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

module hex8(
	input wire clk,	//50M
	input wire reset_n,
	input wire en,//数码管显示使能，1使能，0关闭
	input wire   [23:0]  bcd_data,
	input wire [2:0] flag,
	
	output reg [7:0] sel,//数码管位选（选择当前要显示的数码管）
	output reg [7:0] seg//数码管段选（当前要显示的内容）
);
    wire reset;
	assign reset=~reset_n;
	
    reg [31:0] disp_data;
    
always@(posedge clk or negedge reset_n)
    if(!reset_n)
        disp_data <={8'd0,bcd_data};
    else
        case (flag)
            3'd0: disp_data <= {4'd1,4'd0,bcd_data};
            3'd1: disp_data <= {4'd2,4'd0,bcd_data};
            3'd2: disp_data <= {4'd3,4'd0,bcd_data};
            3'd3: disp_data <= {4'd4,4'd0,bcd_data};
            3'd4: disp_data <= {4'd5,4'd0,bcd_data};
            default: disp_data <= {8'd0,bcd_data};
        endcase
	
	parameter CLOCK_FREQ = 50_000_000;
	parameter TURE_FREQ = 1000;
	parameter MCNT = CLOCK_FREQ/TURE_FREQ -1;
	
	reg [29:0]divider_cnt;//25000-1
	reg [3:0]data_tmp;//数据缓存

//	分频计数器计数模块
	always@(posedge clk or posedge reset)
	if(reset)
		divider_cnt <= 30'd0;
	else if(!en)
		divider_cnt <= 30'd0;
	else if(divider_cnt == MCNT)
		divider_cnt <= 30'd0;
	else
		divider_cnt <= divider_cnt + 1'b1;
		
    reg [2:0] cnt_sel;
	always@(posedge clk or posedge reset)
	if(reset)
	   cnt_sel <= 0;
    else if(divider_cnt == MCNT)
        cnt_sel <= cnt_sel + 1'd1;

    always@(posedge clk)
        case(cnt_sel)
            0:sel <= 8'b0000_0001;
            1:sel <= 8'b0000_0010;
            2:sel <= 8'b0000_0100;           
            3:sel <= 8'b0000_1000;
            4:sel <= 8'b0001_0000;
            5:sel <= 8'b0010_0000;
            6:sel <= 8'b0100_0000;
            7:sel <= 8'b1000_0000;
        endcase

	always@(*)
		case(cnt_sel)
			0:data_tmp = disp_data[3:0];
			1:data_tmp = disp_data[7:4];
			2:data_tmp = disp_data[11:8];
			3:data_tmp = disp_data[15:12];
			4:data_tmp = disp_data[19:16];
			5:data_tmp = disp_data[23:20];
			6:data_tmp = disp_data[27:24];
			7:data_tmp = disp_data[31:28];
			default:data_tmp = 4'b0000;
		endcase
		
	always@(*)
		case(data_tmp)
			4'h0:seg = 8'b1100_0000;
			4'h1:seg = 8'b1111_1001;
			4'h2:seg = 8'b1010_0100;
			4'h3:seg = 8'b1011_0000;
			4'h4:seg = 8'b1001_1001;
			4'h5:seg = 8'b1001_0010;
			4'h6:seg = 8'b1000_0010;
			4'h7:seg = 8'b1111_1000;
			4'h8:seg = 8'b1000_0000;
			4'h9:seg = 8'b1001_0000;
			4'ha:seg = 8'b1000_1000;
			4'hb:seg = 8'b1000_0011;
			4'hc:seg = 8'b1100_0110;
			4'hd:seg = 8'b1010_0001;
			4'he:seg = 8'b1000_0110;
			4'hf:seg = 8'b1000_1110;
		endcase

endmodule

