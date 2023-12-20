function wi = EulerdotToOmega(X)

miu = 3.986005e14;
ae = 6378140;
wo = sqrt(miu/(ae+100000)^3);

phi = X(1);
theta = X(2);
psi = X(3);
phidot = X(4);
thetadot = X(5);
psidot = X(6);
wi = Ay(theta)*Ax(phi)*Az(psi)*[0;0;psidot]+Ay(theta)*Ax(phi)*[phidot;0;0]+Ay(theta)*[0;thetadot;0;];
%wi = wbo+Ay(theta)*Ax(phi)*Az(psi)*[0;-wo;0];
end