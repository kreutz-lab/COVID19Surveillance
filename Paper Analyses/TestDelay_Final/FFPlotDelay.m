function FFPlotDelay(Outbreak_tot,logo)

% FFPlotDelay(Outbreak_tot,logo)
%
% Basic Plot for Test-to-Result Delay Data.
%
% load('TestDelaySerious35Data.mat')

indwhich = 1;

delays = [2,1,0];
mu_data = mean(squeeze(Outbreak_tot(indwhich,:,:,:)),3);
mu_shape = reshape(mu_data,[3,4,3]);
sd_shape = 1*sqrt(mu_shape.*(1-mu_shape)/size(Outbreak_tot,4));

mu_plot = squeeze(mu_shape(2,:,:));
sd_plot = squeeze(sd_shape(2,:,:));

x = repmat(delays,[4,1]);
normali = max(mu_plot,[],[1,2]);
g = repmat([1;2;3;4],[1,3]);
if logo == 0
    y = mu_plot/normali;
    sd = sd_plot/normali;
    ylab = 'Relative Outbreak Probability [AU]';
elseif logo == 1
    y = log2(mu_plot/normali);
    sd = log2(exp(1))*sd_plot./mu_plot;
    ylab = 'Log2(Relative Outbreak Probability)';
end

clrs = lines(10);
hold on
ggplot = gscatter(x(:),y(:),g(:),clrs(1:4,:),'',30);
erplot = errorbar(x',y',sd','LineStyle','none','LineWidth',1.5);
for mm = 1:length(ggplot)
    set(erplot(mm),'Color',get(ggplot(mm),'Color'));
end
hold off

grid on
if logo == 0
    ylim([0,1.01]);
else
    ylim_old = get(gca,'YLim');
    ylim([ylim_old(1),0.01]);
end
xticks(sort(delays));
xlabel('Test-to-Result Delay t_{del} [Days]','FontSize',12);
ylabel(ylab,'FontSize',12);
title('Test-to-Result Delay','FontSize',14);

legend(ggplot,{'Baseline','Entry','Once Weekly','Twice Weekly'},...
    'Location','southeast')

end