function SimuPop = InitInfPopulation(cfg)
% SimuPop = InitInfPopulation(cfg)
%
% Initializes a population with one infected individual, drawn randomly
% according to the relative sizes of the agent classes.

% Draw population with no infected individuals
pInfec_old = cfg.pInitInfec;
cfg.pInitInfec = 0;
SimuPop = DrawPopulation(cfg);
SimuPop.cfg.pInitInfec = pInfec_old;
cfg = SimuPop.cfg;

class_inf = find(mnrnd(1,cfg.fracClass)); %class index of infected
inf_ind = find(SimuPop.Calc.ClassID(:,1)-class_inf == 0,1); 
    %Unique ID of infected individual

% Assign disease properties to infected agent:
[SimuPop.Calc.DiseaseCourse{inf_ind},SimuPop.Calc.Infectivity{inf_ind}] = ...
    CourseOfDisease(cfg);
SimuPop.Calc.StateID(inf_ind,1) = SimuPop.Calc.DiseaseCourse{inf_ind}(1);
SimuPop.Calc.DiseaseDay(inf_ind,1) = 1;
SimuPop.Calc.InfectionCause(inf_ind,1) = 1;
SimuPop.Calc.InfectionDay(inf_ind,1) = 0;
if class_inf == 1
    SimuPop.Calc.StartDay(inf_ind,1) = 0;
else
    SimuPop.Calc.StartDay(inf_ind,1)= NaN;
end