function SimuPop = ProcessQuarantine(SimuPop,q_who)

% SimuPop = ProcessQuarantine(SimuPop,q_who)
% 
% Processes actions on the population structed related to quarantine. It is
% called during ProgressDay.
%
% q_who corresponds to individuals which have not permanently left the
% clinic.

t = SimuPop.GlobalDay;

%% Identify first order targets for quarantine:

% Test results are accessible:
q_result = (SimuPop.Calc.TestDelayTimer(:,t) == SimuPop.cfg.testDelay)  & ...
    q_who;
% Accessible result is positive:
q_pos = q_result & (SimuPop.Calc.TestResults(:,t) == 1);
% Tested positive in active surveillance testing:
q_quar_test = q_pos & (SimuPop.Calc.Quarantined(:,t) == 0);
% Tested first time positive in quarantine to indicate individuals for
% contact tracing:
if t > 1
    if SimuPop.cfg.testDelay ~= 0
        q_firstpos = q_pos;
    else
        % Tracing is delayed by 1 day if test delay is 0 to make it work 
        q_firstpos = (SimuPop.Calc.TestResults(:,t) == 1) & ...
            (SimuPop.Calc.TestDelayTimer(:,t-1) == 0);
    end
    q_firstpos = q_firstpos & (SimuPop.Calc.Quarantined(:,t) == 1) & ...
        (SimuPop.Calc.Tracing(:,t) == 0);
else
    q_firstpos = zeros(size(q_pos));
end
% Symptomatic non-quarantined individuals:
q_quar_symp = (SimuPop.Calc.StateID(:,t) == 5) & ...
    (SimuPop.Calc.Quarantined(:,t) == 0) & q_who;
% Fake symptomatic individuals:
n_clinic = SimuPop.cfg.nPatients + SimuPop.cfg.nWorkers;
q_fakesymp = PickRandomExisting(q_who,...
    binornd(n_clinic,SimuPop.cfg.fracIso*...
    SimuPop.cfg.expectedFalseAlarms/n_clinic));
q_quar_symp = q_fakesymp | q_quar_symp;
% Symptomatic patients returning from leave are covered by the symptomatic
% isolation strategy before they have a chance to infect
q_quar_symp = q_quar_symp & (rand(size(q_quar_symp)) < SimuPop.cfg.fracIso);

%% Identify second order targets for quarantine:

% Contact-Tracing for first-time positively tested: 
q_prime = q_quar_test | q_firstpos;

ind_qprime = find(q_prime);
q_trace = zeros(size(q_quar_test));
if ~isempty(ind_qprime)
    for ii = 1:length(ind_qprime)
        % Backward-tracing:
        ind_prime_inf = SimuPop.Calc.InfectionBy(ind_qprime(ii),t);
        q_traceback_tmp = zeros(size(q_trace));
        if ~isnan(ind_prime_inf)
            q_traceback_tmp(ind_prime_inf) = 1;
        end
        % Forward-tracing:
        q_trace_tmp = (SimuPop.Calc.InfectionBy(:,t) == ind_qprime(ii));
        q_trace_tmp = ((q_trace_tmp | q_traceback_tmp) & ...
            (rand(size(q_trace_tmp)) < SimuPop.cfg.fracTrace));
        
        % False traces
        q_faketrace_tmp = ...
            PickRandomExisting(q_who,...
            binornd(n_clinic,...
            SimuPop.cfg.fracTrace*...
            SimuPop.cfg.expectedFalseTraces/n_clinic));
        % Scale False Tracing with Tracing efficiency
        
        q_trace = q_trace | q_trace_tmp | q_faketrace_tmp;
    end
end
q_quar_trace = (q_trace & q_who & ...
    (SimuPop.Calc.Quarantined(:,t) == 0));

% Save which agents initiated contact tracing and which were traced; these
% can not initiate another tracing round as long as they are in quarantine
% "first order tracing"
SimuPop.Calc.Tracing(:,t+1) = q_prime | ...
    (SimuPop.Calc.Tracing(:,t) == 1);

%% Process Quarantine for identified targets:

q_quarenter = q_quar_test | q_quar_symp | q_quar_trace;

% If people should be quarantined by any measures, they are brought back
% into the clinc and quarantined. Since this is 100% effective, the
% transfer back into the clinic is for convenient handling.
q_return = (SimuPop.Calc.Presence(:,t) == 0) & q_quarenter;
SimuPop.Calc.Presence(q_return,t) = 1;
SimuPop.Calc.LeaveTimer(q_return,t) = 0;
SimuPop.Calc.LeaveLength(q_return,t) = NaN;
SimuPop.Calc.LastLeaveTimer(q_return,t) = 0;

SimuPop.Calc.Quarantined(q_quarenter,t) = 1;
SimuPop.Calc.Quarantined(q_quarenter,t+1) = 1;
% The Quarantine comes into effect immediately, not only at day t+1. 
% Infections on day t are already prevented.

%% Dismiss agents from quarantine:

q_quarleave = ((SimuPop.Calc.QuarantineTimer(:,t) == ...
    SimuPop.cfg.maxQuarantine) | ...
    (q_result & (SimuPop.Calc.TestResults(:,t) == 0)));
SimuPop.Calc.Quarantined(q_quarleave,t) = 0;
SimuPop.Calc.Quarantined(q_quarleave,t+1) = 0;
SimuPop.Calc.Tracing(q_quarleave,t+1) = 0; 
% Tracing ability gets reset once relased from quarantine; expecially
% important because of false tracings

%% Erase or progess TestDelays:
q_tested = ~isnan(SimuPop.Calc.TestDelayTimer(:,t)) & q_who;
q_await = q_tested & ~q_result;
SimuPop.Calc.TestDelayTimer(q_await,t+1) = ...
    SimuPop.Calc.TestDelayTimer(q_await,t) + 1;
SimuPop.Calc.TestDelayTimer(q_result,t+1) = NaN;

%% Test people who are unconfirmed in quarantine:

% Time difference to first test:
Dif2QuarMin = SimuPop.Calc.QuarantineTimer(:,t) - SimuPop.cfg.minQuarantine;
    % Note that QuarantineTimer is 0 for new quarantine admissions and is 
    % changed to 1 only later
% Retest in quarantine:
q_intervaltest = (rem(Dif2QuarMin,SimuPop.cfg.retestfreq) == 0) & ...
    (Dif2QuarMin > 0); 
% Test immediately once in quarantine:
if (SimuPop.cfg.minQuarantine == 0) || (SimuPop.cfg.minQuarantine == 1)
    q_immediatetest = (SimuPop.Calc.QuarantineTimer(:,t) == 0);
else
    q_immediatetest = zeros(size(Dif2QuarMin));
end
% Also test symptomatic entering individuals immediately
q_immediatetest = q_immediatetest | q_quar_symp; 
q_quartests = (SimuPop.Calc.Quarantined(:,t) == 1) & ... % in quarantine
    ~q_tested & q_who & ... % no pending test result
    (q_intervaltest | Dif2QuarMin == 0 | q_immediatetest); 
    % all possible reasons to get tested
SimuPop = ConductEvent(SimuPop,'test',q_quartests);
SimuPop.Calc.TestResults(q_quartests,t+1) = ...
    SimuPop.Calc.TestResults(q_quartests,t);

% Instantly remove negatively tested again if there is no delay:
if SimuPop.cfg.testDelay == 0
    q_neg = (SimuPop.Calc.TestResults(:,t) == 0) & q_quartests;
    % contains only agents which were not quarantined by testing
    SimuPop.Calc.Quarantined(q_neg,t) = 0;
    SimuPop.Calc.Quarantined(q_neg,t+1) = 0;
    % No specific modifications to QuarantineTimer necessary since it has
    % not been altered yet
    SimuPop.Calc.TestDelayTimer(q_quartests,t+1) = NaN;
    % Reset Timer for those who get out of quarantine 
    SimuPop.Calc.QuarantineTimer(q_neg,t) = 0;
    SimuPop.Calc.QuarantineTimer(q_neg,t+1) = 0;
    SimuPop.Calc.Tracing(q_neg,t+1) = 0;
else
    SimuPop.Calc.TestDelayTimer(q_quartests,t+1) = 1;
end

%% Progress quarantine timer:

q_quar = (SimuPop.Calc.Quarantined(:,t) == 1);
SimuPop.Calc.QuarantineTimer(q_quarenter,t) = 1;
SimuPop.Calc.QuarantineTimer(q_quar,t+1) = ...
    SimuPop.Calc.QuarantineTimer(q_quar,t) + 1;
SimuPop.Calc.QuarantineTimer(q_quarleave,t+1) = zeros(sum(q_quarleave),1);

end

function q_chosen = PickRandomExisting(q_start,number)
% Randomly pick number patients from q_start.

inds_start = find(q_start);
inds_chosen = inds_start(randi(sum(q_start),...
    [number,1]));
q_chosen = zeros(size(q_start));
q_chosen(inds_chosen) = 1;
q_chosen = logical(q_chosen);

end