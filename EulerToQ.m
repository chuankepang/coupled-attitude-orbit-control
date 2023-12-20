function Q = EulerToQ(X)

phi = X(1);
theta = X(2);
psi = X(3);
q0 = cos(theta/2)*cos(phi/2)*cos(psi/2)-sin(theta/2)*sin(phi/2)*sin(psi/2);
q1 = cos(theta/2)*sin(phi/2)*cos(psi/2)-sin(theta/2)*cos(phi/2)*sin(psi/2);
q2 = sin(theta/2)*cos(phi/2)*cos(psi/2)+cos(theta/2)*sin(phi/2)*sin(psi/2);
q3 = sin(theta/2)*sin(phi/2)*cos(psi/2)+cos(theta/2)*cos(phi/2)*sin(psi/2);
Q = [q0;q1;q2;q3];
end