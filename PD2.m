function Tw = PD2(X)
global Ib kp kd
Qe = X(1:4);
wbi = X(5:7);
we = X(8:10);
wdi = X(11:13);
wdidot = X(14:16);
qe = Qe(2:4);
qe0 = Qe(1);
I = Ib*wbi;

Abd = (qe0^2-qe'*qe)*eye(3)+2*(qe*qe')-2*qe0*crossfun(qe);
Tw = -kp*qe-kd*we+cross(wbi,I)+Ib*(-crossfun(we)*Abd*wdi+Abd*wdidot);
end