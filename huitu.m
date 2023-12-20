t = 0:0.01:600;
Q1 = Qr.data;
figure
plot(t,Q1(:,1));
xlabel('{\it{t}}(sec)','fontname', 'times new roman','fontsize',18);
ylabel('实际四元数','fontname', '宋体','fontsize',18);
ylim([0.997,1.0005]);
legend('q0','fontname', 'times new roman','fontsize',12);
figure
plot(t,Q1(:,2),t,Q1(:,3),t,Q1(:,4));
xlabel('{\it{t}}(sec)','fontname', 'times new roman','fontsize',18);
ylabel('实际四元数','fontname', '宋体','fontsize',18);
legend('q1','q2','q3','fontname', 'times new roman','fontsize',12);

Q2 = Qd.data;
figure
plot(t,Q2(:,1));
xlabel('{\it{t}}(sec)','fontname', 'times new roman','fontsize',18);
ylabel('估计四元数','fontname', '宋体','fontsize',18);
ylim([0.997,1.0005]);
legend('q0','fontname', 'times new roman','fontsize',12);
figure
plot(t,Q2(:,2),t,Q2(:,3),t,Q2(:,4));
xlabel('{\it{t}}(sec)','fontname', 'times new roman','fontsize',18);
ylabel('估计四元数','fontname', '宋体','fontsize',18);
legend('q1','q2','q3','fontname', 'times new roman','fontsize',12);

Q3 = Qm.data;
figure
plot(t,Q3(:,1));
xlabel('{\it{t}}(sec)','fontname', 'times new roman','fontsize',18);
ylabel('量测四元数','fontname', '宋体','fontsize',18);
ylim([0.997,1.0005]);
legend('q0','fontname', 'times new roman','fontsize',12);
figure
plot(t,Q3(:,2),t,Q3(:,3),t,Q3(:,4));
xlabel('{\it{t}}(sec)','fontname', 'times new roman','fontsize',18);
ylabel('量测四元数','fontname', '宋体','fontsize',18);
legend('q1','q2','q3','fontname', 'times new roman','fontsize',12);



