%plot bundle value vs sum of individual values
fig2 = figure;
%sum_of_values = sum(X_full,2);
sum_of_values = sum(X,2);
bdm_bundle_value = y;
%plot(sum_of_values,bdm_bundle_value,'.','MarkerSize',20);
binscatter(sum_of_values,bdm_bundle_value,[20 20])
%colormap(gca,flipud('hot'))
cmap = flipud(colormap(gca,'pink'));
colormap(cmap);
hold on
%plot((0:.01:20), (0:.01:20),'r','MarkerSize',10,'LineWidth',2);
plot((0:.01:20), (0:.01:20),'--k');
xlabel('Value of Sum of Individual Item Values','FontSize',16);
ylabel('Bundle Value','FontSize',16);
title(sprintf('Bundle Value vs. Linear Sum'),'FontSize',18);
xlim([0 20])
ylim([0 20]);

hold on

plot(sumx3(under20_inds),u_power(under20_inds),'LineWidth',2);
plot(sumx3(under20_inds),u_log(under20_inds),'LineWidth',2);
plot(sumx3(under20_inds),u_linear(under20_inds),'LineWidth',2);
legend('Data','Y=X','Power','Logarithmic','Linear','Location','northwest')