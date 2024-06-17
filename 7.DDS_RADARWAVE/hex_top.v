
//////////////////////////////////////////////////////////////////////////////////
module hex_top(
	input wire clk,//50M
	input wire reset_n,
	input wire [19:0] disp_data,
	input wire [2:0] flag,
	
	output wire RCLK,
	output wire SRCLK,
	output wire DIO
);
	wire [7:0] sel;//数码管位选（选择当前要显示的数码管）
	wire [7:0] seg;//数码管段选（当前要显示的内容)
	wire          [23:0]          bcd_data;
	
	hc595_driver hc595_driver(
		.clk(clk),
		.reset_n(reset_n),
		.sel(sel),
		.seg(seg),
		
		
		.RCLK(RCLK),
		.SRCLK(SRCLK),
		.DIO(DIO)
	);
	
	hex8 hex8(
		.clk(clk),
		.reset_n(reset_n),
		.en(1'b1),
		.bcd_data(bcd_data),
		.flag (flag),
		
		.sel(sel),
		.seg(seg)
	);
	
	bcd_8421 bcd_8421_inst
(
.sys_clk                    (clk),//系统时钟，频率50MHz
.sys_rst_n                  (reset_n),//复位信号，低电平有效
.data                       (disp_data),//输入需要转换的数据

.bcd_data                   (bcd_data)
 );
   	
endmodule
