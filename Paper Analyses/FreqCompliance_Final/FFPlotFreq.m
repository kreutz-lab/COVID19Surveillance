function FFPlotFreq(Outbreak_tot,whichcase,logo)

% FFPlotFreq(Outbreak_tot,whichcase,logo)
%
% Plots outbreak probability as function of Test Frequency and Compliance
% or Sensitivity. 
%
% logo = 0: Absolute probability (maximum nomalized to 1)
% logo = 1: Log2(Absolute Probability)
% logo = 2: Ratio to Best
%
% load('FreqSys35Data.mat')

if strcmp(whichcase,'testSensitivity') == 1
    indwhich = 1;
    titlestr = 'Sensitivity';
elseif strcmp(whichcase,'compliance') == 1
    indwhich = 2;
    titlestr = 'Compliance';
else
    warning('Case not found');
    return
end

% Define plot data:
freq_data = [1./(1:7),0]; %Express conditions as frequencies
mu_data = mean(squeeze(Outbreak_tot(indwhich,:,:,:)),3);
sd_data = sqrt(mu_data.*(1-mu_data)/size(Outbreak_tot,4));
log_data = log2(mu_data);
log_ratio = log_data - log_data(3,:);

errprog = @(x,y,sigx,sigy) ...
    log2(exp(1))*sqrt(((sigx./x).^2)+((sigy./y).^2));
sd_log_data = errprog(mu_data(1:2,:),mu_data(1:2,:),...
    sd_data(1:2,:),sd_data(1:2,:));

% Define plot data case-dependently:
if logo == 0
    x = repmat(freq_data,[3,1]);
    y = mu_data/max(mu_data,[],[1,2]);
    g = repmat([1;2;3],[1,8]);
    sd = sd_data/max(mu_data,[],[1,2]);
    leg_txt = {'  60% Compliance','  80% Compliance','100% Compliance'};
    ylab = 'Relative Outbreak Probability';
elseif logo == 1
    x = repmat(freq_data,[3,1]);
    y = log2(mu_data/max(mu_data,[],[1,2]));
    g = repmat([1;2;3],[1,8]);
    sd = log2(exp(1))*sd_data./mu_data;
    leg_txt = {'  60% Compliance','  80% Compliance','100% Compliance'};
    ylab = 'Log2(Relative Outbreak Probability)';   
elseif logo == 2
    x = repmat(freq_data,[2,1]);
    y = log_ratio(1:2,:);
    g = repmat([1;2],[1,8]);
    sd = sd_log_data;    
    leg_txt = {'Lower','Base'};
    ylab = 'Log2(Outbreak Probability Ratio)';
end
    
hold on
% Plot points and errors
ggplot = gscatter(x(:),y(:),g(:),'bgr','',30);
erplot = errorbar(x',y',sd','LineStyle','none','LineWidth',1.5);
for mm = 1:length(ggplot)
    set(erplot(mm),'Color',get(ggplot(mm),'Color'));
end

if logo == 0
    ylim([0,1.01]);
end

legend(ggplot,leg_txt,'Location','northeast');

grid on

% Manipulation of ticks and labels:
xlabel('Time Between Subsequent Tests [Days]','FontSize',12)
freqdatasort = sort(freq_data);
xticks(freqdatasort)
xticlab = strsplit(num2str(1./freqdatasort));
xticlab{1} = 'No Tests';
xticklabels(xticlab);
ylabel(ylab,'FontSize',12)
title(titlestr,'FontSize',14);

hold off
end