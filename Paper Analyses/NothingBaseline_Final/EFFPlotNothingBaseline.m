% load('NothingBaseline35Data.mat');
%
% For comments, refer to EFFPlotSensis. Script works exactly the same, but 
% additionally undoes the special status of some parameters.

f = figure('Position',[150,150,1500,700]);
subs = NaN(1,2);
xlims = NaN(2,2);

subs(1) = subplot(1,2,1);
FFPlotSensisCompare(Outbreak_tot3,casenames,[2,1],1,1);
legend('off')
ylabel('Model Parameters','FontSize',16);
yticklabs = get(subs(1),'YTickLabels');
yticklabs{end-1} = 'HeterogeneityModifier \sl h_{mod}';
yticklabs{end} = 'TestCompliance';
set(subs(1),'YTickLabels',yticklabs);

title('Baseline - No Surveillance, N_{out} = 3');
xlims(1,:) = get(gca,'XLim');

subs(2) = subplot(1,2,2);
FFPlotSensisCompare(Outbreak_tot5,casenames,[2,1],1,1);
set(gca,'YTickLabel',[]);
title('Baseline - No Surveillance, N_{out} = 5');
xlims(2,:) = get(gca,'XLim');

pos = NaN(2,4);
subaxes = get(gcf,'Children');
xlim_new = [min(xlims(:,1)),max(xlims(:,2))];
for ii = 1:2
    set(subs(ii),'XLim',xlim_new);
    if ii == 2
        line([NaN,NaN],[NaN,NaN],'Color',[0,0,0],'LineWidth',1.5);
    end
    xaxis_handle = get(subs(ii),'XAxis');
    set(xaxis_handle,'FontSize',13,'Linewidth',1.4);
    yaxis_handle = get(subs(ii),'YAxis');
    set(yaxis_handle,'FontSize',13,'LineWidth',1.4);
    xlab_handle = get(subs(ii),'XLabel');
    set(xlab_handle,'FontSize',16);
    ylab_handle = get(subs(ii),'YLabel');
    set(ylab_handle,'FontSize',16);
    
    childs = get(subs(ii),'Children');
    set(childs(8),'MarkerFaceAlpha',0.2);
    set(childs(9),'MarkerFaceAlpha',0.2);

end

leg = get(subs(2),'Legend');
strs = get(leg,'String');
strs{6} = 'Ratio Best Parameters';
set(leg,'String',strs);

all_objs = get(subs(2),'Children');
all_names = get(all_objs,'DisplayName');
q_objs = ~cellfun(@isempty,all_names);
leg_objs = all_objs(q_objs);
names_objs = all_names(q_objs);
names_objs{2} = 'No Surveillance';
permu = [2,1,6,5,4,3];
legend(leg_objs(permu),names_objs(permu),'FontSize',12);
leg_pos = get(leg,'Position');
set(leg,'Position',leg_pos+[0.04,0,0,0]);

% For some reason the plot has to be executed here first before the position
% manipulation works as expected. This is why the "pause" is necessary.
pause(1);

pos(1,:) = get(subaxes(2),'Position');
pos(2,:) = get(subaxes(3),'Position');

del = 0.8*(pos(1,1) - pos(2,1) - pos(1,3));
pos(1,1) = pos(1,1) - del;
for ii = 1:2
    set(subaxes(ii+1),'Position',pos(ii,:));
end