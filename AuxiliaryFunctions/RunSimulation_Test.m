% Skeleton simulation code to start a simulation with customized properties
% and scenarios.

nsimu = 10; % Number of simulations
scens = 1; % Number of scenarios
t = 100; % Duration of simulation (days)
Pops = cell(scens,nsimu); % Cell array for structs of full population
Chronos = cell(scens,nsimu); % Cell array for infection chronologies 
Quar_tot = NaN(scens,nsimu); % Average number of quarantine in simulation
Test_tot = NaN(scens,nsimu); % Average number of tests in simulation

for jj = 1:nsimu
    % Loop over simulation number
    
    clearvars -EXCEPT jj kk mm nsimu t scens SimuPop_start...
        Quar_tot Test_tot profile_eff Chronos Pops
    
    % Initialize model parameters and population
    cfgHyper = InitHyperConfigs;
    cfgRandom = InitRandomConfigs(cfgHyper,2); 
        %Set all parameters to best estimate
    if ~exist('profile_eff','var')
        [cfg,profile_eff] = CalibrateConfigs(cfgRandom);
    else
        cfg = CalibrateConfigs(cfgRandom,...
            profile_eff);
        % profile_eff is numerically calibrated. This is skipped if a value
        % is provided.
    end
    SimuPop_start = DrawPopulation(cfg);
    
    for nn = 1:scens
        
        %Start from the same population for all scenarios
        SimuPop = SimuPop_start;
        
        for ii = 2:t
            %Conduct Simulation
            
            SimuPop = ProgressDay(SimuPop);
            
            if SimuPop.WeekDay == 6
                %Leave clinic for the weekend
                q_who = (SimuPop.Calc.PurposeID(:,ii) == 1);
                q_who = q_who & (rand(size(q_who)) < SimuPop.cfg.fracWeekend);
                SimuPop = ConductEvent(SimuPop,'leave',q_who,2);
            end
            
        end
        
        % Save information from simulation
        Chronos{nn,jj} = SummarizeInfections(SimuPop);
        Quar_tot(nn,jj) = sum(SimuPop.Calc.Quarantined,'all','omitnan')/t;
        Test_tot(nn,jj) = SimuPop.TestCounter/t;
        Pops{nn,jj} = SimuPop; %Delete if many simulations are conducted
        
    end
end
