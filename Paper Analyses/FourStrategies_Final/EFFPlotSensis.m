% Plots Final Large Sensitivity Plot.
%
% load('Serious35Data.mat')

Outbreak_tot = Outbreak_tot5;

f = figure('Position',[50,150,1820,600]);
subs = NaN(1,3);
xlims = NaN(3,2);

subs(1) = subplot(1,3,1);
FFPlotSensisCompare(Outbreak_tot,casenames,[2,1],1);
legend('off')
xlabel('');
ylabel('Model Parameters','FontSize',16);
xlims(1,:) = get(gca,'XLim');

subs(2) = subplot(1,3,2);
FFPlotSensisCompare(Outbreak_tot,casenames,[3,1],1);
legend('off')
set(gca,'YTickLabel',[]);
xlims(2,:) = get(gca,'XLim');
xlab = get(gca,'XLabel');
set(xlab,'FontSize',16);

subs(3) = subplot(1,3,3);
FFPlotSensisCompare(Outbreak_tot,casenames,[4,1],1);
set(gca,'YTickLabel',[]);
xlabel('');
xlims(3,:) = get(gca,'XLim');

pos = NaN(3,4);
subaxes = get(gcf,'Children');
xlim_new = [min(xlims(:,1)),max(xlims(:,2))];
for ii = 1:3
    set(subs(ii),'XLim',xlim_new);
    if ii == 3
        line([NaN,NaN],[NaN,NaN],'Color',[0,0,0],'LineWidth',1.5);
    end
    pos(ii,:) = get(subaxes(ii+1),'Position');
    xaxis_handle = get(subs(ii),'XAxis');
    set(xaxis_handle,'FontSize',13,'Linewidth',1.4);
    yaxis_handle = get(subs(ii),'YAxis');
    set(yaxis_handle,'FontSize',13,'LineWidth',1.4);
    xlab_handle = get(subs(ii),'XLabel');
    set(xlab_handle,'FontSize',16);
    ylab_handle = get(subs(ii),'YLabel');
    set(ylab_handle,'FontSize',16);
end
leg = get(subs(3),'Legend');
strs = get(leg,'String');
strs{6} = 'Ratio Best Parameters';
set(leg,'String',strs);

all_objs = get(subs(3),'Children');
all_names = get(all_objs,'DisplayName');
q_objs = ~cellfun(@isempty,all_names);
leg_objs = all_objs(q_objs);
names_objs = all_names(q_objs);
permu = [2,1,6,5,4,3];
legend(leg_objs(permu),names_objs(permu),'FontSize',12);
leg_pos = get(leg,'Position');
set(leg,'Position',leg_pos+[0.005,0,0,0]);

del = 0.9*(pos(1,1) - pos(2,1) - pos(1,3));
pos(1,1) = pos(1,1) - 2*del;
pos(2,1) = pos(2,1) - del;
for ii = 1:3
    set(subaxes(ii+1),'Position',pos(ii,:));
end

xlims = get(subs(1),'XLim');
ylims = get(subs(1),'YLim');
txts = ...
    {['\bf [\color[rgb]{0,0,1}60%,\color[rgb]{0,0,0}80%,'...
        '\color[rgb]{1,0,0}100%\color[rgb]{0,0,0}]'],...
    ['\bf [\color[rgb]{0,0,1}80%,\color[rgb]{0,0,0}90%,'...
        '\color[rgb]{1,0,0}100%\color[rgb]{0,0,0}]']};
for ii = 1:2
    axes(subs(1));
    t = text(xlims(1)+0.05*(xlims(2)-xlims(1)),...
        ylims(2)+0.25-ii,txts{ii},'FontSize',13,'Interpreter','tex');
end

title_post = {'Entry','Once Weekly','Twice Weekly'};
for ii = 1:3
    title_tmp = get(subs(ii),'Title');
    title_str = [title_post{ii},' - Baseline'];
    set(title_tmp,'String',title_str);
end
    
    
    