t = 0:0.01:600;
Speed = speed.data;
figure
plot(t,Speed);
xlabel('{\it{t}}(sec)','fontname', 'times new roman','fontsize',18);
ylabel('\fontname{����}����ת��\fontname{times new roman}(rpm)','fontname', '����','fontsize',18);

TC = Tc.data;
figure
plot(t,TC);
xlabel('{\it{t}}(sec)','fontname', 'times new roman','fontsize',18);
ylabel('\fontname{����}ʵ�ʿ�������\fontname{times new roman}(N*m)','fontname', '����','fontsize',18);
legend('x','y','z','fontname', 'times new roman','fontsize',12);