function Wbidot = Dynamicfun1(X)
global Ib
Tc = X(1:3);
Wbi = X(4:6);
IW = Ib*Wbi;
Wbidot = inv(Ib)*(Tc-cross(Wbi,IW));
end