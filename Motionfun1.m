function Eulerdot = Motionfun(X)
global wo
Wbi = X(1:3);
Euler = X(4:6);
phi = Euler(1);
theta = Euler(2);
psi = Euler(3);
Wbo = Wbi-Ay(theta)*Ax(phi)*Az(psi)*[0;-wo;0];
M = [cos(theta) 0 sin(theta);tan(phi)*sin(theta) 1 -tan(phi)*cos(theta);-sin(theta)/cos(phi) 0 cos(theta)/cos(phi)];
Eulerdot = M*Wbo;
end
