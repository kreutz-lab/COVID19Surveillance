function SimuPop = ProgressDay(SimuPop)

% SimuPop = ProgressDay(SimuPop)
%
% Simulates dynamics from GlobalDay to GlobalDay+1.
%
% Agent states:
% 0: N (Left Clinic)
% 1: S (Susceptible)
% 2: E (Exposed)
% 3: I_P (Presymptomatic)
% 4: I_A (Asymptomatic)
% 5: I_S (Symptomatic)
% 6: R (Recovered)

t = SimuPop.GlobalDay;

%% Append agent column for day t+1:

calc_old = rmfield(SimuPop.Calc,{'DiseaseCourse','Infectivity'});
fieldstrings = fieldnames(calc_old);
for ii = 1:length(fieldstrings)
    SimuPop.Calc.(fieldstrings{ii}) = [SimuPop.Calc.(fieldstrings{ii}),...
        SimuPop.Calc.(fieldstrings{ii})(:,t)];
end

%% Progress permanently absent agents:

q_permleave = (t - SimuPop.Calc.StartDay(:,t) == SimuPop.cfg.leaveTime);
SimuPop.Calc.StateID(q_permleave,t+1) = 0;
SimuPop.Calc.Presence(q_permleave,t+1) = 0;
SimuPop.Calc.Quarantined(q_permleave,t+1) = 0;
q_permgone = (SimuPop.Calc.StateID(:,t) == 0) | q_permleave;

%% Progress disease states:

q_sick = (SimuPop.Calc.StateID(:,t) == 2) | ...
    (SimuPop.Calc.StateID(:,t) == 3) | (SimuPop.Calc.StateID(:,t) == 4) | ...
    (SimuPop.Calc.StateID(:,t) == 5);
ind_tmp = find(q_sick&~q_permgone);
if ~isempty(ind_tmp)
    for ii = 1:sum(q_sick & ~q_permgone)
        % Vectorization hard because of the structure of DiseaseCourse
        dis_day = SimuPop.Calc.DiseaseDay(ind_tmp(ii),t)+1;
        SimuPop.Calc.DiseaseDay(ind_tmp(ii),t+1) = dis_day;
        course_tmp = SimuPop.Calc.DiseaseCourse{ind_tmp(ii)};
        if dis_day > length(course_tmp)
            SimuPop.Calc.StateID(ind_tmp(ii),t+1) = 6;
        else
            SimuPop.Calc.StateID(ind_tmp(ii),t+1) = course_tmp(dis_day);
        end
    end
end

%% Manage quarantine of people (new or existing) on day t:

SimuPop = ProcessQuarantine(SimuPop,~q_permgone);

%% Simulate infections on day t:

SimuPop = ConductEvent(SimuPop,'default'); %default within clinic
SimuPop = ConductEvent(SimuPop,'defaultoutside'); %default outside of clinic
SimuPop = ConductEvent(SimuPop,'visit'); %new infections by visits
SimuPop = ConductEvent(SimuPop,'afterwork'); %staff after their shift

%% Progress temporary leave states:

q_pres = (SimuPop.Calc.Presence(:,t) == 1);
q_nonpres = (~q_pres) & (~q_permgone);

% Progress Last-Leave-Timer:
SimuPop.Calc.LastLeaveTimer(q_nonpres,t+1) = NaN;
SimuPop.Calc.LastLeaveTimer(q_pres,t+1) = ...
    SimuPop.Calc.LastLeaveTimer(q_pres,t) + 1;
% Progress Leave-Timer:
SimuPop.Calc.LeaveTimer(q_nonpres,t+1) = ...
    SimuPop.Calc.LeaveTimer(q_nonpres,t) + 1;
% Reset returning individuals:
q_comeback = q_nonpres & (SimuPop.Calc.LeaveTimer(:,t) == ...
    SimuPop.Calc.LeaveLength(:,t));
SimuPop.Calc.Presence(q_comeback,t+1) = 1;
SimuPop.Calc.LeaveTimer(q_comeback,t+1) = 0;
SimuPop.Calc.LeaveLength(q_comeback,t+1) = NaN;
SimuPop.Calc.LastLeaveTimer(q_comeback,t+1) = 0;

%% Progress day counters:

SimuPop.GlobalDay = SimuPop.GlobalDay + 1;
if SimuPop.WeekDay == 7
    SimuPop.WeekDay = 1;
else
    SimuPop.WeekDay = SimuPop.WeekDay + 1;
end

%% Add newly admitted patients:

N_open = SimuPop.cfg.maxPatients - ...
    sum((SimuPop.Calc.PurposeID(:,t) == 1) & (~q_permgone));
N_init = SimuPop.cfg.maxPatients - SimuPop.cfg.nPatients;
newpatients = random('Binomial',N_open,SimuPop.cfg.joinAverage/N_init,1);
% Patient admission increases with number of unoccupied postions N_open,
% guarantees that population is not depleted by patients ending their stay

if newpatients ~= 0
    for ii = 1:newpatients
        SimuPop = AddAgent(SimuPop,'joinclinic',2);
    end
end

end

