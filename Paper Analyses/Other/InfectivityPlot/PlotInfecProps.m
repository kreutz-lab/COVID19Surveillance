% Plots Infectivity Profiles and Time Distributions into subplots:

f = figure('Position',[150,150,1300,400]);
subs = gobjects(2,1);

subs(1) = subplot(1,2,1);
PlotTimeDist;
subs(2) = subplot(1,2,2);
InfectivityPlot;

prefix = {'A: ','B: '};
for ii = 1:2
    title_tmp = get(subs(ii),'Title');
    set(title_tmp,'String',[prefix{ii},get(title_tmp,'String')])
    xaxis_handle = get(subs(ii),'XAxis');
    set(xaxis_handle,'FontSize',11,'Linewidth',1);
    yaxis_handle = get(subs(ii),'YAxis');
    set(yaxis_handle,'FontSize',11,'LineWidth',1);
    xlab_handle = get(subs(ii),'XLabel');
    set(xlab_handle,'FontSize',13);
    ylab_handle = get(subs(ii),'YLabel');
    set(ylab_handle,'FontSize',13);
end