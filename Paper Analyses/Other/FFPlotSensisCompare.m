function FFPlotSensisCompare(Outbreak_tot,casenames,ind_cmp,logo,varname)

% FFPlotSensisCompare(Outbreak_tot,casenames,ind_cmp,logo)
%
% Plots Basic Sensitivity Plot of outbreak probability ratios between strategies
%
% load('Serious35Data.mat');

scennames = {'Baseline','Entry','Once Weekly','Twice Weekly'};

% Ratios on log scale?
if ~exist('logo','var')
    logo = 0;
end
if ~exist('varname','var')
    varname = 0;
end

ncases = length(casenames);

% Generate data points and binomial standard error
mu_outbreak = mean(Outbreak_tot,4);
n_tmp = size(Outbreak_tot,4);
sd_outbreak = sqrt((mu_outbreak.*(1-mu_outbreak))/n_tmp);

mumean = squeeze(mean(mu_outbreak(:,2,:),1));
sdmean = sqrt((mumean.*(1-mumean))/(n_tmp*ncases));

% Ratio data points:
rel_effec = mu_outbreak(:,:,ind_cmp(1))./mu_outbreak(:,:,ind_cmp(2));
rel_tot = mumean(ind_cmp(1))/mumean(ind_cmp(2)); % average over base parameters

% Propagate error to log ratio:
errprog = @(x,y,sigx,sigy) log2(exp(1))*sqrt(((sigx./x).^2)+((sigy./y).^2));
sd_log_effec = errprog(mu_outbreak(:,:,ind_cmp(1)),mu_outbreak(:,:,ind_cmp(2)),...
    sd_outbreak(:,:,ind_cmp(1)),sd_outbreak(:,:,ind_cmp(2)));
sdmean_effec_log = errprog(mumean(ind_cmp(1)),mumean(ind_cmp(2)),...
    sdmean(ind_cmp(1)),sdmean(ind_cmp(2)));

if logo == 0
    mu = rel_effec;
    er_up = 2.^(log2(mu)+sd_log_effec)-mu;
    er_down = mu-2.^(log2(mu)-sd_log_effec);
    mu_tot = rel_tot;
    ermean_down = 2.^(log2(mu_tot) - sdmean_effec_log);
    ermean_up = 2.^(log2(mu_tot) + sdmean_effec_log);
    base = 1;
    xlab = 'Reduction of Outbreak Probability (Ratio)';
elseif logo == 1
    mu = log2(rel_effec);
    er_up = sd_log_effec;
    er_down = sd_log_effec;
    mu_tot = log2(rel_tot);
    ermean_down = mu_tot - sdmean_effec_log;
    ermean_up = mu_tot + sdmean_effec_log;
    base = 0;
    xlab = 'Reduction of Outbreak Probability (Ratio)';
end

del = 0.15;
alpha_low = 0.2;
alpha_high = 1;
mrksize = 80;
mineffects = [-0.1,0.1];
range1 = (ncases-1):ncases;
range2 = 1:(ncases-2);
clrs = [0,0,1;1,0,0];

hold on
ghostscatter_clr1 = scatter(NaN,NaN,80,clrs(1,:),'filled');
ghostscatter_clr2 = scatter(NaN,NaN,80,clrs(2,:),'filled');
ggplot1 = scatter([mu(range1,1);mu(range1,3)]',...
    [range1-del,range1+del],mrksize,...
    [repmat(clrs(1,:),[length(range1),1]);repmat(clrs(2,:),[length(range1),1])],...
    'filled','MarkerFaceAlpha',alpha_high);
ggplot2 = scatter([mu(range2,1);mu(range2,3)]',...
    [range2-del,range2+del],mrksize,...
    [repmat(clrs(1,:),[length(range2),1]);repmat(clrs(2,:),[length(range2),1])],...
    'filled','MarkerFaceAlpha',alpha_low);
erplot1 = errorbar(mu(range1,[1,3]),...
    [range1-del;range1+del]',...
    er_down(range1,[1,3]),er_up(range1,[1,3]),...
    'horizontal','LineStyle','none','LineWidth',1.5);
erplot2 = errorbar(mu(range2,[1,3]),...
    [range2-del;range2+del]',...
    er_down(range2,[1,3]),er_up(range2,[1,3]),...
    'horizontal','LineStyle','none','LineWidth',1.5);
for mm = 1:2
    set(erplot1(mm),'Color',clrs(mm,:));
    set(erplot2(mm),'Color',clrs(mm,:));
end

% xpatch = [ermean_down,ermean_down,ermean_up,ermean_up];
% ypatch = [0,ncases+1,ncases+1,0];
% patches = patch(xpatch,ypatch,'g');
% set(patches,'FaceAlpha',0.2,'LineStyle','none');
patches = line([mu_tot,mu_tot],[0,ncases+1],'Color','k','LineWidth',2);

set(gca,'YTick',1:ncases);
set(gca,'YTickLabel',RemapNames(casenames,varname),'FontSize',12);
yticklabs = get(gca,'YTickLabel');
yticklabs{end-1} = ['\bf ',yticklabs{end-1}];
yticklabs{end} = ['\bf ',yticklabs{end}];
set(gca,'YTickLabel',yticklabs);
set(gca,'YGrid','on');
set(gca,'GridAlpha',0.3)
xlabel(xlab);
xticks(log2(0.1:0.1:1));
set(gca,'XTickLabel',num2cell(0.1:0.1:1));
xlim_old = get(gca,'XLim');
xlim([min(base-2*(base-mineffects(1)),xlim_old(1)),...
    max(base+2*(mineffects(2)-base),xlim_old(2))]);
ylim([0,ncases+1]);
baseline = line([base,base],[0,ncases+1],...
    'LineStyle','--','LineWidth',2,'Color','k');
legend([ghostscatter_clr1,ghostscatter_clr2,erplot1(1:2),baseline],...
    {'Ratio Lower Bound','Ratio Upper Bound',...
    'Stochastic Error','Stochastic Error','Baseline Scenario'},...
    'Location','northeast');
title([scennames{ind_cmp(1)},' - ',scennames{ind_cmp(2)}],...
    'FontSize',18);
hold off

end