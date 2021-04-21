% Plots of Course of Disease Time Distributions.

dists = gobjects(3,1);

log2norm_mu = @(mu,sd) log((mu^2)./sqrt(mu^2+sd.^2));
log2norm_sd = @(mu,sd) sqrt(log(1+(sd.^2)/(mu^2)));

del = 1;
ts = 0:del:16;

mu_time = [5.5,5];
sd_time = [2.3,1.5];
qt_time = (ts >= 2) & (ts <= 15);  
pdfs = NaN(2,length(ts));
hold on
for ii = 1:2
    pdf_full_tmp = pdf('logn',ts,log2norm_mu(mu_time(ii),sd_time(ii)),...
        log2norm_sd(mu_time(ii),sd_time(ii)));
    pdfs(ii,qt_time) = pdf_full_tmp(qt_time);
    pdfs(ii,~qt_time) = 0;
    pdfs(ii,ts == 2) = sum(pdf_full_tmp(ts <= 2))*del;
    pdfs(ii,ts == 15) = 1 - sum(pdf_full_tmp(ts < 15))*del;
    dists(ii) = stairs([ts,15,17],[pdfs(ii,:),0,0]);
end

dists(3) = stairs([1,1,2,3,4,5],[0,ones(1,4)/4,0]);
hold off

legend(dists,{'Incubation Time','Symptomatic Time','Presymptomatic Time'});
xlabel('Days','FontSize',12);
ylabel('Probability','FontSize',12);
title('Distributions of Course of Disease Times','FontSize',14)

xticks = ts+0.5;
xlim([0,17]);
xticklabs = strsplit(num2str(ts));
set(gca,'XTick',xticks);
set(gca,'XTickLabel',xticklabs);
set(dists,'LineWidth',2);
set(gca,'XGrid','on');


