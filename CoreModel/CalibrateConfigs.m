function [cfg,profile_eff] = CalibrateConfigs(cfgRandom,profile_eff)

% [cfg,profile_eff] = CalibrateConfigs(cfgRandom,profile_eff)
%
% Derive calibrated parameters from parameter struct cfgRandom and create
% struct. Use this after calling InitRandomConfigs.
%
% Input:
%
% cfgRandom: Parameter struct from InitRandomCinfigs.
% profile_eff: Integrated infectiousness profile value, total
%       "infectiousness". If it is not specified, it will be calibrated
%       by this function. 
%
% Output:
%
% cfg: Struct containing the final parameters necessary for analyses.
% profile_eff: Use this output as input for next iterations to skip the
%       specific calibration. This variable only depends on a few parameters.

cfg = cfgRandom;

% Calibrate Infection Structure Matrix:
rmod = cfgRandom.modifierRisk;
cfg.matrixInfectionStructure = [1,1/rmod,1,rmod;1/rmod,1,1,1;...
        1,1,1,1;rmod,1,1,1];

% Make individual infectivity distribution:
indiv_dist = makedist('Gamma','a',cfg.infectivityShape,...
    'b',1/cfg.infectivityShape);
cfg.infectivityDist = indiv_dist;

% Calibrate effective integrated profile by simulation. 
if ~exist('profile_eff','var') || isempty(profile_eff)
    profile_eff = CalibrateTotalInfec(cfg);
end
% profile_eff = (cfg.SymptomMean-mean(cfg.InfectiousShift))/2;
% Analytical expression, which is inaccurate because of truncated
% distributions

% Contact Rate calibrated to give right R0:
N_eff = cfg.nPatients+cfg.nWorkers;
baseContact = cfg.R0/((cfg.baseInfection*N_eff*profile_eff)*...
    (cfg.fracAsymp*cfg.asympInfec_rel+1-cfg.fracAsymp));

% Build conctact and infection matrix:
% Heterogeneity breaks calibrated R0, this is also corrected
probRisk = cfg.probRisk;
fracClass = [cfg.nPatients,cfg.nWorkers*probRisk]/N_eff;
matrixMixing = NaN(length(fracClass),length(fracClass));
for ii = 1:length(fracClass)
    for jj = 1:length(fracClass)
        matrixMixing(ii,jj) = fracClass(ii)*fracClass(jj);
    end
end
HeteroCorrection = sum(cfg.matrixInfectionStructure.*...
    cfg.matrixContactStructure.*matrixMixing,'all');
matrixContact = baseContact*cfg.matrixContactStructure;
matrixInfection = cfg.baseInfection*cfg.matrixInfectionStructure/...
    HeteroCorrection;

cfg.baseContact = baseContact;
cfg.modifierAfterWork = cfg.contactsAfterWork*cfg.pInitInfec;
cfg.modifierLeave = cfg.contactsLeave*cfg.pInitInfec;
cfg.modifierVisit = cfg.contactsVisit*cfg.pInitInfec;
cfg.fracClass = fracClass;
cfg.matrixInfection = matrixInfection;
cfg.matrixContact = matrixContact;
cfg.joinAverage = cfg.nPatients/cfg.leaveTime;
cfg.maxPatients = cfg.nPatients+5;

end

function profile_eff = CalibrateTotalInfec(cfg)

% Draw random disease courses and calculate integrated infectiousness
% numerically.

n = 5*10^3;
profile_effs = NaN(1,n);

for ii = 1:n
    [~,~,profile_effs(ii)] = CourseOfDisease(cfg);
end

profile_eff = mean(profile_effs);

end

