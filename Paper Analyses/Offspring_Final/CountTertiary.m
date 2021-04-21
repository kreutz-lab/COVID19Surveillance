function counts_tert = CountTertiary(SimuPop)

% counts_tert = CountTertiary(SimuPop)
%
% Count infections of secondary infected individuals. See CountSecondary
% for details.

chrono = SummarizeInfections(SimuPop);

inf_init = chrono(1,4);
q_sec = (chrono(:,3) == inf_init);
ind_sec = chrono(q_sec,4);
q_keep = ((chrono(q_sec,1) - ...
    SimuPop.Calc.StartDay(ind_sec,SimuPop.GlobalDay) < 25) | ...
     (SimuPop.Calc.ClassID(ind_sec,SimuPop.GlobalDay) ~= 1)) & ...
     (SimuPop.GlobalDay - chrono(q_sec,1) > 25);
ind_sec = ind_sec(q_keep);

if isempty(ind_sec)
    counts_tert = [];
else 
    for ii = 1:length(ind_sec)
        counts_tert(ii) = sum(chrono(:,3) == ind_sec(ii),'omitnan');
    end
end

end

