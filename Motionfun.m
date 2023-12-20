function Qdot = Motionfun(X)
Wbi = X(1:3);
Q = X(4:7);
q0 = Q(1);
q1 = Q(2);
q2 = Q(3);
q3 = Q(4);
M = [-q1 -q2 -q3;q0 -q3 q2;q3 q0 -q1;-q2 q1 q0];
Qdot = 0.5*M*Wbi;
end
