function PlotTestSensis(ratios,sigmas)

% Plots results of the analysis of different sensitivities on the relative
% outbreak probability for the four strategies.

fig = figure('Position',[100,100,600,500]);

y = ratios;
x = repmat([50:10:100]',[1,3]);
g = repmat([1,2,3],[6,1]);

clrs = lines(10);
xlims = [min(x,[],'all')-5,max(x,[],'all')+5];

hold on
data = gscatter(x(:),y(:),g(:),clrs(2:4,:),'',25);
errors = errorbar(x,y,sigmas,'LineStyle','none','LineWidth',1);
for mm = 1:length(data)
    set(errors(mm),'Color',get(data(mm),'Color'));
end
base = line(xlims,[0,0],'Color','k','LineStyle','--','LineWidth',1.5);
hold off
xlim(xlims);
ylims = get(gca,'YLim');
ylim([ylims(1),0.02]);

xlabel('Test Sensitivity [%]');
ylabel('Log2(Relative Outbreak Probability)');

% Make grid for better visibility:
set(gca,'YGrid','on');
set(gca,'GridAlpha',0.3)

legend([base;data],{'Baseline','Entry','Once Weekly','Twice Weekly'},...
    'Location','northeast');

subs(1) = gca;
% Modify axes and labels for aesthetic reasons
xaxis_handle = get(subs(1),'XAxis');
set(xaxis_handle,'FontSize',13,'Linewidth',1.4);
yaxis_handle = get(subs(1),'YAxis');
set(yaxis_handle,'FontSize',13,'LineWidth',1.4);
xlab_handle = get(subs(1),'XLabel');
set(xlab_handle,'FontSize',14);
ylab_handle = get(subs(1),'YLabel');
set(ylab_handle,'FontSize',14);

end

