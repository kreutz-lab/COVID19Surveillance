% Generates the data for the comparing different combinations of the two
% days of the entry tests.

% If the seed is not shuffled, results of simulations will be the same
% if conducted directly after starting a new instance of MATLAB
rng('shuffle')

% Add relevant folders with the necessary functions
addpath(genpath(pwd));

cfgHyper = InitHyperConfigs;
nsimu = 10; % Number of simulations
scens = 2;
entris = [1,2,3,4,5,6]; % Days for second test
t = 100; % Number of Simulation Days
Chronos = cell(length(entris),scens,nsimu);
Quar_tot = NaN(length(entris),scens,nsimu);
Test_tot = NaN(length(entris),scens,nsimu);

for jj = 1:nsimu
    
    clearvars -EXCEPT jj nsimu t scens entris SimuPop_start...
        Quar_tot Test_tot profile_eff Chronos ...
    
    % Initialize population for this simulation index, such that it is the
    % same overal scenarios and sensitivity analyses:
    cfgHyper = InitHyperConfigs;
    cfgRandom = InitRandomConfigs(cfgHyper,2); %Initialize all at best guess
    cfgRandom.testDelay = cfgHyper.Scenario.testDelay(1);
    % no test delay
    cfgRandom.minQuarantine = cfgHyper.Scenario.minQuarantine(1);
    % no minimal quarantine
    cfgRandom.maxQuarantine = cfgHyper.Scenario.maxQuarantine(2);
    % 10 days of maximal quarantine time
    cfgRandom.retestfreq = cfgHyper.Scenario.retestfreq(2);
    if ~exist('profile_eff','var')
        [cfg,profile_eff] = CalibrateConfigs(cfgRandom);
    else
        cfg = CalibrateConfigs(cfgRandom,...
            profile_eff);
        % profile_eff is numerically calibrated. This is skipped if a value
        % is provided.
    end
    SimuPop_start = DrawPopulation(cfg);
    
    for kk = 1:length(entris)
        % Loop over different days for second entry test
        
        for nn = 1:scens
            % Loop over different strategies
            
            SimuPop = SimuPop_start;
            cfg = CalibrateConfigs(cfgRandom,profile_eff);
            SimuPop.cfg = cfg;
            
            for ii = 2:t
                % Conduct Simulation according to defined
                % specifications
                
                SimuPop = ProgressDay(SimuPop);
                
                if nn == 2
                    % Entry Testing
                    
                    q_who_base = (SimuPop.Calc.Quarantined(:,ii) == 0);
                    
                    q_who = (SimuPop.Calc.LastLeaveTimer(:,ii) == 0) | ...
                        (SimuPop.Calc.LastLeaveTimer(:,ii) == entris(kk));
                    q_who = q_who & q_who_base;
                    SimuPop = ConductEvent(SimuPop,'test',q_who);
                   
                end
                
                if SimuPop.WeekDay == 6
                    % Patient weekend leave
                    q_who = (SimuPop.Calc.PurposeID(:,ii) == 1);
                    q_who = q_who & (rand(size(q_who)) < ...
                        SimuPop.cfg.fracWeekend);
                    SimuPop = ConductEvent(SimuPop,'leave',q_who,2);
                end
            end
            
            % Save short version of simulation results:
            Chronos{kk,nn,jj} = SummarizeInfections(SimuPop);
            Quar_tot(kk,nn,jj) = sum(SimuPop.Calc.Quarantined,...
                'all','omitnan')/t;
            Test_tot(kk,nn,jj) = SimuPop.TestCounter/t;
        end
    end
    
end

% Save mat file with generic name:
strid = datestr(now,30);
save(['entryTRUE',strid,'.mat']);

