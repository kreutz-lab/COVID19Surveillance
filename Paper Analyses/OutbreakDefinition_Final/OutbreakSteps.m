scens = size(Chronos,3);
datasize = size(Chronos,1)*size(Chronos,4);
remap = 1:8;
mus = NaN(length(remap),scens);
for ii = 1:length(remap)
    Outbreak_tot = AnalyzeSensis(Chronos,remap(ii),3);
    mus(ii,:) = mean(squeeze(Outbreak_tot(:,2,:,:)),[1,3]);
end
sigmas = sqrt(mus.*(1-mus)/datasize);