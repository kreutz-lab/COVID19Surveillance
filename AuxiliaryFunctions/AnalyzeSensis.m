function Outbreak_tot = AnalyzeSensis(Chronos,infthresh,tthresh)

isOutbreakDefined = @(x) isOutbreak(x,tthresh,infthresh);
Outbreak_tot = cellfun(isOutbreakDefined,Chronos);

end