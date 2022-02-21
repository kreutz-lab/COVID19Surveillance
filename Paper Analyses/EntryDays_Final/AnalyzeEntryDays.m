function [ratios,sigmas] = AnalyzeEntryDays(Outbreak)

% Load data set 'EntryDays35Data.mat' to run this analysis.
% Plot results with 'PlotEntryDays.m'

mu = mean(Outbreak,3);
n = size(Outbreak,3);
sd = sqrt((mu.*(1-mu))/n);

mumean = mean(mu(:,1));
sdmean = mean(sd(:,1))/sqrt(size(Outbreak,1));

% Ratio data points:
ratios = log2(mu(:,2)./mumean);

% Propagate error to log ratio:
errprog = @(x,y,sigx,sigy) log2(exp(1))*sqrt(((sigx./x).^2)+((sigy./y).^2));
sigmas = errprog(mu(:,2),mumean,sd(:,2),sdmean);

end