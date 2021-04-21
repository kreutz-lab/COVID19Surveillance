function SimuPop = AddAgent(SimuPop,whichcircumstance,RiskID)
% Add a new individual to the clinic.

q_infec = (rand(1) < SimuPop.cfg.pInitInfec);
if ~isempty(SimuPop.Calc.UniqueID)
    UniqueID = size(SimuPop.Calc.UniqueID,1)+1;
else
    UniqueID = 1;
end

ag = struct('UniqueID',UniqueID);
ag.RiskID = RiskID;

if q_infec == 1
    [DiseaseCourse,Infectivity] = CourseOfDisease(SimuPop.cfg);
    q_nosymp = (DiseaseCourse == 2) | (DiseaseCourse == 3) | ...
        (DiseaseCourse == 4);
    dayofdisease = randi(sum(q_nosymp),1);
    ag.DiseaseDay = dayofdisease;
    ag.StateID = DiseaseCourse(dayofdisease);
else
    ag.StateID = 1;
    Infectivity = [];
    DiseaseCourse = [];
    ag.DiseaseDay = NaN;
    ag.InfectionCause = NaN;
    ag.InfectionDay = NaN;
end

if strcmp(whichcircumstance,'joinclinic')
    
    ag.PurposeID = 1;
    ag.RiskID = 2;
    ag.StartDay = SimuPop.GlobalDay;
    ag.LastLeaveTimer = 0;

    if q_infec == 1
        ag.InfectionCause = 2;
        ag.InfectionDay = SimuPop.GlobalDay-1;
    end
    
end

if (strcmp(whichcircumstance,'initpatient') == 1) || ...
        (strcmp(whichcircumstance,'initworker') == 1)
    
    ag.LastLeaveTimer = NaN;
    
    if strcmp(whichcircumstance,'initpatient') == 1    
        ag.PurposeID = 1;
        ag.StartDay = -randi(SimuPop.cfg.leaveTime-1);
    elseif strcmp(whichcircumstance,'initworker') == 1
        ag.PurposeID = 2;
        ag.StartDay = NaN;
    end
    
    if q_infec == 1
        ag.InfectionCause = 1;
        ag.InfectionDay = 0;
    end
end


ag.Compliance = (rand(1) < SimuPop.cfg.compliance);
ag.Presence = 1;
ag.LeaveTimer = NaN;
ag.LeaveLength = NaN;
ag.Quarantined = 0;
ag.QuarantineTimer = 0;
ag.TestDelayTimer = NaN;
ag.InfectionBy = NaN;
ag.TestResults = NaN;
ag.Tracing = 0;

if ag.PurposeID == 1
        ag.ClassID = 1;
else
    if ag.RiskID == 1
        ag.ClassID = 2;
    elseif ag.RiskID == 2
        ag.ClassID = 3;
    else
        ag.ClassID = 4;
    end       
end

calc_old = rmfield(SimuPop.Calc,{'DiseaseCourse','Infectivity'});
ag = orderfields(ag,calc_old);
DiseaseCourse_old = SimuPop.Calc.DiseaseCourse;
Infectivity_old = SimuPop.Calc.Infectivity;

fieldstrings = fieldnames(calc_old);
for ii = 1:length(fieldstrings)
    if ~strcmp(whichcircumstance,'joinclinic')
        SimuPop.Calc.(fieldstrings{ii}) = [calc_old.(fieldstrings{ii});...
            ag.(fieldstrings{ii})];
    else
        SimuPop.Calc.(fieldstrings{ii}) = [calc_old.(fieldstrings{ii});...
            [NaN(1,SimuPop.GlobalDay-1),ag.(fieldstrings{ii})]];
    end
end

if ~isempty(DiseaseCourse_old)
    SimuPop.Calc.DiseaseCourse = [DiseaseCourse_old,{DiseaseCourse}];
    SimuPop.Calc.Infectivity = [Infectivity_old,{Infectivity}];
else
    SimuPop.Calc.DiseaseCourse = {DiseaseCourse};
    SimuPop.Calc.Infectivity = {Infectivity};
end

end

