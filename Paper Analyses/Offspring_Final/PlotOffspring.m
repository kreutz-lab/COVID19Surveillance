load('OffspringShape.mat');

AnalyzeOffspring;

axions = get(gcf,'Children');
delete(axions(3))

for ii = [2,4]
    axes(axions(ii))
    xlim([-0.5,17])
end