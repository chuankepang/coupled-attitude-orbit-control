function out = measure(X)
global b d
Q = X(1:4);
wbi = X(5:7);
t = X(8);
m = 0.000012;
M = m*eye(4);
%M = sqrt(m)*eye(4);
r = 0.0001*pi/180;
%R = sqrt(r)*eye(3);
R = r*eye(3);
rand1 = [randn;randn;randn;randn];rand2 = [randn;randn;randn];
ns = M*rand1;
nb = R*rand2;
Qm1 = Q+ns;
Qm = Qm1./(norm(Qm1));
E1 = [0 0;1 0;0 1];
E2 = [1 0;0 0;0 1];
E3 = [1 0;0 1;0 0];
E = [E1 zeros(3,2) zeros(3,2);zeros(3,2) E2 zeros(3,2);zeros(3,2) zeros(3,2) E3];
Omega = [wbi' zeros(1,3) zeros(1,3);zeros(1,3) wbi' zeros(1,3);zeros(1,3) zeros(1,3) wbi'];
d1 = d+0*sin(t)*[0.005;0.005;0.005;0.005;0.005;0.005];
wd = Omega*E*d1;
wbim = wbi+nb+b+wd;
out = [Qm;wbim];