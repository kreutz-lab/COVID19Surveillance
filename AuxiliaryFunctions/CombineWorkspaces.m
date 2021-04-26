% Combines outputs across many simulations. This is desirable if many
% simulations of the same scenarios have been generated and need to be
% merged
%
% This is more of a template. Function only works if it is in the same
% folder as all the data sets which is also the directory and the right 
% search string is specified.

directory = dir;
ind_files = strmatch('seriousnew',{directory.name});
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