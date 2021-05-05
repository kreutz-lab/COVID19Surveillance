% Plots Offspring Distributions Plot from dataset 'OffspringShape.mat'
%
% load('OffspringShape.mat');

maxval = [];
alldata = cell(1,4);
means = cell(1,4);
R0 = SimuPop.cfg.R0;

% Calculates reproduction number:
% means{1} = mean(offspring_sec(1,:),'omitnan');
% means{2} = mean(offspring_sec(2,:),'omitnan');
% means{3} = mean(offspring_tert{1});
% means{4} = mean(offspring_tert{2});

% Prepare raw histogram data for plot:
alldata{1} = histcounts(offspring_sec(1,:));
alldata{2} = histcounts(offspring_sec(2,:));
alldata{3} = histcounts(offspring_tert{1});
alldata{4} = histcounts(offspring_tert{2});

% Define histogram edges for correct plot later:
edgemax = max(cellfun(@length,alldata));
edges = 0:1:(edgemax-1);
edges = [0,edges];
edges = edges-0.5;

% Manipulate data to make nice normalized histogram:
for ii = 1:4
    alldata{ii} = alldata{ii}/sum(alldata{ii});
    if isempty(maxval)
        maxval = max(alldata{ii});
    else
        maxval = max([maxval,max(alldata{ii})]);
    end
    if length(alldata{ii}) < edgemax
        alldata{ii} = [alldata{ii},zeros(1,edgemax-length(alldata{ii}))];
    end
    alldata{ii} = [0,alldata{ii}];
end

% Plot Figure:
f = figure('Position',[150,150,1400,450]);

subplot(1,2,1);
hold on
for ii = [1,3]
    stairs(edges,alldata{ii},'LineWidth',2);
end
line([R0,R0],[0,maxval],'Color','k','LineStyle','--','LineWidth',2);
ylim([0,maxval]);
xlim([-0.5,edgemax-1]);
grid on
xticks(0:(edgemax-1));
xlabel('Infections','FontSize',12);
ylabel('Probability','FontSize',12);
legend({'Secondary','Tertiary','R_0'});
title('Poisson offspring distribution','FontSize',13);
hold off

subplot(1,2,2);
hold on
for ii = [2,4]
    stairs(edges,alldata{ii},'LineWidth',2);
end
line([R0,R0],[0,maxval],'Color','k','LineStyle','--','LineWidth',2);
ylim([0,maxval]);
xlim([-0.5,edgemax-1]);
grid on
xticks(0:(edgemax-1));
xlabel('Infections','FontSize',12);
ylabel('Probability','FontSize',12);
legend({'Secondary','Tertiary','R_0'});
title('Overdispersed offspring distribution','FontSize',13);
hold off

axions = get(gcf,'Children');
delete(axions(3))

for ii = [2,4]
    axes(axions(ii))
    xlim([-0.5,17])
end