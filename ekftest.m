clear;
q1 = 0.01;q2 = 0.1;Q = diag([q1,q2]);
r1 = 1;r2 = 0.1;R = diag([r1,r2]);
N = 500;
xr(:,1) = [1.5;1.5]+[q1^0.5*randn;q2^0.5*randn];
for k = 2:N
    xr(:,k) = [sin(xr(1,k-1))*xr(2,k-1)+0.1*(k-1);cos(xr(2,k-1))^2+xr(1,k-1)-0.1*(k-1)]+[q1^0.5*randn;q2^0.5*randn];
    zr(:,k) = [sqrt(xr(1,k)^2+xr(2,k)^2);atan(xr(1,k)/xr(2,k))]+[r1^0.5*randn;r2^0.5*randn];
end
xe(:,1) = [1;1];
Ppos = 10*eye(2);
Ppre(:,1) = diag(Ppos);
Pest(:,1) = diag(Ppos);
for k = 2:N
    x(:,k) = [sin(xe(1,k-1))*xe(2,k-1)+0.1*(k-1);cos(xe(2,k-1))^2+xe(1,k-1)-0.1*(k-1)];
    F = [xe(2,k-1)*cos(xe(1,k-1)) sin(xe(1,k-1));1 -sin(2*xe(2,k-1))];
    Pneg = F*Ppos*F'+Q;
    H = [x(1,k)/sqrt(x(1,k)^2+x(2,k)^2) x(2,k)/sqrt(x(1,k)^2+x(2,k)^2);x(2,k)/(x(1,k)^2+x(2,k)^2) -x(1,k)/(x(1,k)^2+x(2,k)^2)];
    K = Pneg*H'*inv(H*Pneg*H'+R);
    zpre = [sqrt(x(1,k)^2+x(2,k)^2);atan(x(1,k)/x(2,k))];
    xe(:,k) = x(:,k)+K*(zr(:,k)-zpre);
    Ppos = Pneg-K*(H*Pneg*H'+R)*K';
end
t = 1:N;
figure(1);
plot(t,xr(1,:),'o-',t,xr(2,:),'-');
figure(2);
plot(t,xr(1,:),'-',t,x(1,:),'o-',t,xe(1,:),'*-');
figure(3);
plot(t,xr(2,:),'-',t,x(2,:),'o-',t,xe(2,:),'*-');
figure(4);
plot(t,xr(1,:)-x(1,:),'o-',t,xr(1,:)-xe(1,:),'*-');
figure(5);
plot(t,xr(2,:)-x(2,:),'o-',t,xr(2,:)-xe(2,:),'*-');