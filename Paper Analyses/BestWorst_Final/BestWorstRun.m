% Generates the data for the comparison of the three active strategies to
% baseline surveillance for a best and worst case parameter set.

% If the seed is not shuffled, results of simulations will be the same
% if conducted directly after starting a new instance of MATLAB
rng('shuffle')

% Add relevant folders with the necessary functions
addpath(genpath(pwd));

nsimu = 20000; % Number of simulations
scens = 4; % Number of Strategies
t = 100; % Number of Simulation Days
Chronos = cell(2,scens,nsimu);
Quar_tot = NaN(2,scens,nsimu);
Test_tot = NaN(2,scens,nsimu);

% Prepare replacements of effective infectiousness which are introduced by
% modifying related disease course parameters.
profile_eff_matrix = NaN(3,1);
cfgHyper = InitHyperConfigs;
cfgRandom = InitRandomConfigs(cfgHyper,2);
for ii = 1:3
    if ii == 1
        cfgRandom.('SymptomMean') = ...
            cfgHyper.Sensitivity.('SymptomMean')(1);
    elseif ii == 2
        cfgRandom.('SymptomMean') = ...
            cfgHyper.Sensitivity.('SymptomMean')(2);
    elseif ii == 3
        cfgRandom.('SymptomMean') = ...
            cfgHyper.Sensitivity.('SymptomMean')(3);
    end
    [~,profile_eff_matrix(ii)] = CalibrateConfigs(cfgRandom);
end

parnames = fieldnames(cfgHyper.Sensitivity);
% Worst and Best case parameter sets:
worst_par = [2,1,2,2,1,1,1,1,1,3,3,3,2,2,2,1,2,2,1];
mid_par =   [2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2];
best_par  = [2,3,2,2,3,3,3,3,3,1,1,1,2,2,2,3,2,2,3];
pars = [worst_par;mid_par;best_par];

for jj = 1:nsimu
    
    clearvars -EXCEPT jj nsimu t scens parnames SimuPop_start...
        Quar_tot Test_tot profile_eff_matrix Chronos ...
        pars
    
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
        profile_eff_matrix(2));
    SimuPop_start = DrawPopulation(cfg);
    
    for kk = 1:3
        % Loop over best and worst case
        
        % Compliant population needs to be reassigned based on value of
        % compliance parameter
        SimuPop_start.Calc.Compliance = ...
            rand(size(SimuPop_start.Calc.Compliance)) < ...
            cfgHyper.Sensitivity.compliance(kk);
        
        for nn = 1:4
            % Loop over different strategies
            
            SimuPop = SimuPop_start;
            
            % Replace parameters in cfg case-dependently:
            for nameindex = 1:length(parnames)
                cfgRandom.(parnames{nameindex}) = ...
                    cfgHyper.Sensitivity.(parnames{nameindex})...
                    (pars(kk,nameindex));
            end
            cfg = CalibrateConfigs(cfgRandom,...
                profile_eff_matrix(kk));
            % Set all parameters in SimuPop:
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
            Chronos{kk,nn,jj} = SummarizeInfections(SimuPop);
            Quar_tot(kk,nn,jj) = sum(SimuPop.Calc.Quarantined,...
                'all','omitnan')/t;
            Test_tot(kk,nn,jj) = SimuPop.TestCounter/t;
        end
    end
    
end

% Save mat file with generic name:
strid = datestr(now,30);
save(['bestworst',strid,'.mat']);

