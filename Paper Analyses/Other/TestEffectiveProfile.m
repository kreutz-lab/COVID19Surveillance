% Test which sensitvity parameters have an influence on the expected total 
% infectiousnessover the infectivity profile. SymptomMean has a large 
% effect, IncubationMean has a small effect. 

cfgHyper = InitHyperConfigs;
cfgRandom = InitRandomConfigs(cfgHyper,2);

strs = {'IncubationMean','SymptomMean'};
reps = 20;
remap = [1,3];
profile_eff = NaN(2,length(strs));
peffs = NaN([size(profile_eff),reps]);

for kk = 1:reps
    for ii = 1:length(strs)
        for jj = 1:2
            cfgRandom.(strs{ii}) = ...
                cfgHyper.Sensitivity.(strs{ii})(remap(jj));
            [~,profile_eff(jj,ii)] = CalibrateConfigs(cfgRandom);
        end
        cfgRandom.(strs{ii}) = cfgHyper.Sensitivity.(strs{ii})(2);
    end
    peffs(:,:,kk) = profile_eff;
end

mus = mean(peffs,3);
sds = std(peffs,[],3)/sqrt(reps);

save('EffectiveProfileSensi.mat')