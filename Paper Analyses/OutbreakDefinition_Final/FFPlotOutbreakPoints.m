% Plots Definition of Outbreak Size Plot. 
%
% load('StepAnalysis.mat');

% Data is from sizes 1:8
% Take only data for sizes 2 to 5:
cutofflow = 2;
cutoffhigh = 5;
mus_remap = mus(cutofflow:cutoffhigh,:);
sigmas_remap = sigmas(cutofflow:cutoffhigh,:);
reremap = remap(cutofflow:cutoffhigh);

% Bring data into gscatter format:
xPLOT = repmat(reremap',[1,4]);
normali = max(mus_remap,[],[1,2]);
yPLOT = log2(mus_remap/normali);
sigmasPLOT = log2(exp(1))*sigmas_remap./mus_remap;
groupPLOT = repmat([1,2,3,4],[length(reremap),1]);

% Plot Data:
clrs = lines(10);
hold on
meansPLOT = gscatter(xPLOT(:),yPLOT(:),groupPLOT(:),clrs(1:4,:),'',30);
sdPLOT = errorbar(xPLOT,yPLOT,sigmas_remap,...
    'LineStyle','none','LineWidth',1.5);
for ii = 1:scens
   clr_tmp =get(meansPLOT(ii),'Color');
   set(sdPLOT(ii),'Color',clr_tmp);
end
hold off

% Modify axes properties:
xlim([xPLOT(1)-0.5,xPLOT(end)+0.5]);
ylim_old = get(gca,'YLim');
ylim([ylim_old(1),0.01]);
xticks(reremap);

grid on
xlabel('Number of Infections Defined as Outbreak N_{out}','FontSize',12);
ylabel('Log2(Relative Outbreak Probability)','FontSize',12);
title('Outbreak Size Definition','FontSize',14);

legend(meansPLOT,{'Baseline','Entry Testing','Once Weekly','Twice Weekly'},...
    'Location','Northeast');

