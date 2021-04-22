function SimuPop = AddAgent(SimuPop,whichcircumstance,RiskID)

% SimuPop = AddAgent(SimuPop,whichcircumstance,RiskID)
%
% This function adds a new individual to the clinic.
%
% SimuPop: Current Population
% whichcircumstance: String which specifies which agent is added to the 
%   clinic: 
%       - 'initpatient': Adds a patient when population is initialized
%       - 'initworker: Adds a worker when population is initialized
%       - 'joinclinic': Adds a newly admitted patient
% RiskID: Identifier to which risk class individual belongs

% Simulate infection status from prevalence:
q_infec = (rand(1) < SimuPop.cfg.pInitInfec);
% Define unique identifier:
if ~isempty(SimuPop.Calc.UniqueID)
    UniqueID = size(SimuPop.Calc.UniqueID,1)+1;
else
    UniqueID = 1;
end

% Define agent struct:
ag = struct('UniqueID',UniqueID);
ag.RiskID = RiskID;

% Set disease related properties if agent is infected:
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

% Set properties for patient admission:
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

%Set properties for initialized agent:
if (strcmp(whichcircumstance,'initpatient') == 1) || ...
        (strcmp(whichcircumstance,'initworker') == 1)
    
    ag.LastLeaveTimer = NaN;
    
    if strcmp(whichcircumstance,'initpatient') == 1    
        ag.PurposeID = 1;
        ag.StartDay = -randi(SimuPop.cfg.leaveTime-1);
        % Randomize admission day such that not all patients leave at once
    elseif strcmp(whichcircumstance,'initworker') == 1
        ag.PurposeID = 2;
        ag.StartDay = NaN;
    end
    
    if q_infec == 1
        ag.InfectionCause = 1;
        ag.InfectionDay = 0;
    end
end

% Initialize all other properties:
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

% Define agent class from RiskID and PurposeID
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

% Stratify non-scalar field values from scalar ons 
calc_old = rmfield(SimuPop.Calc,{'DiseaseCourse','Infectivity'});
ag = orderfields(ag,calc_old);
DiseaseCourse_old = SimuPop.Calc.DiseaseCourse;
Infectivity_old = SimuPop.Calc.Infectivity;

% Add scalar field values to SimuPop.Calc
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

% Add cell field values to SimuPop.Calc
if ~isempty(DiseaseCourse_old)
    SimuPop.Calc.DiseaseCourse = [DiseaseCourse_old,{DiseaseCourse}];
    SimuPop.Calc.Infectivity = [Infectivity_old,{Infectivity}];
else
    SimuPop.Calc.DiseaseCourse = {DiseaseCourse};
    SimuPop.Calc.Infectivity = {Infectivity};
end

end

