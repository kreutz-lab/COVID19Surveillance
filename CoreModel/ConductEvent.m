function SimuPop = ConductEvent(SimuPop,whichevent,q_who,vararg)

% Collection of different events which can be conducted. 
%
% 'default': Infection in clinic.
% 'defaultoutside': Infection when on temproal leave.
% 'test': Put people in quarantine when result positive.
% 'afterwork': Infection of worker after shift.
% 'leave': Set temporal leave.
% 'visit': Infection of patients who get visited

% Specify scenario-specific q_who as argument. For example: Who gets
% tested is a property of the scenario, not the general simulation. 

calc =  SimuPop.Calc;
t = SimuPop.GlobalDay;

if strcmp(whichevent,'default')
% Default Event is a possible infection by other agents in the clinic
% within a day.
    
    whicheventID = 3;

    q_inf = ((calc.StateID(:,t) == 3) |  (calc.StateID(:,t) == 4) | ...
        (calc.StateID(:,t) == 5)) & ...
        (calc.Quarantined(:,t) == 0) & (calc.Presence(:,t) == 1);
    % Infectious Agents
    
    if sum(q_inf) == 0
        return
    end
    
    q_hel = (calc.StateID(:,t) == 1) & (calc.Presence(:,t) == 1) & ...
        (calc.Quarantined(:,t) == 0);
    % Agents which can be infected
    
    if sum(q_hel) == 0
        return
    end    
    
    p_indivs = NaN(sum(q_inf),sum(q_hel));
    p_health = ones(size(q_hel));
    
    % Calculate infection probability between one infected and one healthy
    % individual:
    ClassID_hel = calc.ClassID(q_hel,t);
    inds_inf = find(q_inf == 1);    
    for ii = 1:sum(q_inf)
       ClassID_inf = calc.ClassID(inds_inf(ii),t);
       contact_tmp = SimuPop.cfg.matrixContact(ClassID_hel,ClassID_inf);
       infec_tmp = SimuPop.cfg.matrixInfection(ClassID_hel,ClassID_inf);
       tempo_tmp = calc.Infectivity{inds_inf(ii)};
       tempo_tmp = tempo_tmp(calc.DiseaseDay(inds_inf(ii),t));
       p_indivs(ii,:) = contact_tmp.*infec_tmp.*tempo_tmp;
    end
    
    % Total probability of staying healthy:
    p_health(q_hel) = prod(1-p_indivs,1);

elseif strcmp(whichevent,'test')
    % Test agents for disease. 
    
    % Scenario-specific
    
    q_test = (calc.Presence(:,t) == 1) & q_who & ...
        (isnan(calc.TestDelayTimer(:,t)));
    % only test if there is not already a pending test result
    
    q_detec = ((calc.StateID(:,t) == 3) |  (calc.StateID(:,t) == 4) | ...
        (calc.StateID(:,t) == 5)) & q_test;    
    q_nodetec = ((calc.StateID(:,t) == 1) |  (calc.StateID(:,t) == 2) | ...
        (calc.StateID(:,t) == 6)) & q_test;    
    % q_detec: True Positive Possibility
    % q_nodetec: False Positive Probability
    
    q_detec = q_detec & (rand(length(q_detec),1) < SimuPop.cfg.testSensitivity);
    q_nodetec = q_nodetec & (rand(length(q_detec),1) > SimuPop.cfg.testSpecificity);
    q_pos = q_detec | q_nodetec;
    % Count all Positives
    SimuPop.Calc.TestDelayTimer(q_test,t) = 0;
    % TestDelayTimer tracks delay of test to result
    SimuPop.Calc.TestResults(q_pos & q_test,t) = 1;
    SimuPop.Calc.TestResults(~q_pos & q_test,t) = 0;
    % TestResults tracks state of last test performed, 0 if tested
    % negative, 1 if tested positive, NaN for no test available
    % Knowledge about result only once delay is over
    SimuPop.TestCounter = SimuPop.TestCounter + sum(q_test);
    
    return
    
elseif strcmp(whichevent,'afterwork')
    % Evaluate the additional infection risk of workers getting infected
    % after their shift. 
    %
    % Use a generic risk modifier.
    
    whicheventID = 4;
    
    q_hel = (calc.PurposeID(:,t) == 2) & (calc.StateID(:,t) == 1) & ...
        (calc.Presence(:,t) == 1);
    p_health = ones(size(q_hel));
    p_health(q_hel) = (1-SimuPop.cfg.modifierAfterWork*...
        SimuPop.cfg.baseInfection)*ones(1,sum(q_hel));

elseif strcmp(whichevent,'leave')
    % Set the properties of individuals who are leaving the clinic
    % temporarily.
    
    % Scenario-specific
    
    q_leave = (calc.Presence(:,t) == 1) & (calc.Quarantined(:,t) == 0) & q_who;
    
    SimuPop.Calc.LeaveTimer(q_leave,t) = 1;
    SimuPop.Calc.LeaveLength(q_leave,t) = vararg;
    SimuPop.Calc.Presence(q_leave,t) = 0;
    
    return
    
elseif strcmp(whichevent,'defaultoutside')
    % Evaluate the infection risk of people who are on temporal leave.
    % Generic modifier for all absent agents.
    
    whicheventID = 5;
    
    q_hel = (calc.Presence(:,t) == 0) & (calc.StateID(:,t) == 1);
    
    p_health = ones(size(q_hel));
    p_health(q_hel) = 1-SimuPop.cfg.modifierLeave*SimuPop.cfg.baseInfection;

elseif strcmp(whichevent,'visit')    
    
    whicheventID = 6;
    
    q_hel = (calc.Presence(:,t) == 1) & (calc.StateID(:,t) == 1) & ...
        (calc.Quarantined(:,t) == 0) & (calc.PurposeID(:,t) == 1);
    q_hel = q_hel & (rand(size(q_hel)) < SimuPop.cfg.fracVisit);
    
    p_health = ones(size(q_hel));
    p_health(q_hel) = 1-SimuPop.cfg.modifierVisit*SimuPop.cfg.baseInfection;
    
else
    disp('Chosen Eventname does not exist');
end

% Simulate whether infections occur given probabilities p_health:
q_infection = (rand(size(p_health)) > p_health);
if sum(q_infection) == 0
    return
end
% Note that t+1 only makes sense because infection functions are only
% called in ProgressDay, which adds the t+1-column before going from t to
% t+1.
ind_infection = find(q_infection);
for ii = 1:sum(q_infection)
   [SimuPop.Calc.DiseaseCourse{ind_infection(ii)},...
    SimuPop.Calc.Infectivity{ind_infection(ii)}] = CourseOfDisease(SimuPop.cfg); 
    SimuPop.Calc.StateID(ind_infection(ii),t+1) = ...
        SimuPop.Calc.DiseaseCourse{ind_infection(ii)}(1);
    % If infection in clinic, draw who spread the infection: 
    if whicheventID == 3
        % Transform infection index to infection index on healthy people
        % only:
        ind_hel_tmp = sum(q_hel(1:ind_infection(ii)));
        % For an agent who got infected, the unnormalized probabilities of 
        % infection from any infectious individual are given by:
        weights_tmp = p_indivs(:,ind_hel_tmp);
        % Select spreader by drawing from multinomial:
        SimuPop.Calc.InfectionBy(ind_infection(ii),t+1) = ...
            inds_inf(logical(mnrnd(1,weights_tmp/sum(weights_tmp))));
    end
end
SimuPop.Calc.DiseaseDay(q_infection,t+1) = 1;
SimuPop.Calc.InfectionCause(q_infection,t+1) = whicheventID;
SimuPop.Calc.InfectionDay(q_infection,t+1) = t;
    
end
