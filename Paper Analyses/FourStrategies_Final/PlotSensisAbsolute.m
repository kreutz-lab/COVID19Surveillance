function PlotSensisAbsolute(Outbreak_tot,Quar_tot,Test_tot,casenames,ind_cmp)

% PlotSensisAbsolute(Outbreak_tot,Quar_tot,Test_tot,casenames,ind_cmp)
%
% Plots the absolute outbreak probability sensitivity plot.
%
% Outbreak_tot: Logical array of outbreaks. Load from 
%   'Sensitivity35Data.mat' or from 'NothingBaseline35Data.mat'.
% Quar_tot: Daily amount of agents in quarantine in simulation
% Test_tot: Daily amount of agents tested in simulation
% casenames: Names of sensitivity parameters, saved in same files
% ind_cmp: Vector of two strategies which are plotted simultaneously

ncases = length(casenames);
del = 0.15;
f = figure('Position',[100,100,1600,800]);
plothandle = cell(length(ind_cmp));

% Generate plot data from raw data:
mu = mean(Outbreak_tot,4);
n_tmp = size(Outbreak_tot,4);
sd = sqrt((mu.*(1-mu))/n_tmp);
muquar = sum(~Outbreak_tot.*Quar_tot,4)./sum(~Outbreak_tot,4);
mutest = sum(~Outbreak_tot.*Test_tot,4)./sum(~Outbreak_tot,4);
    % Only count tests and outbreaks if no outbreak occurred
mumean = squeeze(mean(mu(:,2,:),1));
sdmean = sqrt((mumean.*(1-mumean))/(n_tmp*ncases));
quarmean = squeeze(mean(muquar(:,2,:),1));
testmean = squeeze(mean(mutest(:,2,:),1));
quar_txt = round(quarmean,2);
test_txt = round(testmean,1);

for ii = 1:length(ind_cmp)
    
    % Generic Title
    if ind_cmp(ii) == 1
        titlestr = 'Baseline';
    elseif ind_cmp(ii) == 2
        titlestr = 'Entry';
    elseif ind_cmp(ii) == 3
        titlestr = 'Once Weekly';
    elseif ind_cmp(ii) == 4
        titlestr = 'Twice Weekly';
    else
        titlestr = [];
    end
    
    plothandle{ii} = subplot(1,length(ind_cmp),ii);
    
    % Plot Data and errors for upper/lower bound:
    hold on
    ggplot = gscatter([mu(:,1,ind_cmp(ii));...
        mu(:,3,ind_cmp(ii))]',...
        [(1:ncases)-del,(1:ncases)+del]',...
        [ones(1,ncases),3*ones(1,ncases)],'br');
    erplot = errorbar(mu(:,[1,3],ind_cmp(ii)),...
        [(1:ncases)-del;(1:ncases)+del]',...
        sd(:,[1,3],ind_cmp(ii)),...
        'horizontal','LineStyle','none','LineWidth',1.5);
    for mm = 1:2
        set(erplot(mm),'Color',get(ggplot(mm),'Color'));
    end
    hold off
    
    hs = get(gca,'Children');
    for jj = 1:length(hs)
        set(hs(jj),'MarkerSize',25)
    end
    
    % Draw line for best guess value:
    xpatch = [mumean(ind_cmp(ii)),mumean(ind_cmp(ii))];
    ypatch = [0,ncases+1];
    meanline = line(xpatch,ypatch,'Color','k','LineWidth',1.5);
    
    % Draw comparison to best guess in first plot:
    if ii ~= 1
        previ = line([mumean(ind_cmp(1)),mumean(ind_cmp(1))],[0,ncases+1],...
            'LineStyle','--','Color','k','LineWidth',1.5);
    end
    % Add legend in last plot:
    if ii == length(ind_cmp)
        legend([ggplot',meanline,previ],{'Lower Parameter Bound',...
            'Upper Parameter Bound','Best Parameter Estimate',...
            'Baseline'},'Location','northeast');
    else
        legend('off');
    end
    
    % Axis Labels
    set(gca,'YTick',1:ncases);
    set(gca,'YTickLabel',RemapNames(casenames),'FontSize',12);
    set(gca,'TickLabelInterpreter','none');
    set(gca,'YGrid','on');
    xlabel('Outbreak Probability','FontSize',14);
    title(titlestr,'FontSize',16);
    if ii > 1
        set(gca,'YTickLabel',[]);
    end
    
    % Adjust axis limits to be the same
    ylim([0,ncases+1]);
    xlim_tmp = get(gca,'XLim');
    if ii == 1
        xlims = xlim_tmp;
    else
        xlims = [min([xlims(1),xlim_tmp(1)]),max([xlims(2),xlim_tmp(2)])];
    end
    
end

% Add Test/Quarantine text,other aesthetic manipulations:
for ii = 1:length(plothandle)
    axes(plothandle{ii});
    set(plothandle{ii},'XLim',xlims);
    sumtxt = {['Quarantine: ',num2str(quar_txt(ind_cmp(ii)))],...
        ['Tests: ',num2str(test_txt(ind_cmp(ii)))]};
    text(0.55*diff(xlims),1,sumtxt,'FontSize',11);
    xaxis_handle = get(plothandle{ii},'XAxis');
    set(xaxis_handle,'FontSize',11,'Linewidth',1);
    yaxis_handle = get(plothandle{ii},'YAxis');
    set(yaxis_handle,'FontSize',11,'LineWidth',1);
end

end