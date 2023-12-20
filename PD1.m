function Tw = PD1(X)
global k1 k2 Ib
Q = X(1:4);
wbi = X(5:7);
q = Q(2:4);
I1 = Ib*wbi;
Tw = -k1*q-k2*wbi+cross(wbi,I1);