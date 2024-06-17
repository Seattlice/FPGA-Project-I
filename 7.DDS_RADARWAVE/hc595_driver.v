`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/17 11:43:11
// Design Name: 
// Module Name: hc595_driver
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



// 
//////////////////////////////////////////////////////////////////////////////////
module hc595_driver(
	clk,   
	reset_n,
	seg,
	sel,

	RCLK,
	SRCLK,
	DIO
);

	input clk;
	input reset_n;
	input [7:0] sel;
	input [7:0] seg;
	
	output reg RCLK;
	output reg SRCLK;
	output reg DIO;
	wire reset;
	assign reset=~reset_n;
	
	parameter CLOCK_FREQ = 50_000_000;
	parameter SRCLK_FREQ = 12_500_000;
	parameter MCNT = CLOCK_FREQ/(SRCLK_FREQ * 2 )-1;
	
	reg [29:0] divider_cnt;
	
//	分频计数器计数模块
	always@(posedge clk or posedge reset)
	if(reset)
		divider_cnt <= 30'd0;
	else if(divider_cnt == MCNT)
		divider_cnt <= 30'd0;
	else
		divider_cnt <= divider_cnt + 1'b1;
	
    reg [4:0] cnt;
	always@(posedge clk or posedge reset)
	if(reset)
	   cnt <= 0;
    else if(divider_cnt == MCNT)
        cnt <= cnt + 1'd1;
	
    always@(posedge clk or posedge reset)
	if(reset) begin
	DIO<= 1'd0;
	SRCLK<=1'd0;
	RCLK <= 1'd0;
	end
	else begin
	   case(cnt)
	       0:begin DIO <= seg[7] ;SRCLK<=1'd0; RCLK <= 1'd1;end
	       1:begin SRCLK<=1'd1;RCLK <= 1'd0; end
	       2:begin DIO <= seg[6] ;SRCLK<=1'd0;end
	       3:begin SRCLK<=1'd1; end	
	       4:begin DIO <= seg[5] ;SRCLK<=1'd0;end
	       5:begin SRCLK<=1'd1; end	
	       6:begin DIO <= seg[4] ;SRCLK<=1'd0;end
	       7:begin SRCLK<=1'd1; end	
	       8:begin DIO <= seg[3] ;SRCLK<=1'd0;end
	       9:begin SRCLK<=1'd1; end	
	       10:begin DIO <= seg[2] ;SRCLK<=1'd0;end
	       11:begin SRCLK<=1'd1; end	
	       12:begin DIO <= seg[1] ;SRCLK<=1'd0;end
	       13:begin SRCLK<=1'd1; end	
	       14:begin DIO <= seg[0] ;SRCLK<=1'd0;end
	       15:begin SRCLK<=1'd1; end	
	       16:begin DIO <= sel[7] ;SRCLK<=1'd0;end
	       17:begin SRCLK<=1'd1; end	
	       18:begin DIO <= sel[6] ;SRCLK<=1'd0;end
	       19:begin SRCLK<=1'd1; end		
	       20:begin DIO <= sel[5] ;SRCLK<=1'd0;end
	       21:begin SRCLK<=1'd1; end		
	       22:begin DIO <= sel[4] ;SRCLK<=1'd0;end
	       23:begin SRCLK<=1'd1; end		
	       24:begin DIO <= sel[3] ;SRCLK<=1'd0;end
	       25:begin SRCLK<=1'd1; end		
	       26:begin DIO <= sel[2] ;SRCLK<=1'd0;end
	       27:begin SRCLK<=1'd1; end		
	       28:begin DIO <= sel[1] ;SRCLK<=1'd0;end
	       29:begin SRCLK<=1'd1; end	
	       30:begin DIO <= sel[0] ;SRCLK<=1'd0;end
	       31:begin SRCLK<=1'd1; end	
        endcase
        end

endmodule
	