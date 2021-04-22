function SimuPop = DrawPopulation(cfg,zeroinfec) 

% SimuPop = DrawPopulation(cfg,zeroinfec)
%
% Draw population from specific parameter set in struct cfg, obtained by
% calling:
%
% cfgHyper = InitHyperConfigs;
% cfgRandom = InitRandomConfigs(cfgHyper);
% cfg = CalibrateConfigs(cfgRandom);
%
% zeroinfec = 1 (default) initiates the clinic with zero infected agents. 
% If zeroinfec = 0, infections are initialized in the clinic in a random not
% symptomatic state with the relative number of cases having the expectation
% pInitInfec.

np = cfg.nPatients;
nw = cfg.nWorkers;

if ~exist('zeroinfec','var')
    zeroinfec = 1;
end

if zeroinfec == 1
    pInitOld = cfg.pInitInfec;
    cfg.pInitInfec = 0;
end

% List agent properties:
SimuPop = struct('cfg',cfg,'GlobalDay',1,'WeekDay',randi(7,1),'TestCounter',0);
SimuPop.PropNames = ...
    {'UniqueID','PurposeID','RiskID','StateID','StartDay','Presence','LeaveTimer',...
    'LeaveLength','LastLeaveTimer','DiseaseDay','TestDelayTimer','InfectionBy',...
    'Quarantined','QuarantineTimer','InfectionCause','InfectionDay','ClassID',...
    'TestResults','Tracing','Compliance'};
SimuPop.PropNames = sort(SimuPop.PropNames);
c = cell(1,length(SimuPop.PropNames));
SimuPop.Calc = cell2struct(c',SimuPop.PropNames');
SimuPop.Calc.Infectivity = {};
SimuPop.Calc.DiseaseCourse = {};

% Add Agents to Clinic (this should be vectorized, currently efficiency
% bottleneck when population is drawn in each simulation)
for ii = 1:(np+nw)
        
    if ii < np + 1
        SimuPop = AddAgent(SimuPop,'initpatient',2);
    else
        if ii < np + 1 + floor(cfg.probRisk(1)*nw)
            SimuPop = AddAgent(SimuPop,'initworker',1);
        elseif ii < np + 1 + floor((cfg.probRisk(1) + ...
                cfg.probRisk(2))*nw)
            SimuPop = AddAgent(SimuPop,'initworker',2);
        else
            SimuPop = AddAgent(SimuPop,'initworker',3);
        end
    end
end

if zeroinfec == 1
    cfg.pInitInfec = pInitOld;
end

end
