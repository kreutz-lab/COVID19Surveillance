% Plots final sensitivity plot of the comparison of the three active
% strategies compared to baseline surveillance. The sensitivity plots are
% only combined in this function, the magic happens in FFPlotSensisCompare

% load('Sensitivity35Data.mat')

% Use AnalyzeOutbreak on file with saved infection chronologies to obtain 
% logical array of outbreaks.
Outbreak_tot = Outbreak_tot3;

f = figure('Position',[50,150,1820,600]);
subs = NaN(1,3);
xlims = NaN(3,2);

% Entry-Testing to Baseline
subs(1) = subplot(1,3,1);
FFPlotSensisCompare(Outbreak_tot,casenames,[2,1],1);
legend('off')
xlabel('');
ylabel('Model Parameters','FontSize',16);
xlims(1,:) = get(gca,'XLim');

% Once Weekly Testing to Baseline
subs(2) = subplot(1,3,2);
FFPlotSensisCompare(Outbreak_tot,casenames,[3,1],1);
legend('off')
set(gca,'YTickLabel',[]);
xlims(2,:) = get(gca,'XLim');
xlab = get(gca,'XLabel');
set(xlab,'FontSize',16);

% Twice Weekly Testing to Baseline
subs(3) = subplot(1,3,3);
FFPlotSensisCompare(Outbreak_tot,casenames,[4,1],1);
set(gca,'YTickLabel',[]);
xlabel('');
xlims(3,:) = get(gca,'XLim');

pos = NaN(3,4);
subaxes = get(gcf,'Children');
xlim_new = [min(xlims(:,1)),max(xlims(:,2))]; % x-axis same over all subplots
for ii = 1:3
    set(subs(ii),'XLim',xlim_new);
    % Add phantom line for legend:
    if ii == 3
        line([NaN,NaN],[NaN,NaN],'Color',[0,0,0],'LineWidth',1.5);
    end
    % Modify axes and labels for aesthetic reasons
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

% Set name in legend:
leg = get(subs(3),'Legend');
strs = get(leg,'String');
strs{6} = 'Ratio Best Parameters';
set(leg,'String',strs);

% Rearrange objects in legend:
all_objs = get(subs(3),'Children');
all_names = get(all_objs,'DisplayName');
q_objs = ~cellfun(@isempty,all_names);
leg_objs = all_objs(q_objs);
names_objs = all_names(q_objs);
permu = [2,1,6,5,4,3];
legend(leg_objs(permu),names_objs(permu),'FontSize',12);

% Shift legend position:
leg_pos = get(leg,'Position');
set(leg,'Position',leg_pos+[0.005,0,0,0]);

% Shift subplots closer too each other:
del = 0.9*(pos(1,1) - pos(2,1) - pos(1,3));
    % Values within brackets is space between two subplots
pos(1,1) = pos(1,1) - 2*del;
pos(2,1) = pos(2,1) - del;
for ii = 1:3
    set(subaxes(ii+1),'Position',pos(ii,:));
end

% Add test next to y-axis:
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

% Add title to plots:
title_post = {'Entry','Once Weekly','Twice Weekly'};
for ii = 1:3
    title_tmp = get(subs(ii),'Title');
    title_str = [title_post{ii},' - Baseline'];
    set(title_tmp,'String',title_str);
end
    
    
    