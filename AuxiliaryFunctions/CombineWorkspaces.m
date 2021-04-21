% Combines outputs across simulations.
%
% Copy function corresponding results folder and replace search for right
% string

directory = dir;
ind_files = strmatch('prevalence',{directory.name});
results = cell(1,length(ind_files));

for ii = 1:length(ind_files)
    results{ii} = load(directory(ind_files(ii)).name);
end

nsimu = results{1}.nsimu;
t = results{1}.t;
kk_cases = results{1}.kk_cases;
casenames = results{1}.casenames;

Chronos = {};
Quar_tot = [];
Test_tot = [];
for ii = 1:length(ind_files)
    Chronos = cat(4,Chronos,results{ii}.Chronos);
    Quar_tot = cat(4,Quar_tot,results{ii}.Quar_tot);
    Test_tot = cat(4,Test_tot,results{ii}.Test_tot);
end

clear directory ind_files results ii