% Generates the data for the comparison of the three active strategies to
% baseline surveillance and their dependence on different test
% sensitivities

% If the seed is not shuffled, results of simulations will be the same
% if conducted directly after starting a new instance of MATLAB
rng('shuffle')

% Add relevant folders with the necessary functions
addpath(genpath(pwd));

nsimu = 5000; % Number of simulations
scens = 4; % Number of Strategies
senses = [50,60,70,80,90,100]/100;
t = 100; % Number of Simulation Days
Chronos = cell(length(senses),scens,nsimu);
Quar_tot = NaN(length(senses),scens,nsimu);
Test_tot = NaN(length(senses),scens,nsimu);

% Prepare replacements of effective infectiousness which are introduced by
% modifying related disease course parameters.

cfgHyper = InitHyperConfigs;
cfgRandom = InitRandomConfigs(cfgHyper,2);
[~,profile_eff] = CalibrateConfigs(cfgRandom);

for jj = 1:nsimu
    
    clearvars -EXCEPT jj mm nsimu t scens senses SimuPop_start...
        Quar_tot Test_tot profile_eff Chronos
    
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
    cfg = CalibrateConfigs(cfgRandom,...
            profile_eff);
    SimuPop_start = DrawPopulation(cfg);
    
    for mm = 1:length(senses)
        % Loop over different sensitivities
        
        for nn = 1:scens
            % Loop over different strategies
            
            SimuPop = SimuPop_start;
            cfgRandom.testSensitivity = senses(mm);
            cfg = CalibrateConfigs(cfgRandom,profile_eff);
            SimuPop.cfg = cfg;
            
            for ii = 2:t
                % Conduct Simulation according to defined
                % specifications
                
                SimuPop = ProgressDay(SimuPop);
                
                if (nn == 2) || (nn == 3) || (nn == 4)
                    % Entry Testing
                    
                    q_who_base = (SimuPop.Calc.Quarantined(:,ii) == 0);
                    
                    q_who = (SimuPop.Calc.LastLeaveTimer(:,ii) == 0) | ...
                        (SimuPop.Calc.LastLeaveTimer(:,ii) == 5);
                    q_who = q_who & q_who_base;
                    SimuPop = ConductEvent(SimuPop,'test',q_who);
                    
                    if (nn == 3) || (nn == 4)
                        % Test every Friday
                        if SimuPop.WeekDay == 5
                            q_who = (SimuPop.Calc.Compliance(:,ii) == 1);
                            q_who = q_who & q_who_base;
                            SimuPop = ConductEvent(SimuPop,'test',q_who);
                        end
                        
                        if nn == 4
                            % Test every Tuesday
                            if SimuPop.WeekDay == 2
                                q_who = (SimuPop.Calc.Compliance(:,ii) == 1);
                                q_who = q_who & q_who_base;
                                SimuPop = ConductEvent(SimuPop,'test',q_who);
                            end
                        end
                    end
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
            Chronos{mm,nn,jj} = SummarizeInfections(SimuPop);
            Quar_tot(mm,nn,jj) = sum(SimuPop.Calc.Quarantined,...
                'all','omitnan')/t;
            Test_tot(mm,nn,jj) = SimuPop.TestCounter/t;
        end
    end
    
end

% Save mat file with generic name:
strid = datestr(now,30);
save(['sensisTRUE',strid,'.mat']);

