crvs = gobjects(3,1);

x = 0:0.01:4;
y1 = pdf('Gamma',x,1.5,1/1.5);
y2 = pdf('Gamma',x,10,1/10);
y3 = pdf('Gamma',x,50,1/50);

clrs = lines(10);
hold on
crvs(1) = plot(x,y1,'Color',clrs(6,:));
crvs(2) = plot(x,y2,'Color',clrs(4,:));
crvs(3) = plot(x,y3,'Color',clrs(2,:));
ylims = get(gca,'YLim');
meaninfec = line([1,1],ylims,'Color','k','LineStyle','--','LineWidth',2);
hold off

set(crvs,'LineWidth',2);
xlabel('Infectivity Factor');
ylabel('Probability Density');
legend([crvs;meaninfec],{'Shape = 1.5','Shape = 10',...
    'Shape = 50','Mean Infectivity'},'FontSize',11);

xaxis_handle = get(gca,'XAxis');
set(xaxis_handle,'FontSize',11,'Linewidth',1);
yaxis_handle = get(gca,'YAxis');
set(yaxis_handle,'FontSize',11,'LineWidth',1);
xlab_handle = get(gca,'XLabel');
set(xlab_handle,'FontSize',14);
ylab_handle = get(gca,'YLabel');
set(ylab_handle,'FontSize',14);
