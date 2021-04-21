% Skeleton simulation code to start a simulation with customized properties
% and scenarios.

nsimu = 10;
scens = 1;
t = 100;
Pops = cell(scens,nsimu);
Chronos = cell(scens,nsimu);
Quar_tot = NaN(scens,nsimu);
Test_tot = NaN(scens,nsimu);

for jj = 1:nsimu
    
    clearvars -EXCEPT jj kk mm nsimu t scens SimuPop_start...
        Quar_tot Test_tot profile_eff Chronos Pops
    
    cfgHyper = InitHyperConfigs;
    cfgRandom = InitRandomConfigs(cfgHyper,2);
    
    if ~exist('profile_eff','var')
        [cfg,profile_eff] = CalibrateConfigs(cfgRandom);
    else
        cfg = CalibrateConfigs(cfgRandom,...
            profile_eff);
    end
    SimuPop_start = DrawPopulation(cfg);
    % DrawPopulation at this point to ensure that they are the same over all
    % conditions
    
    for nn = 1:scens
        
        SimuPop = SimuPop_start;
        
        for ii = 2:t
            
            SimuPop = ProgressDay(SimuPop);
            
            if SimuPop.WeekDay == 6
                q_who = (SimuPop.Calc.PurposeID(:,ii) == 1);
                q_who = q_who & (rand(size(q_who)) < SimuPop.cfg.fracWeekend);
                SimuPop = ConductEvent(SimuPop,'leave',q_who,2);
            end
            % Leave Clinic on day ii-1:
            % Evening, because infections are still checked in clinic
            
        end
        
        Chronos{nn,jj} = SummarizeInfections(SimuPop);
        Quar_tot(nn,jj) = sum(SimuPop.Calc.Quarantined,'all','omitnan')/t;
        Test_tot(nn,jj) = SimuPop.TestCounter/t;
        Pops{nn,jj} = SimuPop;
        
    end
end
