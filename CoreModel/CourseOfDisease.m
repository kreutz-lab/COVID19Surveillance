function [states,infectivity_rel,profile_eff] = CourseOfDisease(cfg)
% [states,infectivity_rel,profile_eff] = CourseOfDisease(cfg)
%
% Randomly draws a course of disease for an agent.
%
% states: Vector of disease states 
% infectivity_rel: Time-dependent relative infectivity
% profile_eff: Total relative infectivity, with maximum normalized to 1


% When using the lognormal distribution in Matlab, be aware that the mean
% and standard deviation which need to be specified are not mean and
% standarad deviation of the lognormal distribution, but of the underlying
% normal distribution. Conversion by:
log2norm_mu = @(mu,sd) log((mu^2)./sqrt(mu^2+sd.^2));
log2norm_sd = @(mu,sd) sqrt(log(1+(sd.^2)/(mu^2)));

%% Sample relevant time points from distributions
IncubationTime = round(random('logn',...
    log2norm_mu(cfg.IncubationMean,cfg.IncubationSD),...
    log2norm_sd(cfg.IncubationMean,cfg.IncubationSD),1));
if IncubationTime > 15
    IncubationTime = 15;
elseif IncubationTime < 2
    IncubationTime = 2;
end

SymptomaticTime = round(random('logn',...
    log2norm_mu(cfg.SymptomMean,cfg.SymptomSD),...
    log2norm_sd(cfg.SymptomMean,cfg.SymptomSD),1));
if SymptomaticTime > 15
    SymptomaticTime = 15;
elseif SymptomaticTime < 2
    SymptomaticTime = 2;
end

% Presymptomatic time can not be longer than incubation time:
PresymptomaticShift = randi(cfg.InfectiousShift,1);
if IncubationTime + PresymptomaticShift < 1
    PresymptomaticShift = 1 - IncubationTime;
end
InfectiousStart = IncubationTime+PresymptomaticShift;

%% Set up states from the random time points

% Infected, but not infectious (Exposed):
if InfectiousStart > 1
    states = 2*ones([1,InfectiousStart-1]);
else
    states = [];
end
% Infectious, but not yet symptomatic (Presymptomatic):
states = [states,3*ones([1,IncubationTime-InfectiousStart])];
% Infectious and develop symptoms (Asymptomatic or Symptomatic):
if rand(1) < cfg.fracAsymp
    stateID = 4;
else
    stateID = 5;
end
states = [states,stateID*ones([1,SymptomaticTime])];

%% Calculate infectivity profile from state vector

% At least 1 day of not full infectiousness:
PeakShift = cfg.PeakShift;
if PeakShift < PresymptomaticShift + 1
    PeakShift = PresymptomaticShift + 1;
end
% Peak at least 2 days before end infectiousness:
if PeakShift > SymptomaticTime - 2
    PeakShift = SymptomaticTime - 2;
end

% Define Infecivity Profile:
q_zeros = (states == 2);
q_belowpeak = ((1:length(states)) < IncubationTime+PeakShift); 
n_below = sum((~q_zeros) & q_belowpeak);
n_upper = sum(~q_belowpeak);
infectivity_rel = zeros(1,length(states));
infectivity_rel((~q_zeros) & q_belowpeak) = (1/(n_below+1))*(1:n_below);
infectivity_rel(~q_belowpeak) = (1/(n_upper))*(n_upper:-1:1);

% Total relative infecivity for calibration pruposes:
profile_eff = sum(infectivity_rel); 

% Randomize the scale of infectivity:
if sum(stateID == 4) > 0
    infectivity_rel = cfg.asympInfec_rel*infectivity_rel;
end
infectivity_rel = random(cfg.infectivityDist,1)*infectivity_rel;

end

