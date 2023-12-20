t = 0:0.01:600;
Speed = speed.data;
figure
plot(t,Speed);
xlabel('{\it{t}}(sec)','fontname', 'times new roman','fontsize',18);
ylabel('\fontname{宋体}飞轮转速\fontname{times new roman}(rpm)','fontname', '宋体','fontsize',18);

TC = Tc.data;
figure
plot(t,TC);
xlabel('{\it{t}}(sec)','fontname', 'times new roman','fontsize',18);
ylabel('\fontname{宋体}实际控制力矩\fontname{times new roman}(N*m)','fontname', '宋体','fontsize',18);
legend('x','y','z','fontname', 'times new roman','fontsize',12);