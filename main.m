clear all;
close all;
clc


addpath('igrf');
addpath('KF');
addpath('orbit');
addpath('sensor');
addpath('KF');
addpath('transform_matrix');

load topo;% ������ʹ��

global body  orbit  filter  nom  gain
% nom-> ���ڿ��Ƶ��������
global measure      %�ͺ�����������صĽṹ��
global simflag  dt  deltaT B_s_out

%% ���ڳ�ʼ��
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
filter.T= 0.25; % �������˲�����ʱ��(��)
deltaT = 0.25;     % ��������  0.25 s
dt = deltaT*1;  % t_step:���沽��
deg_rad = pi/180;   % angle constant, from deg to rad
km_m = 1000;                          % distance constant, from km to m 
rpm_radps = 2*pi/60; % rpm��rad/s��ת��
% simflag ��ʾ����ģʽ�ͷ���ģʽ�ı�־λ
filter.case=1;    % �������˲���ѡ�� 
simflag.RW = 0;
% 0-�����Σ�2-̫������3-����Ѳ����4-��̬������5-�Ե��ȶ���9-�Ե�����,12-ͣ��
simflag.WorkMode = 1;   % ����ģʽ��־λ, 
simflag.cnum = 1; 

% parameters of the Earth-------gravitational constant (km**3/sec**2)
mu = 398600.436233e9;            % �������������
req = 6378137;                 % earth mean equatorial radius 
fE = 1/298.257223563;   % �������
wE = 7.292116e-5;   % ������ת���ٶ�ʸ��, unit: rad/s

%-----------------------�����ʼ������--------------------------------%
vec_qBI0 = [-0.4;0.2;-0.4];
sc_qBI0 = sqrt(1 - vec_qBI0'*vec_qBI0);
qBI0 = [sc_qBI0; vec_qBI0];

% wBI_B0 = [0.001; 0.002; -0.001];
wBI_B0 = [5; 6; -5]*pi/180; % ģ�����߼��л�ʹ��
% wBI_B0 = [1.2; 1.5; -1.2]*pi/180; % ģ�����߼��л�ʹ��
% wBI_B0 = [0.026; 0.026; 0.026]; % ģ�ɲ�����
% wBI_B0 = [10; 10; 10]*pi/180;  % �����������
%  wBI_B0 = [0.2; -0.2; 0.3]*pi/180;  % ���Ӳ�����
% wBI_B0 = [1.2; -1.2; -1.4]*pi/180;  % �����������
% Omg_RW0 = [1500; 1500; 1500; -1500]*rpm_radps;  % ���ת��
Omg_RW_initial = [0; 0; 0; 0]*rpm_radps;  % ��ʼת��
Q0= qBI0;     %  �����˲�����ʼ��
% [0.8;0.4;-0.2;-0.4];  

%---------------���ǵ���ʵ��������--------------%
% ����չ��״̬����
% body.Ix = 0.2167;
% body.Iy = 0.2;
% body.Iz = 0.1265;
% body.Jb = [body.Ix   0.006     -0.04
%            0.006     body.Iy   0.04
%            -0.04     0.04      body.Iz];
%        
%�������

 body.Jb = [0.10998334449  0.00002054857  -0.00057230704;
            0.00002054857  0.11020065834  -0.00152664144;
           -0.00057230704 -0.00152664144   0.07891517948;];
       
% �����ս�״̬����
% body.Ix = 3.3*1.2;
% body.Iy = 6.7*1.2;
% body.Iz = 8.1*1.2;
% body.Jb = [body.Ix   0.3       -0.2
%            0.3       body.Iy   0.1
%            -0.2      0.1       body.Iz];
       
body.Jb_inv = inv(body.Jb);
% �������ת��7800 rpm�����Ƕ���0.34 
body.Iw = 2.387e-5;   % kg.m^2
body.Iw_test = 1.089e-5;
body.Jw = diag([body.Iw, body.Iw, body.Iw, body.Iw_test]);
body.resm = [0.05; 0.05; 0.05];   % ���ǵ�ʣ��ž� residual moment��unit: Am^2
% ���ֵİ�װ����,������+һбװ��������
alpha = 54.74*deg_rad;
body.Cw = [ -1,   0,   0,  1/sqrt(3);
	         0,  -1,   0,  1/sqrt(3);
	         0,   0,   1,  1/sqrt(3)];
%---------------���ǵ������������--------------% 
% % nom.Jb = body.Jb;
% nom.Jb = diag([3.58, 4.4, 6.4]);
% nom.Jw = body.Jw;
% nom.Hw0 = nom.Jw*Omg_RW0;
% nom.Cw = [cos(angle_rw1 + 0*deg_rad), cos(angle_rw2+ 0*deg_rad), cos(angle_rw3+ 0*deg_rad), -cos(angle_rw4+ 0*deg_rad)];
% % nom.Cw = body.Cw;
% nom.STLmat = nom.Cw'/(nom.Cw*nom.Cw');  % steering law matrix

%-----------------------------------------------%
%����Ϊ����ת��-�������Բ��������ֶ�̬ģ��ʹ�ã�20180405�����)�����ֶ�̬ģ���Ϊģ��������ԣ������в�����
%-------------------�������ת��-------------------------------%
max_wspeed = 4500*rpm_radps; %���ת������ת���޷���unit: rad/s��Ϊ������ֵ�������Ǽ��ٶ�����ٶȲ�ƥ�䣬���ｫ�޷�ת������С��

%-------------�����޷����Բ�����20180405,���룬����ģ����������޷���--------%


body.MagBar_Install2body=[ -1  0  0;
                            0  1  0;
                            0  0 -1;];
%����������װ�󵽱���ϵ��ת������


%-------------���Ҫ�س�ʼ����---------------%
W0 = 0.00109723094722768;
% orbit.i=97.63*pi/180;%%������1
% orbit.ac=6918000;           %%�볤��2
% orbit.e=0.00000;            %%ƫ����3
% orbit.RAANc=338.038*pi/180;%%������ྭ4
% orbit.omgc=0*pi/180;%%���ص����5
% orbit.omg0=180*pi/180;%%γ�ȷ���6
% orbit.time=[2018;10;4;2;30;0];%��ʼʱ��
% body.w0=[0;-W0;0];

 orbit.i = 97.6249 * pi/180;%%������1
 orbit.ac = 6925620;           %%�볤��2
 orbit.e = 0.000344;            %%ƫ����3
 orbit.RAANc = 41.6336 * pi/180;%%������ྭ4
 orbit.omgc = 195.01 * pi/180;%%���ص����5
 orbit.omg0 = 172.653 * pi/180;%%γ�ȷ���6
 orbit.time = [2018;12;7;4;24;38];%��ʼʱ��
 body.w0=[0;-W0;0];

% �����ʼʱ�����ǵ����µ�λ�ã���Ϊ���ó�ʼʱ��Ŀ���λ�õĲο�����������̫Զ
vec_orb0 = ProduceOrbit_13(0);
vec_orb0(10),vec_orb0(11)     % ���µ�Ĵ�ؾ��Ⱥ͵���γ��
target_GDlong = 102.55*deg_rad;  % Ŀ���ĵ�����
target_GDlat = -25.107*deg_rad;    % Ŀ���ĵ���γ��

% target_GDlong = 293.12*deg_rad;  % Ŀ���ĵ�����
% target_GDlat = -59.787*deg_rad;    % Ŀ���ĵ���γ��
GClat_target = atan((1 - fE)^2*tan(target_GDlat));   % Ŀ���ĵ���γ��, GClat_target = GDlat_target + fE*sin(2*GDlat_target); 
nm_rTI = req*(1 - fE)/sqrt(1 - fE*(2 - fE)*(cos(GClat_target))^2 );
SPP = [target_GDlong; target_GDlat];  % staring point position, SPP
rTI_E = nm_rTI*[cos(GClat_target)*cos(target_GDlong); cos(GClat_target)*sin(target_GDlong); sin(GClat_target)];
% geod2ecef(45, 310, 0) - rTI_E'
% �����ʼʱ��̫��λ��ʸ��,��̫��ָ����ơ���̬ȷ���ж��õ�����ʱ���ڿ��Կ����㶨�ģ�����ʹ����Ҫ���ڸ���
rso_I0 = SunPosition(orbit.time(1), orbit.time(2), orbit.time(3), orbit.time(4), orbit.time(5), orbit.time(6)+0);
Euler312_target = [0; 0; 0];
AG0 = fun_GL(orbit.time(1), orbit.time(2), orbit.time(3), orbit.time(4), orbit.time(5), orbit.time(6), 0);

% %  �˲�����������
% angle0=QToAngle(Q0);
% % angle0=[-10;14;20]*pi/180;
% omgeia0=[0;-0.001;0];
% Tr=[0;0;0];
% % Control.dely1=200;
% % Control.dely2=500;

%-------------�ų�����-----------%
orbit.magnetic=datenum(2018,10,4,2,30,0);

%% 

%%-------------------��������---------------%%
measure.earth=67*pi/180;%�����ӳ���
%----1�����������������ٶȣ�---------------%
measure.Flag_star1=1;
measure.star1_gyro=1.5*pi/180;
measure.star1_field=25*pi/180;%�ӹ����ƽ�
measure.star1_erfa=(20/3600)*pi/180;  %һ��������������ƫ��,10''precise0.003��
measure.star1_beta=(100/3600)*pi/180;  %һ��������������ƫ��,10''precise0.003��
measure.CStar1tob=[ -1        0          0
	                 0    0.258819     0.965925826
	                 0    0.9659258   -0.258819045];

measure.Star1_e=(pi/180)*[20;30;25]/3600;   %һ����������ƫ��,30''BtoB����


%-----------1������---------------%
measure.Flag_gyro1=1;
measure.C_gyrotob1=[     0    0   -1
                         0   -1    0
                        -1    0    0 ];%1�����ݰ�װ�󵽱���
%measure.C_gyrotob1=eye(3);%1�����ݰ�װ�󵽱���
measure.gyro1_e=(pi/180)*[0.6;-0.4;0.5];%һ����������ƫ��,30''BtoB����
measure.gyron1=1*(0.001*pi/180);%��������
measure.gyrob1=1*0.007*pi/180*1;%����Ư��


%-------��ǿ��--------------%
measure.Flag_B=1;
measure.mu=50;%��ǿ�Ʋ�������
measure.C_Mutob=[  -1    0    0
                    0   -1    0
                    0    0    1];%
measure.Mu_e=1*(pi/180)*[-0.1;0.2;0.1];%��ǿ�ư�װƫ��
%-------1��̫��������--------------%
measure.sun1_field = 60*pi/180;%̫��1�ӳ���
measure.Flag_sun1=1;
measure.sun1=5*1e-3;%̫����������
measure.C_sunb1=[ 0,  -1,   0
                  1,   0,   0
                  0,   0,   1 ]; %2��̫����װ�󵽱���
% measure.C_sunb1=[ -1,  0,   0
%                   0,  0,  1
%                   0,  1,   0 ]; %2��̫����װ�󵽱���              
measure.Sun1_e=1*(pi/180)*[-25;32;21]/3600;%̫��1��װƫ��

%-------2��̫��������--------------%
measure.sun2_field = 60*pi/180;%̫��1�ӳ���
measure.Flag_sun2 = 1;
measure.sun2=5*1e-3;%̫����������
measure.C_sunb2=[  0,	1,	 0
                  -1,	0,   0
                   0,   0,	 1 ]; %1��̫����װ�󵽱���
% measure.C_sunb2=[ 1,	0,	 0
%                   0,	0,   -1
%                    0,   1,	 0 ]; %1��̫����װ�󵽱���
              
measure.Sun2_e=1*(pi/180)*[-25;32;21]/3600;%̫��2��װƫ��

% measure.C_sunb2(1:3,3)' * measure.C_sunb1(1:3,3);
%---------------ǿ���л���������----------------%
measure.Flag_AD=0;

%% 

% %------------�������˲�����--------------------%
% % filter.b=[1;1;1]*0.007*pi/180;%����Ư��
% 
% %�������˲���ѡ��
%  %filter.lastQ=[1;0;0;0];
% filter.lastQ=Q0;
% filter.X=[filter.lastQ;0;0;0];%��ʼ״̬
% hatX0 = [filter.X; Omg_RW0];   %  ����memory�ĳ�ʼֵ�趨
% filter.P=diag([1,1,1,1,1e-6,1e-6,1e-6]);%��ʼЭ����
% %------------�������˲�����1(����������)--------------------%
filter.Q1=1e-13*diag([100,100,100,100,1,1,1]);%QΪiά�Խ���,״̬���̷���
filter.R1=1e-9*eye(4);%RΪj�Խ��󣬹۲ⷽ�̷���
% %------------�������˲�����2(û������)--------------------%
% filter.Q2=1*1e-14*diag([100,100,100,100,1,1,1]);%QΪiά�Խ���,״̬���̷���
% filter.R2=1*1e-8*eye(4);%RΪj�Խ��󣬹۲ⷽ�̷���
% 
% %------------�������˲�����3(��ʸ��+����)--------------------%
% filter.Q3=1*1e-14*diag([100,100,100,100,1,1,1]);%QΪiά�Խ���,״̬���̷���
% filter.R3=0.25*1e-6*eye(3);%RΪj�Խ��󣬹۲ⷽ�̷���



%% ��ʼ�����֪ͨ

h=dialog('name',' ','position',[200 200 200 70]);  
uicontrol('parent',h,'style','text','string','��ʼ����ɣ�','position',[50 40 120 20],'fontsize',12);  
uicontrol('parent',h,'style','pushbutton','position', [80 10 50 20],'string','ȷ��','callback','delete(gcbf)');  