function bool = isOutbreak(chrono,tthresh,infthresh)

% bool = isOutbreak(chrono,tthresh,infthresh)
%
% Checks whether an outbreak has occurred. An outbreak is defined as
% infthresh infected agents in the clinic during a time span of tthresh
% days.

% Takes chronology of infections (obtained by SummarizeInfections) as input
% instead of the whole population. The rationale behind this is the
% following: Population structs of many simulation runs can lead to large
% files, while Chronologies are much smaller in size, hence Chronologies 
% are saved. But isOutbreak can not already be conducted in the simulation, 
% since it is desirable that threshold parameters can be changed without 
% running new simulations.

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

