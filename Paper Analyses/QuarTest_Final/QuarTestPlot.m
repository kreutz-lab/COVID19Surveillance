function QuarTestPlot(Outbreak_tot,Quar_tot,Test_tot,casenames,case_ind)

subs = gobjects(1,2);
kk_cases = length(casenames);
del = 0.15;
f = figure('Position',[100,100,1100,800]);

for ii = 1:2   
    if ii == 1
        analysant = Test_tot;
        titlestr = 'Tests';
        xlab = 'Tests per Day';
    else
        analysant = Quar_tot;
        titlestr = 'Quarantine';
        xlab = 'Agents in Quarantine per Day';
    end
    
    mu = sum(~Outbreak_tot.*analysant,4)./sum(~Outbreak_tot,4);
    mu_mean = mean(mu(:,2,case_ind));
    
    subs(ii) = subplot(1,2,ii);

    hold on
    ggplot = gscatter([mu(:,1,case_ind);mu(:,3,case_ind)]',...
        [(1:kk_cases)-del,(1:kk_cases)+del]',...
        [ones(1,kk_cases),3*ones(1,kk_cases)],'br');
    meanline = line([mu_mean,mu_mean],[0,kk_cases+1],'Color','k','LineWidth',2.5);
    hold off
    
    hs = get(gca,'Children');
    for jj = 1:length(hs)
        set(hs(jj),'MarkerSize',30)
    end
    set(gca,'YTick',1:kk_cases);
    set(gca,'YTickLabel',RemapNames(casenames),'FontSize',12);
    set(gca,'TickLabelInterpreter','none');
    set(gca,'YGrid','on');
    legend([ggplot(1),meanline,ggplot(2)],{'Lower Parameter Bound','Best Parameter Guess',...
        'Upper Parameter Bound'},'Location','northeast');
    title(titlestr,'FontSize',14);
    xlabel(xlab,'FontSize',12);
    xaxis_handle = get(subs(ii),'XAxis');
    set(xaxis_handle,'FontSize',11,'Linewidth',1);
    yaxis_handle = get(subs(ii),'YAxis');
    set(yaxis_handle,'FontSize',11,'LineWidth',1);
    
end

set(subs(2),'YTickLabel',{''});
legend(subs(1),'off');
set(subs(1),'Position',[0.15,0.1,0.28,0.8]);
set(subs(2),'Position',[0.48,0.1,0.28,0.8]);
leg = get(subs(2),'Legend');
pos = get(leg,'Position');
pos(1) = 0.77;
set(leg,'Position',pos);

q_specificity = strcmp(casenames','testSpecificity');
yticklabs = get(subs(1),'YTickLabel');
yticklabs{q_specificity} = '\bf TestSpecificity';
set(subs(1),'TickLabelInterpreter','tex');
set(subs(1),'YTickLabel',yticklabs);
pars_txt = ...
    ['\bf [\color[rgb]{0,0,1}0.98,\color[rgb]{0,0,0}0.995,'...
        '\color[rgb]{1,0,0}0.999\color[rgb]{0,0,0}]'];
axes(subs(1));
xlims = get(subs(1),'XLim');
ylims = get(subs(1),'YLim');
text(xlims(1)+0.03*(xlims(2)-xlims(1)),...
    0.25+find(q_specificity),pars_txt,...
    'FontSize',11,'Interpreter','tex');


end