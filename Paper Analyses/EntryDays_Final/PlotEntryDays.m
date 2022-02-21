function PlotEntryDays(ratios,sigmas)

% Plots results of the analysis of the impact of the day of the second
% entry test.

fig = figure('Position',[100,100,400,500]);

x = 1:length(ratios);
y = ratios;

xlims = [min(x)-0.5,max(x)+0.5];
hold on
data = plot(x,y,'Marker','.','MarkerSize',20,'LineStyle','None');
errors = errorbar(y,sigmas,'Color',get(data,'Color'),...
    'LineStyle','none','LineWidth',1.5);
base = line(xlims,[0,0],'Color','k','LineStyle','--','LineWidth',1.5);
hold off
xlim(xlims);
ylims = get(gca,'YLim');
ylim([ylims(1),0.02]);

xlabel('Day of Second Test');
ylabel('Log2(Relative Outbreak Probability)');

% Make grid for better visibility:
set(gca,'YGrid','on');
set(gca,'GridAlpha',0.3)

legend([base,data,errors],...
    {'Baseline','Log-Reduction','Stochastic Error'});

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

