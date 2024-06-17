# FPGA-Project-I
Simple Radar Signal Generator Based on Low Spurious Carrier - FPGA Based Platform

A low spurious carrier generation method is used to generate four kinds of radar signals, BPSK/QPSK/LFM/NFLM, in which the parameters of the radar waveform can be adjusted (frequency, waveform, duty cycle, pulse mode, pulse time), and the results of the parameter adjustments are displayed on the digital tube.

The five parameters that can be changed are: wave_sel, mode_sel, F, T, Z.

wave_sel :Six kinds of waveforms can be selected, they are as follows.
wave_sel == 6'b000001: SIN carrier waveform

wave_sel == 6'b000010: COS carrier waveform

wave_sel == 6'b000100: LFM carrier

wave_sel == 6'b001000: BSPK carrier wave

wave_sel == 6'b010000: QPSK carrier

wave_sel == 6'b100000: NFLM carrier wave

T is the time taken by the pulse, the unit of T is 1us.

F is the waveform frequency change parameter. unit of F is 0.1MHz

Z is the duty cycle parameter.

Continuous waveform: mode_sel = 4'b0001, which can produce uninterrupted continuous waveform;

Normal pulse waveform: mode_sel = 4'b0010, which can generate normal pulse waveform;

Step Frequency Pulse: mode_sel = 4'b0100, which can generate a fixed step frequency pulse, temporarily set to four step frequency pulses, where each pulse is double the step frequency of the previous pulse, and the first pulse is the pulse signal of the frequency to be generated;

Frequency jump pulse: mode_sel = 4'b1000, which can generate a fixed frequency jump pulse, temporarily set to four step frequency pulses, where the first pulse is the pulse signal of the frequency to be generated, the second pulse is twice the frequency of the first pulse, and the third pulse is the pulse signal of the frequency to be generated.

中文：

利用一种低杂散的载波产生方式来产生BPSK/QPSK/LFM/NFLM四种雷达信号，其中实现了雷达波形的参数可调(频率，波形，占空比，脉冲模式，脉冲时间)，将参数调整后的结果显示在数码管上

其中可改变的五个参数有：wave_sel、mode_sel、F、T、Z。

wave_sel :可以进行六种波形的选择，它们分别是:
wave_sel  == 6'b000001：SIN载波

wave_sel  == 6'b000010：COS载波

wave_sel  == 6'b000100：LFM载波

wave_sel  == 6'b001000：BSPK载波

wave_sel  == 6'b010000：QPSK载波

wave_sel  == 6'b100000：NFLM载波

T为脉冲所用的时间。T的单位为1us

F为波形频率的改变参数。F的单位为0.1MHz

Z为占空比参数。

连续波：mode_sel = 4’b0001，可以产生不间断的连续波形；

普通脉冲波形：mode_sel = 4’b0010，可以产生普通的脉冲波形；

步进频率脉冲：mode_sel = 4’b0100，可以产生固定的步进频率脉冲，暂时设定为四个步进频率脉冲，其中每一个脉冲是上一个脉冲步进频率的一倍，第一个脉冲为要生成频率的脉冲信号；

频率跳变脉冲：mode_sel = 4’b1000，可以产生固定的频率跳变脉冲，暂时设定为四个步进频率脉冲，其中第一个脉冲为要生成频率的脉冲信号，第二个脉冲频率为第一个脉冲的2倍，第三个脉冲频率为第一个脉冲的两倍，第四个为第一个脉冲频率的3倍



