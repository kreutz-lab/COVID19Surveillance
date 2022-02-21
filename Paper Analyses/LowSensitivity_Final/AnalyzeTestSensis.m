function [ratios,sigmas] = AnalyzeTestSensis(Outbreak)

% Load data set 'LowerSensis35Data.mat' to run this analysis.
% Plot results with 'PlotEntryDays.m'

mu = mean(Outbreak,3);
n = size(Outbreak,3);
sd = sqrt((mu.*(1-mu))/n);

% Ratio data points:
ratios = log2(mu(:,2:4)./mu(:,1));

% Propagate error to log ratio:
errprog = @(x,y,sigx,sigy) log2(exp(1))*sqrt(((sigx./x).^2)+((sigy./y).^2));
sigmas = errprog(mu(:,2:4),mu(:,1),sd(:,2:4),sd(:,1));

end