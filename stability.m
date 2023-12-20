D = [sqrt(2) 0 0 0 0 0;0 0 0 0 0 0;0 0 sqrt(2) 0 0 0;0 0 0 0 0 0;0 0 0 0 sqrt(2) 0 ;0 0 0 0 0 0];
global  wo Ixx Iyy Izz
a1 = (Izz-Iyy)*wo^2/Ixx;
a2 = (Ixx+Izz-Iyy)*wo/Ixx;
a3 = (Iyy-Ixx-Izz)*wo/Izz;
a4 = (Ixx-Iyy)*wo^2/Izz;
b1 = 1/Ixx;
b2 = 1/Iyy;
b3 = 1/Izz;
A = [0 1 0 0 0 0;a1 0 0 0 0 a2;0 0 0 1 0 0;0 0 0 0 0 0;0 0 0 0 0 1;0 a3 0 0 a4 0];
B = [0 0 0;b1 0 0;0 0 0;0 b2 0;0 0 0;0 0 b3];
V = ctrb(A,B);
r1 = rank(V);
N = obsv(A,D);
r2 = rank(N);
