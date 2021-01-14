%Initialize workspace
clearvars;
clc;

%Specify script parameters
%which subjects to analyze
subID_cell = {'101','102','103','104','105','106'...
    ,'107','108','109','110','111','112','113','114'}; 

y = [];
X_full = [];
all_subIDs = [];
for i=1:length(subID_cell)
    subID = subID_cell{i};
    for day=1:3
        subID_day = [subID,'-',num2str(day)];
        temp_file = ['logs/bdm_items_sub_',subID_day,'.mat'];
        load(temp_file)
        bdm_item_value = value;
        bdm_item = item;
        temp_file = ['logs/bdm_bundle_sub_',subID_day,'.mat'];
        load(temp_file)
        bdm_bundle_value = value;
        bdm_bundle = item;

        y = [y; bdm_bundle_value];
        X = zeros(length(bdm_bundle_value), 2);
        %create a array of subID to put in table
        subID_array = str2num(subID(2:3))*ones(length(bdm_bundle_value),1);

        for j=1:length(bdm_bundle_value)
            temp_bundle = bdm_bundle(j,:);
            left_item_ind = find(bdm_item == temp_bundle(1));
            X(j,1) = bdm_item_value(left_item_ind);
            right_item_ind = find(bdm_item == temp_bundle(2));
            X(j,2) = bdm_item_value(right_item_ind);
        end
        X_full = [X_full; X];
        all_subIDs = [all_subIDs; subID_array];
    end
end

mdl = fitlm(X_full,y,'VarNames',{'LeftItem','RightItem','BundleValue'});

figure();
PredictedValues=feval(mdl,X_full);
plot(PredictedValues,y,'.','MarkerSize',20);
hold on
plot(0:22,0:22)
xlabel('Predicted bundle value from LM');
ylabel('Actual bundle value');
title('Regression Fit', 'FontSize', 14)
grid on
xlim([0 22])
ylim([0 22])

%mixed effects analysis while treating subject as a random effect
tbl = table(y,X_full(:,1),X_full(:,2),all_subIDs,'VariableNames',{'BundleValue','LItemValue','RItemValue','Subject'});
%lme = fitlme(tbl,'BundleValue ~ 1 + LItemValue + RItemValue + (1|Subject)')
lme = fitlme(tbl,'BundleValue ~ 1 + LItemValue + RItemValue + (-1 + RItemValue|Subject) + (-1 + LItemValue|Subject) + (1|Subject)');

[beta,betanames,stats] = fixedEffects(lme);
[B,Bnames,stats] = randomEffects(lme);
temp_subjs = 5:12;
rfx_tbl_betas = table(temp_subjs',B(17:24)+beta(1),B(9:16)+beta(2),B(1:8)+beta(3),'VariableNames',{'Subject','Intercept','LItemCoef','RItemCoef'});

%plot bundle value vs sum of individual values
fig2 = figure;
sum_of_values = sum(X_full,2);
%plot(sum_of_values,bdm_bundle_value,'.','MarkerSize',20);
y = binscatter(sum_of_values,y,[20 20]);
colormap(gca,'parula')
hold on
plot((0:.01:20), (0:.01:20),'MarkerSize',10);
xlabel('Value of Sum of Individual Item Values','FontSize',16);
ylabel('Bundle Value','FontSize',16);
title(sprintf('Bundle Value vs. Linear Sum - All Subjects'),'FontSize',18);
xlim([0 20])
ylim([0 20]);

%food and trinket regression
% y = [];
% X_full = [];
% all_subIDs = [];
% for i=1:length(subID_cell)
%     subID = subID_cell{i};
%     temp_file = ['logs/bdm_items_sub_',subID,'.mat'];
%     load(temp_file)
%     bdm_item_value = value;
%     bdm_item = item;
%     temp_file = ['logs/bdm_bundle_sub_',subID,'.mat'];
%     load(temp_file)
%     bdm_bundle_value = value;
%     bdm_bundle = item;
%     
%     food_bundle_inds = find(bdm_bundle(:,1) < 100 & bdm_bundle(:,2) < 100);
%     trinket_bundle_inds = find(bdm_bundle(:,1) > 100 & bdm_bundle(:,2) > 100);
%     all_inds = 1:length(bdm_bundle);
%     mix_bundle_inds = setdiff(all_inds, union(food_bundle_inds, trinket_bundle_inds))';
%     
%     y = [y; bdm_bundle_value(mix_bundle_inds)];
%     X = zeros(length(bdm_bundle_value(mix_bundle_inds)), 2);
%     %create a array of subID to put in table
%     subID_array = str2num(subID(2:3))*ones(length(bdm_bundle_value(mix_bundle_inds)),1);
% 
%     for j=1:length(bdm_bundle_value(mix_bundle_inds))
%         ind = mix_bundle_inds(j);
%         temp_bundle = bdm_bundle(ind,:);
%         if temp_bundle(1) < 100
%             food_ind = find(bdm_item == temp_bundle(1));
%         elseif temp_bundle(1) > 100
%             trinket_ind = find(bdm_item == temp_bundle(1));
%         end
%         if temp_bundle(2) < 100
%             food_ind = find(bdm_item == temp_bundle(2));
%         elseif temp_bundle(2) > 100
%             trinket_ind = find(bdm_item == temp_bundle(2));
%         end
%         X(j,1) = bdm_item_value(food_ind);
%         X(j,2) = bdm_item_value(trinket_ind);
%     end
%     X_full = [X_full; X];
%     all_subIDs = [all_subIDs; subID_array];
% end
% 
% mdl = fitlm(X_full,y)
% 
% figure();
% PredictedValues=feval(mdl,X_full);
% plot(PredictedValues,y,'.','MarkerSize',20);
% hold on
% plot(0:21,0:21)
% xlabel('Predicted bundle value from LM');
% ylabel('Actual bundle value');
% title('Regression Fit', 'FontSize', 14)
% grid on
% xlim([0 21])
% ylim([0 21])
% 
% %mixed effects analysis while treating subject as a random effect
% tbl = table(y,X_full(:,1),X_full(:,2),all_subIDs,'VariableNames',{'BundleValue','FoodValue','TrinketValue','Subject'});
% %lme = fitlme(tbl,'BundleValue ~ 1 + FoodValue + TrinketValue + (1|Subject)')
% lme = fitlme(tbl,'BundleValue ~ 1 + FoodValue + TrinketValue + (-1 + FoodValue|Subject) + (-1 + TrinketValue|Subject) + (1|Subject)');
% 
% [beta,betanames,stats] = fixedEffects(lme);
% [B,Bnames,stats] = randomEffects(lme);
% temp_subjs = 5:12;
% rfx_tbl_betas = table(temp_subjs',B(17:24)+beta(1),B(9:16)+beta(2),B(1:8)+beta(3),'VariableNames',{'Subject','Intercept','TrinketCoef','FoodCoef'});