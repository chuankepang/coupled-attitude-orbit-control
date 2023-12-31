clear;
global miu ae wo Ixx Ixy Ixz Iyy Iyz Izz I I1  C Iw k1 k2 Ib Qini wini Xest Pneg Q R b d kp kd
miu = 3.986005e14;
ae = 6378140;
wo = sqrt(miu/(ae+100000)^3);
Ixx = 12.77;
Iyy = 133;
Izz = 133;
Ixy = -0.366;
Ixz = 0.158;
Iyz = 0.099;
I = [Ixx Ixy Ixz;Ixy Iyy Iyz;Ixz Iyz Izz];
I1 = inv(I);
%C = eye(3);
C = [1 0 0 1/3^0.5;0 1 0 1/3^0.5;0 0 1 1/3^0.5];
%C = [sin(a)*cos(b) sin(a)*sin(b) -sin(a)*cos(b) -sin(a)*sin(b);cos(a) cos(a) cos(a) cos(a);-sin(a)*sin(b) sin(a)*cos(b) sin(a)*sin(b) -sin(a)*cos(b)];
Iw = 4.113*10^-4;
k1 = 5;
k2 = 200;
Ib = [Ixx Ixy Ixz;Ixy Iyy Iyz;Ixz Iyz Izz];
phi = 10*pi/180;theta = 5*pi/180;psi = 8*pi/180;
q0 = cos(theta/2)*cos(phi/2)*cos(psi/2)-sin(theta/2)*sin(phi/2)*sin(psi/2);
q1 = cos(theta/2)*sin(phi/2)*cos(psi/2)-sin(theta/2)*cos(phi/2)*sin(psi/2);
q2 = sin(theta/2)*cos(phi/2)*cos(psi/2)+cos(theta/2)*sin(phi/2)*sin(psi/2);
q3 = sin(theta/2)*sin(phi/2)*cos(psi/2)+cos(theta/2)*cos(phi/2)*sin(psi/2);
Qini = [q0;q1;q2;q3];
wini = [0.2*pi/180;0.2*pi/180;0.2*pi/180];
b = 0.007*pi/180;
%d = [8;-14;10;-12;14;-10]*pi/648000;
d = [0.01;-0.01;0.02;-0.015;0.015;-0.02];
Xest = [1;0;0;0;0;0;0;0.01;-0.01;0.019;-0.014;0.014;-0.019];
Pneg = diag([1e-4 1e-4 1e-4 1e-4 1e-7 1e-7 1e-7 0 0 0 0 0 0]);
Q = diag([0.000012^2 0.000012^2 0.000012^2 0.000012^2 0.00002^2 0.00002^2 0.00002^2 0.000001^2 0.000001^2 0.000001^2 0.000001^2 0.000001^2 0.000001^2]);
R = diag([0.000012^2 0.000012^2 0.000012^2 0.000012^2 (0.0001*pi/180)^2 (0.0001*pi/180)^2 (0.0001*pi/180)^2]);
kp = diag([182.4 400 324.16]);
kd = diag([319.2 700 567.28]);