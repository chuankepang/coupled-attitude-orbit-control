function Euler = QtoEuler(Q)
q0 = Q(1);
q1 = Q(2);
q2 = Q(3);
q3 = Q(4);
phi1 = asin(2*(q3*q2+q1*q0));
theta1 = atan(-2*(q1*q3-q2*q0)/(2*(q0^2+q3^2)-1));
psi1 = atan(-2*(q1*q2-q3*q0)/(2*(q0^2+q2^2)-1));
%phi = phi1*180/pi;
%theta = theta1*180/pi;
%psi = psi1*180/pi;
Euler = [phi1;theta1;psi1];
end