% Plots of random infectivity profiles:

% Initialize configs with best guess parameters:
cfgHyper = InitHyperConfigs;
cfgRandom = InitRandomConfigs(cfgHyper,2);
cfgRandom.fracAsymp = 0; % without asymptomatic contribution
cfg = CalibrateConfigs(cfgRandom);

tmax = [];
hold on
for ii = 1:20
    [~,infec] = CourseOfDisease(cfg); % Draw random infectivity profile
    infec = [0,infec]; % Include day of infection as non-infectious
    infec(end+1) = 0; % Include day of infection clearance as non-infectious
    ts = 0:(length(infec)-1);
    if isempty(tmax)
        tmax = ts(end);
    else
        tmax = max(tmax,ts(end));
    end
    % Add currentprofile to plot:
    lastplot = plot(ts,infec,'Color',[0.7,0.7,0.7],'LineWidth',1);
    xlim([0,tmax]); % Adjust to fit longest profile
end

legend(lastplot,'Random Infectivity Profile');
xlabel('Days','FontSize',12);
ylabel('Relative Infecticity','FontSize',12);
title('Sample of Infectivity Profiles','FontSize',14);
set(gca,'XGrid','on');

hold off
