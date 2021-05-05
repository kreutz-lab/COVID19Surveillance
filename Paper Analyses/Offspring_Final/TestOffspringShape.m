% Generates the data for the offspring distriutions.
%
% Code is mainly copy-pasted from "FourStrategiesRun", so refer to this
% script for comments on basic structure.

kk_cases = 2;
nsimu = 100;
t = 100;
offspring_sec = NaN(kk_cases,nsimu);
offspring_tert = cell(kk_cases,1);

for jj = 1:nsimu
    
    clearvars -EXCEPT jj kk nsimu t offspring_sec offspring_tert ...
        Pops kk_cases profile_eff
    
    cfgHyper = InitHyperConfigs;
    cfgRandom = InitRandomConfigs(cfgHyper,2);
    
    if ~exist('profile_eff','var')
        [~,profile_eff] = CalibrateConfigs(cfgRandom);
    end
    
    for kk = 1:kk_cases
        
        % Turn off surveillance and keep individuals in clinic
        cfgRandom.fracIso = 0;
        cfgRandom.fracTrace = 0;
        cfgRandom.fracWeekend = 0;
        
        if kk == 1
            % Homogeneous infectivity
            cfgRandom.infectivityShape = 10^4;
        else
            % Infectivity as used in model
            cfgRandom.infectivityShape = 1.5;
        end
        cfg = CalibrateConfigs(cfgRandom,profile_eff);
        
        SimuPop_start = InitInfPopulation(cfg);
        SimuPop = SimuPop_start;
        
        for ii = 2:t
            
            SimuPop = ProgressDay(SimuPop);
            
        end
        
        offspring_sec(kk,jj) = CountSecondary(SimuPop);
        offspring_tert{kk} = [offspring_tert{kk},CountTertiary(SimuPop)];        
    end
end

save('OffspringShape.mat');