% Final Triple Result Plot:
% Test-to-Result Delay, Outbreak Size, Compliance and Tets Frequency

f = figure('Position',[150,150,1400,500]);
subs = gobjects(1,3);

subs(1) = subplot(1,3,1);
load('TestDelaySerious35Data.mat')
FFPlotDelay(Outbreak_tot3,1);
subs(2) = subplot(1,3,2);
load('StepAnalysis.mat')
FFPlotOutbreakPoints;
subs(3) = subplot(1,3,3);
load('FreqSys35Data.mat');
FFPlotFreq(Outbreak_tot3,'compliance',1);

clearvars -EXCEPT f subs

legend(subs(1),'off');

pos = cell2mat(get(subs,'Position'));
siz = pos(1,3);
dis = pos(2,1) - pos(1,1) - siz;
siz_mod = 0.1;
dis_mod = 0.3;

pos(1,3) = (1-siz_mod)*siz;
pos(2,3) = (1-siz_mod)*siz;
pos(3,3) = (1+2*siz_mod)*siz+2*dis_mod*dis;
pos(2,1) = pos(1,1) + (1-dis_mod)*dis+(1-siz_mod)*siz;
pos(3,1) = pos(2,1) + (1-dis_mod)*dis+(1-siz_mod)*siz;

txts = {'A: ','B: ','C: '};
ylims = [];
for ii = 1:3
    axes(subs(ii));
    title_tmp = get(subs(ii),'Title');
    set(title_tmp,'String',[txts{ii},get(title_tmp,'String')],...
        'FontSize',14)
    set(subs(ii),'Position',pos(ii,:));
    ylims_tmp = get(subs(ii),'YLim');
    if isempty(ylims)
        ylims = ylims_tmp; 
    else
        ylims(1) = min([ylims(1),ylims_tmp(1)]);
    end
    
    xaxis_handle = get(subs(ii),'XAxis');
    set(xaxis_handle,'FontSize',11,'Linewidth',1.1);
    yaxis_handle = get(subs(ii),'YAxis');
    set(yaxis_handle,'FontSize',11,'LineWidth',1.1);
    xlab_handle = get(subs(ii),'XLabel');
    set(xlab_handle,'FontSize',13);
    ylab_handle = get(subs(ii),'YLabel');
    set(ylab_handle,'FontSize',13);
    leg = get(subs(ii),'Legend');
    set(leg,'FontSize',10,'AutoUpdate','off');
    xlims = get(subs(ii),'XLim');
    line(subs(ii),xlims,[0,0],'LineWidth',2,...
        'LineStyle','--','Color',[0,0,0]);
    set(subs(ii),'GridAlpha',0.3)
end
set(subs,'YLim',[-5.1,0.1]);
ylabel(subs(2),'');
ylabel(subs(3),'');

% Optional: Modify error bar sizes
% erbars = findobj(subs,'Type','ErrorBar');
% multiple = @(x) 3*x;
% negbars = get(erbars,'YNegativeDelta');
% posbars = get(erbars,'YPositiveDelta');
% negbars_new = cellfun(multiple,negbars,'UniformOutput',false);
% posbars_new = cellfun(multiple,posbars,'UniformOutput',false);
% for ii = 1:length(erbars)
%     set(erbars(ii),'YNegativeDelta',negbars_new{ii});
%     set(erbars(ii),'YPositiveDelta',posbars_new{ii});
% end