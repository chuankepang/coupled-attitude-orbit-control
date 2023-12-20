function Tw = PD(X)
global k1 k2 C Iw Ib
Q = X(1:4);
wbi = X(5:7);
Omega = X(8:11);
q = Q(2:4);
I1 = Ib*wbi+C*Iw*Omega;
Tw = -k1*q-k2*wbi+cross(wbi,I1);