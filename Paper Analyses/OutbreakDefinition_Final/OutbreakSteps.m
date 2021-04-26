% Generates the data file 'StepAnalysis.mat' from the data for the
% sensitivity analysis of the four strategies. This corresponds to the
% analysis of varying outbreak sizes
%
% Has to be called from a workspace which contains the infection 
% chronologies ("Chronos"). For the paper, all workspaces of the main
% sensitivity analysis have been combined.

scens = size(Chronos,3);
datasize = size(Chronos,1)*size(Chronos,4);
remap = 1:8; % which outbreak sizes
mus = NaN(length(remap),scens);
for ii = 1:length(remap)
    Outbreak_tot = AnalyzeOutbreak(Chronos,remap(ii),10);
        % Get outbreak data for specific size for 10 days as outbreak
        % paramter
    mus(ii,:) = mean(squeeze(Outbreak_tot(:,2,:,:)),[1,3]);
        % Combine all outbreak probability estimates for the best parameter
        % guess
end
sigmas = sqrt(mus.*(1-mus)/datasize);