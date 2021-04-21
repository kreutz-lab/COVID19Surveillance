% Plots of different infectivity profiles

cfgHyper = InitHyperConfigs;
cfgRandom = InitRandomConfigs(cfgHyper,2);
cfgRandom.fracAsymp = 0;
cfg = CalibrateConfigs(cfgRandom);

tmax = [];
hold on
for ii = 1:20
    [~,infec] = CourseOfDisease(cfg);
    infec = [0,infec];
    infec(end+1) = 0;
    ts = 0:(length(infec)-1);
    if isempty(tmax)
        tmax = ts(end);
    else
        tmax = max(tmax,ts(end));
    end
    lastplot = plot(ts,infec,'Color',[0.7,0.7,0.7],'LineWidth',1);
    xlim([0,tmax]);
end

legend(lastplot,'Random Infectivity Profile');
xlabel('Days','FontSize',12);
ylabel('Relative Infecticity','FontSize',12);
title('Sample of Infectivity Profiles','FontSize',14);
set(gca,'XGrid','on');

hold off
