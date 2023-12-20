function Omegadot = steer(X)
global C Iw
Tw = X;
Cw = C*Iw;
Omegadot = -Cw'*inv(Cw*Cw')*Tw;