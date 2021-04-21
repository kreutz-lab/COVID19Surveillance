function [chronology,eventnames] = SummarizeInfections(SimuPop)

% [chronology,eventnames] = SummarizeInfections(SimuPop)
%
% Produces summary of infection events in population.
%
% Output:
%
% eventnames: Names of infection channels
% chronology: Chronological infection history
%       First column: Day of infection
%       Second column: Which infection event
%       Third column: Infected by ...
%       Fourth column: UniqueID of newly infected

t = SimuPop.GlobalDay;
eventnames = {'init','joinclinic','default','afterwork',...
    'defaultoutside','visit','noinfection'};

causes = SimuPop.Calc.InfectionCause(:,t);
times = SimuPop.Calc.InfectionDay(:,t);
uniqueids = SimuPop.Calc.UniqueID(:,t);
spreader = SimuPop.Calc.InfectionBy(:,t);
empties = isnan(times);

infected = uniqueids(~empties);
times = times(~empties);
causes = causes(~empties);
spreader = spreader(~empties);

[times,q_sort] = sort(times);
causes = causes(q_sort);
spreader = spreader(q_sort);
infected = infected(q_sort);

if isempty(times)
    chronology = [];
else
    chronology(:,1) = times;
    chronology(:,2) = causes;
    chronology(:,3) = spreader;
    chronology(:,4) = infected;
end

end
   

