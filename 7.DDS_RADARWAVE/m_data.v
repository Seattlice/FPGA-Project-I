`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/09 10:18:08
// Design Name: 
// Module Name: m_data
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


module m_data(
  input wire clk,          // 时钟信号
  input wire rst_n,        // 复位信号
  input wire [8:0] F0,
  input wire FW_flag,       //频率捷变是否变化
  input wire [3:0] mode_sel,
  input wire [5:0] wave_sel,
  input wire T_cnt,
  input wire judge,
  
  output reg  [22:0] rom_addr_bpsk,
  output reg [22:0] rom_addr_qpsk
);

reg [3:0] state;    // 状态寄存器
reg [15:0] cnt;     //计数器
reg [1:0] m_data2;
reg [13:0] STOP;
reg [1:0] I_tmp;
reg [1:0] Q_tmp;
reg m_data;// m序列位输出

 always @(posedge clk or negedge rst_n)
    if(!rst_n)
        STOP <= 14'd0;
    else if((judge)||(FW_flag))
        STOP <=  1000/F0    ;
    else 
        STOP <= STOP;

 always @(posedge clk or negedge rst_n)
    if(!rst_n)
        cnt <= 16'd0;
    else if(cnt == STOP - 1'd1)
        cnt <= 16'd0;
    else if(judge||FW_flag)
        cnt <= 16'd0; 
    else if((mode_sel != 4'b0001)&&(T_cnt == 1'd1))
         cnt <= 16'd0;      
    else if((wave_sel != 6'b001000)&&(wave_sel != 6'b010000))
        cnt <= 16'd0;              
    else
        cnt <= cnt + 16'd1;

  always @(posedge clk)
      if(!rst_n)
        state <= 4'b1001;  // 初始化初始状态
      else if(cnt == STOP - 3'd5)
        state <= {state[2:0], state[3] ^ state[2]}; // 进行位移和反馈操作
    else if(judge||FW_flag)
        state <= 4'b1001;  // 初始化初始状态
    else if((wave_sel != 6'b001000)&&(wave_sel != 6'b010000))//如不为psk调制，使其始终为0
        state <= 4'b1001;  
    else if((mode_sel != 4'b0001)&&(T_cnt == 1'd1))//占空时始终为0
        state <= 4'b1001;  // 初始化初始状态            
    else 
        state <= state;

  always @(posedge clk)
    if(!rst_n)
        m_data <= 1'd0;
    else if(judge||FW_flag)
        m_data <= 1'd0;    
    else if((mode_sel != 4'b0001)&&(T_cnt == 1'd1))//占空时始终为0
        m_data <= 1'd0;   
    else if((wave_sel != 6'b001000)&&(wave_sel != 6'b010000))//如不为psk调制，使其始终为0
        m_data <= 1'd0;  
    else
        m_data <= state[0]; // 在时钟上升沿触发时，输出m序列位

//QPSK生成
always@(posedge clk or negedge rst_n)
    if(!rst_n)
        m_data2 <= 2'b10;
    else if(judge||FW_flag)
        m_data2 <= 1'd0;    
    else if((mode_sel != 4'b0001)&&(T_cnt == 1'd1))//占空时始终为0
        m_data2 <= 2'b10;
    else if((wave_sel != 6'b001000)&&(wave_sel != 6'b010000))//如不为psk调制，使其始终为0
        m_data2 <= 2'b10;        
    else if(cnt == STOP  - 3'd6)
        m_data2 <= {m_data2[0],m_data};
    else
        m_data2 <= m_data2;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            I_tmp <= 2'b00;
            Q_tmp <= 2'b00;
        end
    else if( judge == 1'd1)
        begin
            I_tmp <= 2'b00;
            Q_tmp <= 2'b00;
        end
    else 
        begin
             I_tmp <= (m_data2[0]) ? 2'b01 : 2'b11; 
             Q_tmp <= (m_data2[1]) ? 2'b01 : 2'b11;
        end
end


always@(posedge clk or negedge rst_n)
    if(!rst_n)
        rom_addr_qpsk <= 23'd0;
    else if(wave_sel != 6'b010000 )
        rom_addr_qpsk <= 23'd0;
    else
        if(I_tmp == 2'b01)
            case(Q_tmp)
             2'b01:rom_addr_qpsk <=  20'd1048575;//pi/4
             2'b11:rom_addr_qpsk <=  22'd3145727;//pi*3/4
             default:rom_addr_qpsk <= 23'd0;
            endcase
        else
            case(Q_tmp)
             2'b01:rom_addr_qpsk <= 23'd5242879;//pi*5/4
             2'b11:rom_addr_qpsk <= 23'd7340031;//pi*7/4
             default:rom_addr_qpsk <= 23'd0;
            endcase    


always@(posedge clk or negedge rst_n)
    if(!rst_n)
        rom_addr_bpsk <= 23'd0;
    else if(wave_sel != 6'b001000 )
         rom_addr_bpsk <= 23'd0;
    else if(m_data == 1'b1)
         rom_addr_bpsk <= 23'd0;
    else
         rom_addr_bpsk <=  22'd4194303;  //输出实部需要加上该项21'd2097151,2^23 / 2 - 1,即为pi/2
    
endmodule

