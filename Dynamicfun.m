function Wbidot = Dynamicfun(X)
global I Iw C
Tc = X(1:3);
Wbi = X(4:6);
Omega = X(7:10);
It = I+C*Iw*C';
IW = It*Wbi+C*Iw*Omega;
Wbidot = inv(It)*(Tc-cross(Wbi,IW));
end