function Outbreak_tot = AnalyzeSensis(Chronos,infthresh,tthresh)
% Outbreak_tot = AnalyzeSensis(Chronos,infthresh,tthresh)
%
% Assigns a boolean variable to each simulation stored in Chronos, which is
% a cell array of infection chronologies. An Outbreak is defined as 
% infthresh infections within tthresh days.
%
% Takes chronology of infections (obtained by SummarizeInfections) as input
% instead of the whole population struct. The rationale behind this is the
% following: Population structs of many simulation runs can lead to large
% files, while chronologies are much smaller in size while containing the
% necessary information, hence chronologies are saved in the simulation runs.

isOutbreakDefined = @(x) isOutbreak(x,tthresh,infthresh);
Outbreak_tot = cellfun(isOutbreakDefined,Chronos);

end

function bool = isOutbreak(chrono,tthresh,infthresh)

% bool = isOutbreak(chrono,tthresh,infthresh)
%
% Checks whether an outbreak has occurred. An outbreak is defined as
% infthresh infected agents in the clinic during a time span of tthresh
% days.

nt = size(chrono,1);

if isempty(chrono) || size(chrono,1) < infthresh
    bool = 0;
else
    % Be careful to implement the exact definitions of tthresh and
    % infthresh
    tspan = chrono(infthresh:nt,1) - chrono(1:(nt-(infthresh-1)),1);
    if sum(tspan < tthresh) > 0
        bool = 1;
    else
        bool = 0;
    end
end

end

