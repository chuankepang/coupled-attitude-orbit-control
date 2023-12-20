clear all;
close all;
clc


addpath('igrf');
addpath('KF');
addpath('orbit');
addpath('sensor');
addpath('KF');
addpath('transform_matrix');

load topo;% 画地球使用

global body  orbit  filter  nom  gain
% nom-> 用于控制的名义参数
global measure      %和航天器本体相关的结构体
global simflag  dt  deltaT B_s_out

%% 串口初始化
newobjs = instrfind;
delete(newobjs);
global s
load('serial.mat');
s = s_com4;
if strcmp(s.status, 'closed')
    fopen(s);
    s.Timeout = 1000;
end
newobjs = instrfind

B_s_out = [0; 0; 0];
% newobjs = instrfind
% delete(newobjs);
% newobjs = instrfind
% s = serial('COM4', 'BaudRate', 115200);
% fopen(s);
%% 

global tsim
tsim = 30000;    %  simulation time span
filter.T= 0.25; % 卡尔曼滤波采样时间(秒)
deltaT = 0.25;     % 控制周期  0.25 s
dt = deltaT*1;  % t_step:仿真步长
deg_rad = pi/180;   % angle constant, from deg to rad
km_m = 1000;                          % distance constant, from km to m 
rpm_radps = 2*pi/60; % rpm到rad/s的转换
% simflag 表示控制模式和仿真模式的标志位
filter.case=1;    % 卡尔曼滤波器选择 
simflag.RW = 0;
% 0-主动段，2-太阳捕获，3-对日巡航，4-姿态机动，5-对地稳定，9-对地凝视,12-停控
simflag.WorkMode = 1;   % 工作模式标志位, 
simflag.cnum = 1; 

% parameters of the Earth-------gravitational constant (km**3/sec**2)
mu = 398600.436233e9;            % 地球的引力常数
req = 6378137;                 % earth mean equatorial radius 
fE = 1/298.257223563;   % 地球扁率
wE = 7.292116e-5;   % 地球自转角速度矢量, unit: rad/s

%-----------------------仿真初始化参数--------------------------------%
vec_qBI0 = [-0.4;0.2;-0.4];
sc_qBI0 = sqrt(1 - vec_qBI0'*vec_qBI0);
qBI0 = [sc_qBI0; vec_qBI0];

% wBI_B0 = [0.001; 0.002; -0.001];
wBI_B0 = [5; 6; -5]*pi/180; % 模拟多个逻辑切换使用
% wBI_B0 = [1.2; 1.5; -1.2]*pi/180; % 模拟多个逻辑切换使用
% wBI_B0 = [0.026; 0.026; 0.026]; % 模飞测试用
% wBI_B0 = [10; 10; 10]*pi/180;  % 磁阻尼测试用
%  wBI_B0 = [0.2; -0.2; 0.3]*pi/180;  % 凝视测试用
% wBI_B0 = [1.2; -1.2; -1.4]*pi/180;  % 轮阻尼测试用
% Omg_RW0 = [1500; 1500; 1500; -1500]*rpm_radps;  % 标称转速
Omg_RW_initial = [0; 0; 0; 0]*rpm_radps;  % 初始转速
Q0= qBI0;     %  用于滤波器初始化
% [0.8;0.4;-0.2;-0.4];  

%---------------卫星的真实基本参数--------------%
% 整星展开状态惯量
% body.Ix = 0.2167;
% body.Iy = 0.2;
% body.Iz = 0.1265;
% body.Jb = [body.Ix   0.006     -0.04
%            0.006     body.Iy   0.04
%            -0.04     0.04      body.Iz];
%        
%名义惯量

 body.Jb = [0.10998334449  0.00002054857  -0.00057230704;
            0.00002054857  0.11020065834  -0.00152664144;
           -0.00057230704 -0.00152664144   0.07891517948;];
       
% 整星收紧状态惯量
% body.Ix = 3.3*1.2;
% body.Iy = 6.7*1.2;
% body.Iz = 8.1*1.2;
% body.Jb = [body.Ix   0.3       -0.2
%            0.3       body.Iy   0.1
%            -0.2      0.1       body.Iz];
       
body.Jb_inv = inv(body.Jb);
% 飞轮最大转速7800 rpm，最大角动量0.34 
body.Iw = 2.387e-5;   % kg.m^2
body.Iw_test = 1.089e-5;
body.Jw = diag([body.Iw, body.Iw, body.Iw, body.Iw_test]);
body.resm = [0.05; 0.05; 0.05];   % 卫星的剩余磁矩 residual moment，unit: Am^2
% 飞轮的安装矩阵,三正交+一斜装（正常）
alpha = 54.74*deg_rad;
body.Cw = [ -1,   0,   0,  1/sqrt(3);
	         0,  -1,   0,  1/sqrt(3);
	         0,   0,   1,  1/sqrt(3)];
%---------------卫星的名义基本参数--------------% 
% % nom.Jb = body.Jb;
% nom.Jb = diag([3.58, 4.4, 6.4]);
% nom.Jw = body.Jw;
% nom.Hw0 = nom.Jw*Omg_RW0;
% nom.Cw = [cos(angle_rw1 + 0*deg_rad), cos(angle_rw2+ 0*deg_rad), cos(angle_rw3+ 0*deg_rad), -cos(angle_rw4+ 0*deg_rad)];
% % nom.Cw = body.Cw;
% nom.STLmat = nom.Cw'/(nom.Cw*nom.Cw');  % steering law matrix

%-----------------------------------------------%
%以下为飞轮转速-力矩特性参数，飞轮动态模拟使用（20180405日添加)。飞轮动态模拟仅为模拟飞轮特性，控制中不出现
%-------------------飞轮最大转速-------------------------------%
max_wspeed = 4500*rpm_radps; %最大转速用于转速限幅，unit: rad/s。为避免数值误差引起角加速度与角速度不匹配，这里将限幅转速略缩小。

%-------------飞轮限幅特性参数（20180405,加入，用于模拟飞轮力矩限幅）--------%


body.MagBar_Install2body=[ -1  0  0;
                            0  1  0;
                            0  0 -1;];
%磁力矩器安装阵到本体系的转换矩阵


%-------------轨道要素初始参数---------------%
W0 = 0.00109723094722768;
% orbit.i=97.63*pi/180;%%轨道倾角1
% orbit.ac=6918000;           %%半长轴2
% orbit.e=0.00000;            %%偏心率3
% orbit.RAANc=338.038*pi/180;%%升交点赤经4
% orbit.omgc=0*pi/180;%%近地点幅角5
% orbit.omg0=180*pi/180;%%纬度幅角6
% orbit.time=[2018;10;4;2;30;0];%初始时刻
% body.w0=[0;-W0;0];

 orbit.i = 97.6249 * pi/180;%%轨道倾角1
 orbit.ac = 6925620;           %%半长轴2
 orbit.e = 0.000344;            %%偏心率3
 orbit.RAANc = 41.6336 * pi/180;%%升交点赤经4
 orbit.omgc = 195.01 * pi/180;%%近地点幅角5
 orbit.omg0 = 172.653 * pi/180;%%纬度幅角6
 orbit.time = [2018;12;7;4;24;38];%初始时刻
 body.w0=[0;-W0;0];

% 输出初始时刻卫星的星下点位置，作为设置初始时刻目标点位置的参考：两者相差不能太远
vec_orb0 = ProduceOrbit_13(0);
vec_orb0(10),vec_orb0(11)     % 星下点的大地经度和地理纬度
target_GDlong = 102.55*deg_rad;  % 目标点的地理经度
target_GDlat = -25.107*deg_rad;    % 目标点的地理纬度

% target_GDlong = 293.12*deg_rad;  % 目标点的地理经度
% target_GDlat = -59.787*deg_rad;    % 目标点的地理纬度
GClat_target = atan((1 - fE)^2*tan(target_GDlat));   % 目标点的地心纬度, GClat_target = GDlat_target + fE*sin(2*GDlat_target); 
nm_rTI = req*(1 - fE)/sqrt(1 - fE*(2 - fE)*(cos(GClat_target))^2 );
SPP = [target_GDlong; target_GDlat];  % staring point position, SPP
rTI_E = nm_rTI*[cos(GClat_target)*cos(target_GDlong); cos(GClat_target)*sin(target_GDlong); sin(GClat_target)];
% geod2ecef(45, 310, 0) - rTI_E'
% 输出初始时刻太阳位置矢量,在太阳指向控制、姿态确定中都用到，短时间内可以看作恒定的，长期使用需要定期更新
rso_I0 = SunPosition(orbit.time(1), orbit.time(2), orbit.time(3), orbit.time(4), orbit.time(5), orbit.time(6)+0);
Euler312_target = [0; 0; 0];
AG0 = fun_GL(orbit.time(1), orbit.time(2), orbit.time(3), orbit.time(4), orbit.time(5), orbit.time(6), 0);

% %  滤波程序保留部分
% angle0=QToAngle(Q0);
% % angle0=[-10;14;20]*pi/180;
% omgeia0=[0;-0.001;0];
% Tr=[0;0;0];
% % Control.dely1=200;
% % Control.dely2=500;

%-------------磁场参数-----------%
orbit.magnetic=datenum(2018,10,4,2,30,0);

%% 

%%-------------------测量参数---------------%%
measure.earth=67*pi/180;%地球视场角
%----1号星敏参数（带角速度）---------------%
measure.Flag_star1=1;
measure.star1_gyro=1.5*pi/180;
measure.star1_field=25*pi/180;%杂光抑制角
measure.star1_erfa=(20/3600)*pi/180;  %一号星敏测量光轴偏差,10''precise0.003°
measure.star1_beta=(100/3600)*pi/180;  %一号星敏测量切向偏差,10''precise0.003°
measure.CStar1tob=[ -1        0          0
	                 0    0.258819     0.965925826
	                 0    0.9659258   -0.258819045];

measure.Star1_e=(pi/180)*[20;30;25]/3600;   %一号星敏测量偏差,30''BtoB估计


%-----------1号陀螺---------------%
measure.Flag_gyro1=1;
measure.C_gyrotob1=[     0    0   -1
                         0   -1    0
                        -1    0    0 ];%1号陀螺安装阵到本体
%measure.C_gyrotob1=eye(3);%1号陀螺安装阵到本体
measure.gyro1_e=(pi/180)*[0.6;-0.4;0.5];%一号星敏测量偏差,30''BtoB估计
measure.gyron1=1*(0.001*pi/180);%陀螺噪声
measure.gyrob1=1*0.007*pi/180*1;%陀螺漂移


%-------磁强计--------------%
measure.Flag_B=1;
measure.mu=50;%磁强计测量精度
measure.C_Mutob=[  -1    0    0
                    0   -1    0
                    0    0    1];%
measure.Mu_e=1*(pi/180)*[-0.1;0.2;0.1];%磁强计安装偏差
%-------1号太阳敏感器--------------%
measure.sun1_field = 60*pi/180;%太敏1视场角
measure.Flag_sun1=1;
measure.sun1=5*1e-3;%太敏测量精度
measure.C_sunb1=[ 0,  -1,   0
                  1,   0,   0
                  0,   0,   1 ]; %2号太敏安装阵到本体
% measure.C_sunb1=[ -1,  0,   0
%                   0,  0,  1
%                   0,  1,   0 ]; %2号太敏安装阵到本体              
measure.Sun1_e=1*(pi/180)*[-25;32;21]/3600;%太敏1安装偏差

%-------2号太阳敏感器--------------%
measure.sun2_field = 60*pi/180;%太敏1视场角
measure.Flag_sun2 = 1;
measure.sun2=5*1e-3;%太敏测量精度
measure.C_sunb2=[  0,	1,	 0
                  -1,	0,   0
                   0,   0,	 1 ]; %1号太敏安装阵到本体
% measure.C_sunb2=[ 1,	0,	 0
%                   0,	0,   -1
%                    0,   1,	 0 ]; %1号太敏安装阵到本体
              
measure.Sun2_e=1*(pi/180)*[-25;32;21]/3600;%太敏2安装偏差

% measure.C_sunb2(1:3,3)' * measure.C_sunb1(1:3,3);
%---------------强制切换测量方案----------------%
measure.Flag_AD=0;

%% 

% %------------卡尔曼滤波参数--------------------%
% % filter.b=[1;1;1]*0.007*pi/180;%陀螺漂移
% 
% %卡尔曼滤波器选择
%  %filter.lastQ=[1;0;0;0];
% filter.lastQ=Q0;
% filter.X=[filter.lastQ;0;0;0];%初始状态
% hatX0 = [filter.X; Omg_RW0];   %  用于memory的初始值设定
% filter.P=diag([1,1,1,1,1e-6,1e-6,1e-6]);%初始协方差
% %------------卡尔曼滤波参数1(完整敏感器)--------------------%
filter.Q1=1e-13*diag([100,100,100,100,1,1,1]);%Q为i维对角阵,状态方程方差
filter.R1=1e-9*eye(4);%R为j对角阵，观测方程方差
% %------------卡尔曼滤波参数2(没有陀螺)--------------------%
% filter.Q2=1*1e-14*diag([100,100,100,100,1,1,1]);%Q为i维对角阵,状态方程方差
% filter.R2=1*1e-8*eye(4);%R为j对角阵，观测方程方差
% 
% %------------卡尔曼滤波参数3(单矢量+陀螺)--------------------%
% filter.Q3=1*1e-14*diag([100,100,100,100,1,1,1]);%Q为i维对角阵,状态方程方差
% filter.R3=0.25*1e-6*eye(3);%R为j对角阵，观测方程方差



%% 初始化完成通知

h=dialog('name',' ','position',[200 200 200 70]);  
uicontrol('parent',h,'style','text','string','初始化完成！','position',[50 40 120 20],'fontsize',12);  
uicontrol('parent',h,'style','pushbutton','position', [80 10 50 20],'string','确定','callback','delete(gcbf)');  