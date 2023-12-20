function out = EKF(Xin)
global Q R Xest Pneg 
Qm = Xin(1:4);
wbim = Xin(5:7);
wbi = Xin(8:10);
T_sample = 0.01;
Z = [Qm;wbim-wbi];
% if(Z(1)*Xest(1)<0)
%   Z(1)=-1*Z(1);
%   Z(2)=-1*Z(2);
%   Z(3)=-1*Z(3);
%   Z(4)=-1*Z(4);
% end
q0=Xest(1);q1=Xest(2);q2=Xest(3);q3=Xest(4);
wx = wbi(1); wy = wbi(2); wz = wbi(3);
w1 = wbim(1)-Xest(5)-wbi(2)*Xest(8)-wbi(3)*Xest(9);
w2 = wbim(2)-Xest(6)-wbi(1)*Xest(10)-wbi(3)*Xest(11);
w3 = wbim(3)-Xest(7)-wbi(1)*Xest(12)-wbi(2)*Xest(13);
wg = [w1;w2;w3];
E1 = [0 0;1 0;0 1];
E2 = [1 0;0 0;0 1];
E3 = [1 0;0 1;0 0];
E = [E1 zeros(3,2) zeros(3,2);zeros(3,2) E2 zeros(3,2);zeros(3,2) zeros(3,2) E3];
Omega = [wbi' zeros(1,3) zeros(1,3);zeros(1,3) wbi' zeros(1,3);zeros(1,3) zeros(1,3) wbi'];
F = 0.5*[0 -w1 -w2 -w3 q1 q2 q3 wy*q1 wz*q1 wx*q2 wz*q2 wx*q3 wy*q3;
         w1 0 w3 -w2 -q0 q3 -q2 -wy*q0 -wz*q0 wx*q3 wz*q3 -wx*q2 -wy*q2;
         w2 -w3 0 w1 -q3 -q0 q1 -wy*q3 -wz*q3 -wx*q0 -wz*q0 wx*q1 wy*q1;
         w3 w2 -w1 0 q2 -q1 -q0 wy*q2 wz*q2 -wx*q1 -wz*q1 -wx*q0 -wy*q0];
%fxt = 0.5*[-w1(1)*q1-w1(2)*q2-w1(3)*q3;w1(1)*q0-w1(2)*q3+w1(3)*q2;w1(1)*q3+w1(2)*q0-w1(3)*q1;-w1(1)*q2+w1(2)*q1+w1(3)*q0;0;0;0];
fxt = 0.5*[Eq(Xest(1:4))*wg;zeros(9,1)];
Phi = eye(13,13)+[F;zeros(9,13)]*T_sample+0.5*[F;zeros(9,13)]*[F;zeros(9,13)]*T_sample*T_sample;
H = [eye(4) zeros(4,9);
    zeros(3,4) eye(3) Omega*E]; 
Xpre = Xest+fxt*T_sample;
Ppre = Phi*Pneg*Phi'+Q;
K = Ppre*H'*inv(H*Ppre*H'+R);
dX = K*(Z-H*Xpre);
Pneg = (eye(13)-K*H)*Ppre*(eye(13)-K*H)'+K*R*K';
Xest = Xpre+dX;

wd = Omega*E*Xest(8:13);
wbid = wbim-Xest(5:7)-wd;
Qd = Xest(1:4)./norm(Xest(1:4));
d5 = Xest(12);
out = [Qd;wbid;d5];









