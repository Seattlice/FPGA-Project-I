`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/10 17:49:37
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


`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/09 10:32:37
// Design Name: 
// Module Name: tb_dds
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

module tb_dds( );

reg     sys_clk;
reg     sys_rst_n;
reg     [5:0]   wave_sel;
reg     [8:0]   F0;
reg     [3:0]   mode_sel;
reg     [10:0]   T;
reg     [6:0]   Z;
wire    [21:0]   dds_data;


initial begin
    sys_clk     =  1'b1;
    sys_rst_n   <= 1'b0;
    wave_sel    <=  6'b000001;
    mode_sel<= 4'd1;    
    F0 <= 9'd10;
    Z <= 7'd2;
    T   <= 11'd10;
    #200;
    sys_rst_n <= 1'b1;
    //F0 <= 9'd400;

    #100000;
     wave_sel    <=  6'b000010;
    #10000;
    wave_sel    <=  6'b000100;
    #10000;
    wave_sel    <=  6'b001000;
    #10000;
    wave_sel    <=  6'b010000;
    #10000;
    wave_sel    <=  6'b100000;
    #10000;
    $stop;
 //  wave_sel    <=  6'b010000;
    #50000;
   // wave_sel    <=  6'b00100;
     //#1000;
    //F0 <= 9'd30;

    #80;
    mode_sel<= 4'd1;
    //wave_sel    <=  6'b010000;
    #80000;
    Z <= 7'd8; 
   F0 <= 9'd50;
    #80000;
    F0 <= 9'd100;   
   // mode_sel<= 4'b0010;
    #160000;
    F0 <= 9'd200;  
    //wave_sel    <=  6'b010000;
    #90000;    
    Z <= 7'd5;
    F0 <= 9'd300;         
    //mode_sel<= 4'b0100;
    #80000;
   // wave_sel    <=  6'b000100;    
    F0 <= 9'd400; 
    T <= 11'd5;
   #80000;
    Z <= 7'd10;   
    //mode_sel<= 4'b1000;
    T <= 11'd30;
    #80000;
   // wave_sel    <=  6'b010000;
    #80000;
    F0 <= 9'd100;
    #40000;
   // mode_sel<= 4'b0010;    
    F0 <= 9'd400;
    #40000;
    Z <= 7'd6;    
    T <= 11'd40;    
    //wave_sel    <=  6'b000100;
    #40000;
    F0 <= 9'd5;
    #40000;
    //wave_sel    <=  6'b100000;
    #40000;
    F0 <= 9'd100;
    #40000;
    T <= 11'd5;  
   // wave_sel    <=  6'b000100;
    #800;
    $stop;
end

always #10 sys_clk= ~sys_clk;

dds dds_inst
(
    .sys_clk     (clk_500m),
    .sys_rst_n   (sys_rst_n),
    .wave_sel    (wave_sel),
    .F           (F0),
    .T           (T),
    .mode_sel    (mode_sel),
    .Z           (Z),
    
    .dac_data    (dds_data)
);

////用来生成大脉宽信号
  pll_ip pll_inst
   (
    // Clock out ports
    .clk_200m(clk_500m),     // output clk_100m
    .clk_25m(clk_25m),     // output clk_25m
    // Status and control signals
    .resetn(sys_rst_n), // input resetn
    .locked(locked),       // output locked
   // Clock in ports
    .sys_clk(sys_clk));      // input sys_clk
    

endmodule


