
%% power
modelfun = @(b,x)b(1) + b(2)*x(:,1).^b(3) + ...
    b(4)*x(:,2).^b(5);
beta0 = [0 1 1 1 1];
y = all_subj_data{:,1};
X = all_subj_data{:,2:3};
group = all_subj_data{:,4};
%mdl = fitnlm(X,y,modelfun,beta0)

[beta_power,PSI,stats_power,B] = nlmefit(X,y,group,[],modelfun,beta0);

u_power = modelfun(beta_power, tempx);

% modelfun = @(b,x)b(1) + b(2)*x.^b(3);
% beta0 = [0 1 1];
% mdl = fitnlm(X_sum,y,modelfun,beta0)
% 
% X_sort = sort(X,2);
% modelfun = @(b,x)b(1) + b(2)*x(:,1).^b(3) + ...
%     b(4)*x(:,2).^b(5);
% beta0 = [0 1 1 1 1];
% mdl = fitnlm(X_sort,y,modelfun,beta0)

%% logarithmic 
modelfun = @(b,x)b(1) + b(2)*log(b(3)+x(:,1)) + b(4)*log(b(5)+x(:,2));
beta0 = [1 1 1 1 1];
%mdl = fitnlm(X,y,modelfun,beta0)
[beta_log,PSI,stats_log,B] = nlmefit(X,y,group,[],modelfun,beta0);

%u_log = mdl.feval(x1,x2);
u_log = modelfun(beta_log, tempx);


%% polynomial
% modelfun = @(b,x) b(1) + b(2)*x(:,1).^2 + b(3)*x(:,2).^2 + b(4)*x(:,1).^3 + b(5)*x(:,2).^3; 
% beta0 = [0 1 1 1 1];
% 
% %mdl = fitnlm(X,y,modelfun,beta0)
% 
% [beta_poly,PSI,stats_poly,B] = nlmefit(X,y,group,[],modelfun,beta0);
% 
% tempx = [x1; x2]';
% u_poly = modelfun(beta_poly, tempx);
% 
% 
lme = fitlme(all_subj_data,['BundleValue ~ 1+ LItemValue + LItemValue^2 + RItemValue + RItemValue^2 + (1|Subject) + (LItemValue|Subject)+ (LItemValue^2|Subject) + (RItemValue|Subject)+ (RItemValue^2|Subject)']);
coefs = lme.Coefficients.Estimate;

u_poly = coefs(1) + x1*coefs(2) + x2*coefs(3) + x1*coefs(4) + x2*coefs(5);

%%
% norm
modelfun = @(b,x) b(1)+ b(2)*(x(:,1)+x(:,2))./ (b(3) + x(:,1)+x(:,2));
beta0 = [0 1 1];
y = all_subj_data{:,1};
X = all_subj_data{:,2:3};
group = all_subj_data{:,4};
%mdl = fitnlm(X,y,modelfun,beta0)

[beta_norm,PSI,stats_norm,B] = nlmefit(X,y,group,[],modelfun,beta0);
u_norm = modelfun(beta_norm, tempx);

%% linear 
lme = fitlme(all_subj_data,'BundleValue ~ 1 + LItemValue + RItemValue + (RItemValue|Subject) + (LItemValue|Subject) + (1|Subject)');
coefs = lme.Coefficients.Estimate;
u_linear = coefs(1) + x1*coefs(2) + x2*coefs(3);

%% plot

%plot bundle value vs sum of individual values
figure(10);
clf
sum_of_values = sum(X_full,2);
bdm_bundle_value = y;
%plot(sum_of_values,bdm_bundle_value,'.','MarkerSize',20);
binscatter(sum_of_values,bdm_bundle_value,[20 20])
%colormap(gca,flipud('hot'))
cmap = flipud(colormap(gca,'pink'));
colormap(cmap);
hold on
plot((0:.01:20), (0:.01:20),'k--','MarkerSize',10,'LineWidth',2);
xlabel('Value of Sum of Individual Item Values','FontSize',16);
ylabel('Bundle Value','FontSize',16);
title(sprintf('Bundle Value vs. Linear Sum'),'FontSize',18);
xlim([0 20])
ylim([0 20]);

hold on

x1 = 0:0.01:20;
x2 = 0:0.01:20;
sumx3 = x1+x2;

tempx = [x1; x2]';

under20_inds = find(sumx3 < 21);

plot(sumx3(under20_inds),u_power(under20_inds),'LineWidth',2);
plot(sumx3(under20_inds),u_log(under20_inds),'LineWidth',2);
plot(sumx3(under20_inds),u_linear(under20_inds),'LineWidth',2);
plot(sumx3(under20_inds),u_norm(under20_inds),'LineWidth',2);
legend('Data','Y=X','Power','Logarithmic','Linear','Normalization','Location','northwest')

% %difference between groups
% all_subj_data = table(y,X_full(:,1),X_full(:,2),all_subIDs,bundle_type.','VariableNames',{'BundleValue','LItemValue','RItemValue','Subject','BundleType'});
% lme = fitlme(all_subj_data,'BundleValue ~ 1 + LItemValue + RItemValue + BundleType + LItemValue*BundleType + RItemValue*BundleType')
% lme = fitlme(all_subj_data,'BundleValue ~ 1 + LItemValue + RItemValue + BundleType + LItemValue*BundleType')
% 
% y = all_subj_data{:,1};
% X_sum = sum(X_full, 2);
% all_subj_data2 = table(y,X_sum,all_subIDs,bundle_type.','VariableNames',{'BundleValue','SumItemValues','Subject','BundleType'});
% 
% lme = fitlm(all_subj_data2,'BundleValue ~ 1 + SumItemValues + BundleType + SumItemValues*BundleType')
% 
% scat_inds = find(contains(bundle_type,'Same Item'));
% slm = fitlm(all_subj_data(scat_inds,:),'BundleValue ~ 1 + LItemValue + RItemValue')
% 
% fcat_inds = find(contains(bundle_type,'Food'));
% flm = fitlm(all_subj_data(fcat_inds,:),'BundleValue ~ 1 + LItemValue + RItemValue')
% 
% tcat_inds = find(contains(bundle_type,'Trinket'));
% tlm = fitlm(all_subj_data(tcat_inds,:),'BundleValue ~ 1 + LItemValue + RItemValue')
% 
% mcat_inds = find(contains(bundle_type,'Mixed'));
% mlm = fitlm(all_subj_data(mcat_inds,:),'BundleValue ~ 1 + LItemValue + RItemValue')
% 
% 
% 
% 
% 
% fcat_inds = find(contains(bundle_type,'Food'));
% flm = fitlm(all_subj_data2(fcat_inds,:),'BundleValue ~ 1 + SumItemValues')
% 
% tcat_inds = find(contains(bundle_type,'Trinket'));
% tlm = fitlm(all_subj_data2(tcat_inds,:),'BundleValue ~ 1 + SumItemValues')
% 
% mcat_inds = find(contains(bundle_type,'Mixed'));
% mlm = fitlm(all_subj_data2(mcat_inds,:),'BundleValue ~ 1 + SumItemValues')