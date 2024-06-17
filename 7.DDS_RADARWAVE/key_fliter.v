`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/17 12:03:03
// Design Name: 
// Module Name: key_fliter
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


module key_fliter #(
    parameter CNT_MAX = 20'd999_999
)
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,
    input  wire                         key_in                     ,

    output reg                         key_flag                    
);
    
reg [19:0]  cnt_20ms;


always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cnt_20ms <= 20'd0;
    else if(key_in == 1'b1)
        cnt_20ms <= 20'd0;
    else if(cnt_20ms == CNT_MAX)
        cnt_20ms <= CNT_MAX;
    else 
        cnt_20ms <= cnt_20ms + 1'b1;

end    

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        key_flag <= 1'b0;
    else if(cnt_20ms == (CNT_MAX - 20'd1))
        key_flag <= 1'b1;
    else
        key_flag <= 1'b0;


end


endmodule
