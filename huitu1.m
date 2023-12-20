t = 0:0.01:600;
WD = wd.data;
figure
plot(t,WD(:,1),t,WD(:,2),t,WD(:,3));
xlabel('{\it{t}}(sec)','fontname', 'times new roman','fontsize',18);
ylabel('\fontname{宋体}估计角速度\fontname{times new roman}(deg/sec)','fontsize',18);
legend('x','y','z','fontname', 'times new roman','fontsize',12);
ylim([-0.12,0.04]);

WM = wm.data;
figure
plot(t,WM(:,1),t,WM(:,2),t,WM(:,3));
xlabel('{\it{t}}(sec)','fontname', 'times new roman','fontsize',18);
ylabel('\fontname{宋体}量测角速度\fontname{times new roman}(deg/sec)','fontsize',18);
legend('x','y','z','fontname', 'times new roman','fontsize',12);

W = w.data;
figure
plot(t,W(:,1),t,W(:,2),t,W(:,3));
xlabel('{\it{t}}(sec)','fontname', 'times new roman','fontsize',18);
ylabel('\fontname{宋体}实际角速度\fontname{times new roman}(deg/sec)','fontsize',18);
legend('x','y','z','fontname', 'times new roman','fontsize',12);