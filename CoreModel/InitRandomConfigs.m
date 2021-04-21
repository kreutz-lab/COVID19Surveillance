function cfgRandom = InitRandomConfigs(cfgHyper,mode)

% cfgRandom = InitRandomConfigs(cfgHyper,mode)
%
% Fixes all hyper parameters to only one value per variable. Use
% InitHyperConfigs before calling this function. Follow this function by
% CalibrateConfigs to initialize derived parameters.
%
% Input:
%
% cfgHyper: From InitHyperConfigs
% mode: Flag to determine how parameters are drawn from hyper parameters:
%       (1): Draw random from sensitivity values
%       (2): Fix all sensitivity values to best estimate
%
% Output:
%
% cfgRandom: Contains all single parameter values as fields.

if ~exist('mode','var')
    mode = 1;
end

% Carry all fixed values over:
cfgRandom = cfgHyper.Fixed;

% Draw random parameters from distributions:
fnames = fieldnames(cfgHyper.Uniform);
discretelist = {'nPatients','nWorkers'};
for ii = 1:length(fnames)
    if sum(strcmp(fnames{ii},discretelist)) > 0
            cfgRandom.(fnames{ii}) = ...
                randi(cfgHyper.Uniform.(fnames{ii}),1);
    else
        cfgRandom.(fnames{ii}) = ...
            DrawUniform(cfgHyper.Uniform.(fnames{ii}));
    end
end

% Takes values from sensitivity parameters as specified in mode:
fnames = fieldnames(cfgHyper.Sensitivity);
for ii = 1:length(fnames)
    if mode == 1
        cfgRandom.(fnames{ii}) = ...
            cfgHyper.Sensitivity.(fnames{ii})(randi([1,3],1));
    else
        cfgRandom.(fnames{ii}) = ...
            cfgHyper.Sensitivity.(fnames{ii})(2);
    end
end

% Add middle value of scenarios:
fnames = fieldnames(cfgHyper.Scenario);
for ii = 1:length(fnames)
    cfgRandom.(fnames{ii}) = ...
        cfgHyper.Scenario.(fnames{ii})(2);
end

end

    