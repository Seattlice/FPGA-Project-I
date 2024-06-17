%% Cardarilli
%% 清理工作区
clc;            %清除命令行
clear all;      %清楚工作区变量，释放空间

%% ROM表
%% 数据参数

F2= 1e8;           %信号频率
T4 = 1/(F2);   %周期的时间
N=2^12;         %累加器位数/采样点数
t = linspace(0, T4, N);%在2pi中的前二分之pi中生成四分之一个rom单位用来存储波形数据
T = 2 ^ 13;%仿真的实践

%% 参数设置

fre_weishu = 32; %累加器位数
fre_add = 0;
romaddr_reg = 0;
dac_data = 0;
jieduan = 14; %截断位数
P_jieduan =9;%小数部分截断
lfm_fre = 0;
fuhao = 1;

Fc =1e8;
f0 = 5e5;

F_WORD = round(f0*2^fre_weishu/Fc);
% F_WORD = 429219;
P_WORD = 0;


%% ROM表格的生成
A = 2^22;
ADC = A - 1; 
N = 18;
for j = 1 : 2^(N/2-1) 
        i = j - 1;
    sina(j) = round(A * sin((2*i*pi+pi)/(2^(N/2 + 1))));
    %cosa(j) = sina(j);
    sinb(j) = round(A/2 *  sin((2*i*pi )/(2^N) - pi/2^(N/2 + 1)));      %丢弃了一位符号位
    cosb(j) = round(A/2 * (1 - cos((2*i*pi)/(2^N) - pi/2^(N/2 + 1)))) ;

end

%选择粗细表
s1 = sina;   %sin_corse256x22
s2 = sinb;  %sin_fine256x14
s3 = cosb;  %cos_fine256x4

% fild = fopen("sin_fine256x22.coe","wt");
% fild = fopen("sin_corse256x14.coe","wt");
fild = fopen("cos_corse256x4.coe","wt");

%写入coe文件头
fprintf(fild,"%s\n","MEMORY_INITIALIZATION_RADIX=10;"); %10进制数
fprintf(fild,"%s\n","MEMORY_INITIALIZATION_VECTOR=");
for i = 1:2^(N/2-1) 
    s0(i) = round(s3(i));   %四舍五入取整数
%         if  s0(i)<0          %负数强制变成0，范围在0-255
%             s0(i) = 0;
%         end
        if i == 2^(N/2-1) 
            fprintf(fild,"%d",s0(i)); %数据写入
             fprintf(fild,"%s",";"); %最后一个数据使用分号
        else
            fprintf(fild,"%d",s0(i)); %数据写入
             fprintf(fild,"%s\n",","); %最后一个数据使用分号
        end

end
fclose(fild);
plot(s0);
