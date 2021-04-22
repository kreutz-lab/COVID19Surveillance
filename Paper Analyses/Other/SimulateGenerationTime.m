% Simulate generation times from infectivity profiles for different
% parameter assumptions.

n = 10^5;
t_inf = NaN(1,n);
mu_gen = NaN(1,3);
se_gen = NaN(1,3);

for jj = 1:3
    
% jj = 1: Minimal Generation Time
% jj = 2: Best Guess Generation Time
% jj = 3: Maximal Generation Time
    
    cfgHyper = InitHyperConfigs;
    cfgRandom = InitRandomConfigs(cfgHyper,2);
    cfgRandom.IncubationMean = cfgHyper.Sensitivity.IncubationMean(jj);
    cfgRandom.SymptomMean = cfgHyper.Sensitivity.SymptomMean(jj);
    cfgRandom.PeakShift = cfgHyper.Sensitivity.PeakShift(jj);
    cfg = CalibrateConfigs(cfgRandom);

    % Generate random infectivity profile and draw random infection time:
    for ii = 1:n
        [~,prob] = CourseOfDisease(cfg);
        prob = prob/sum(prob);
        mnrnd(1,prob);
        t_inf(ii) = find(mnrnd(1,prob));
    end
    
    % Estimate for expected generation time:
    mu_gen(jj) = mean(t_inf);
    se_gen(jj) = std(t_inf)/sqrt(n);

end