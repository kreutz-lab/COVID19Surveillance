% Generates the data for the impact of test frequency and compliance on
% outbreak probability.
%
% Code is mainly copy-pasted from "FourStrategiesRun", so refer to this
% script for comments on basic structure.

rng('shuffle')

currentpath = cd;
addpath(genpath(currentpath));

cfgHyper = InitHyperConfigs;
casenames = {'testSensitivity','compliance'};
    % Only Sensitivity/Compliance as parameters
kk_cases = length(casenames);
remap = [1,2,3];
nsimu = 3000;
scens = 8;
t = 100;
Chronos = cell(kk_cases,3,scens,nsimu);
Quar_tot = NaN(kk_cases,3,scens,nsimu);
Test_tot = NaN(kk_cases,3,scens,nsimu);

profile_eff_matrix = NaN(3,3);
strs = {'SymptomMean','IncubationMean'};
cfgRandom = InitRandomConfigs(cfgHyper,2);
for ii = 1:3
    for jj = 1:3
        cfgRandom.(strs{1}) = ...
            cfgHyper.Sensitivity.(strs{1})(ii);
        cfgRandom.(strs{2}) = ...
            cfgHyper.Sensitivity.(strs{2})(jj);
        [~,profile_eff_matrix(ii,jj)] = CalibrateConfigs(cfgRandom);
    end
end

for jj = 1:nsimu
    
    clearvars -EXCEPT jj kk mm nsimu t scens remap casenames SimuPop_start...
        Quar_tot Test_tot kk_cases profile_eff_matrix Chronos OldCompliance
    
    cfgHyper = InitHyperConfigs;
    cfgRandom = InitRandomConfigs(cfgHyper,2);
    cfgRandom.testDelay = cfgHyper.Scenario.testDelay(1);
    cfgRandom.minQuarantine = cfgHyper.Scenario.minQuarantine(1);
    cfgRandom.maxQuarantine = cfgHyper.Scenario.maxQuarantine(2);
    cfgRandom.retestfreq = cfgHyper.Scenario.retestfreq(2);
    cfg = CalibrateConfigs(cfgRandom,...
        profile_eff_matrix(2,2));
    SimuPop_start = DrawPopulation(cfg);
    OldCompliance = SimuPop_start.Calc.Compliance(:,1);
    
    for kk = 1:kk_cases
        
        for mm = 1:length(remap)
            
            if strcmp(casenames{kk},'compliance')
                SimuPop_start.Calc.Compliance = ...
                    rand(size(SimuPop_start.Calc.Compliance)) < ...
                    cfgHyper.Sensitivity.compliance(remap(mm));
            else
                SimuPop_start.Calc.Compliance = OldCompliance;
            end
            
            for nn = 1:scens
                
                SimuPop = SimuPop_start;
                
                cfgRandom.(casenames{kk}) = ...
                    cfgHyper.Sensitivity.(casenames{kk})(remap(mm));
                
                if strcmp(casenames(kk),'SymptomMean')
                    cfg = CalibrateConfigs(cfgRandom,...
                        profile_eff_matrix(remap(mm),2));
                elseif strcmp(casenames(kk),'IncubationMean')
                    cfg = CalibrateConfigs(cfgRandom,...
                        profile_eff_matrix(remap(mm),2));
                else
                    cfg = CalibrateConfigs(cfgRandom,...
                        profile_eff_matrix(2,2));
                end
                SimuPop.cfg = cfg;
                
                cfgRandom.(casenames{kk}) = ...
                    cfgHyper.Sensitivity.(casenames{kk})(2);
                
                for ii = 2:t
                    
                    SimuPop = ProgressDay(SimuPop);
                    
                    q_who_base = (SimuPop.Calc.Quarantined(:,ii) == 0);
                    
                    % Entry Testing:
                    q_who = (SimuPop.Calc.LastLeaveTimer(:,ii) == 0) | ...
                        (SimuPop.Calc.LastLeaveTimer(:,ii) == 5);
                    q_who = q_who & q_who_base;
                    SimuPop = ConductEvent(SimuPop,'test',q_who);
                    
                    % Test every nn days (or never for nn = 8)
                    if nn ~= 8
                        if rem(SimuPop.GlobalDay,nn) == 0 
                            q_who = (SimuPop.Calc.Compliance(:,ii) == 1);
                            q_who = q_who & q_who_base;
                            SimuPop = ConductEvent(SimuPop,'test',q_who);
                        end
                    end
                    
                    if SimuPop.WeekDay == 6
                        q_who = (SimuPop.Calc.PurposeID(:,ii) == 1);
                        q_who = q_who & (rand(size(q_who)) < ...
                            SimuPop.cfg.fracWeekend);
                        SimuPop = ConductEvent(SimuPop,'leave',q_who,2);
                    end
                end
                
                Chronos{kk,mm,nn,jj} = SummarizeInfections(SimuPop);
                Quar_tot(kk,mm,nn,jj) = sum(SimuPop.Calc.Quarantined,...
                    'all','omitnan')/t;
                Test_tot(kk,mm,nn,jj) = SimuPop.TestCounter/t;
            end
        end
        
    end
end

strid = datestr(now,30);
save(['freqsys',strid,'.mat']);