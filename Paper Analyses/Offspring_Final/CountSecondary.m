function counts_sec = CountSecondary(SimuPop)

% counts_sec = CountSecondary(SimuPop)
%
% Counts secondary infections of primary infector. Checks whether primary
% infector is in clinic for at least 25 days and infection occurred 25
% days before end of simulation.

chrono = SummarizeInfections(SimuPop);
if isempty(chrono)
    counts_sec = [];
else
    t_init = chrono(1,1);
    inf_init = chrono(1,4);
    % Count secondary cases if infection occured:
    %   1. Long enough before end of simulation
    %   2. Agent stays in clinic long enough
    if ((t_init - SimuPop.Calc.StartDay(inf_init,SimuPop.GlobalDay) < 25) ...
            || (SimuPop.Calc.ClassID(inf_init,SimuPop.GlobalDay) ~= 1)) ...
            && (SimuPop.GlobalDay - t_init > 25) 
        counts_sec = sum(chrono(:,3) == inf_init);
    else
        counts_sec = [];
    end
end
    
end

