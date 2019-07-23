%Initialize workspace
clearvars;
clc;

%Specify script parameters
%which subjects to analyze
subID_cell = {'005-1','006-1','007-1','008-1','009-1','010-1','011-1','012-1'};
num_subjs = length(subID_cell);

% %plot bar graph of all subject medians
% subj_fits = zeros(num_subjs,1);
% subj_betas = zeros(num_subjs,3);
% for i=1:length(subID_cell)
%     y = [];
%     X_full = [];
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
%     y = [y; bdm_bundle_value];
%     X = zeros(length(bdm_bundle_value), 2);
% 
%     for j=1:length(bdm_bundle_value)
%         temp_bundle = bdm_bundle(j,:);
%         left_item_ind = find(bdm_item == temp_bundle(1));
%         X(j,1) = bdm_item_value(left_item_ind);
%         right_item_ind = find(bdm_item == temp_bundle(2));
%         X(j,2) = bdm_item_value(right_item_ind);
%     end
%     X_full = [X_full; X];
%     mdl = fitlm(X_full,y,'VarNames',{'LeftItem','RightItem','BundleValue'});
%     subj_fits(i,1) = mdl.Rsquared.Ordinary;
%     subj_betas(i,:) = mdl.Coefficients.Estimate;
% end

% temp_subjs = 5:12;
% tbl_betas = table(temp_subjs',subj_betas(:,1),subj_betas(:,2),subj_betas(:,3),subj_fits,'VariableNames',{'Subject','Intercept','LItemCoef','RItemCoef','R-Squared'});

% fig1 = figure;
% hold on
% subj_strings = {};
% for i=1:num_subjs
%     subj_strings{end+1} = ['S',num2str(i)];
% end
% bar(1:num_subjs,subj_fits, 'FaceColor',[1 0.55 0], 'EdgeColor',[1 0.55 0])
% set(gca, 'XTick', 1:num_subjs)
% set(gca,'xticklabel',subj_strings)
% ylabel('R-Squared')
% xlabel('Subject')
% title('Individual Differences in Regression Fit (Left and Right Model)', 'FontSize', 12)

%plot bar graph of all subject medians - food/trinket
subj_fits = zeros(num_subjs,1);
subj_betas = zeros(num_subjs,3);
for i=1:length(subID_cell)
    y = [];
    X_full = [];
    subID = subID_cell{i};
    temp_file = ['logs/bdm_items_sub_',subID,'.mat'];
    load(temp_file)
    bdm_item_value = value;
    bdm_item = item;
    temp_file = ['logs/bdm_bundle_sub_',subID,'.mat'];
    load(temp_file)
    bdm_bundle_value = value;
    bdm_bundle = item;
    
    food_bundle_inds = find(bdm_bundle(:,1) < 100 & bdm_bundle(:,2) < 100);
    trinket_bundle_inds = find(bdm_bundle(:,1) > 100 & bdm_bundle(:,2) > 100);
    all_inds = 1:length(bdm_bundle);
    mix_bundle_inds = setdiff(all_inds, union(food_bundle_inds, trinket_bundle_inds))';
    
    y = [y; bdm_bundle_value(mix_bundle_inds)];
    X = zeros(length(bdm_bundle_value(mix_bundle_inds)), 2);

    for j=1:length(bdm_bundle_value(mix_bundle_inds))
        ind = mix_bundle_inds(j);
        temp_bundle = bdm_bundle(ind,:);
        if temp_bundle(1) < 100
            food_ind = find(bdm_item == temp_bundle(1));
        elseif temp_bundle(1) > 100
            trinket_ind = find(bdm_item == temp_bundle(1));
        end
        if temp_bundle(2) < 100
            food_ind = find(bdm_item == temp_bundle(2));
        elseif temp_bundle(2) > 100
            trinket_ind = find(bdm_item == temp_bundle(2));
        end
        X(j,1) = bdm_item_value(food_ind);
        X(j,2) = bdm_item_value(trinket_ind);
    end
    X_full = [X_full; X];
    mdl = fitlm(X_full,y,'VarNames',{'FoodValue','TrinketValue','BundleValue'});
    subj_fits(i,1) = mdl.Rsquared.Ordinary;
    subj_betas(i,:) = mdl.Coefficients.Estimate;
end

temp_subjs = 5:12;
tbl_betas = table(temp_subjs',subj_betas(:,1),subj_betas(:,2),subj_betas(:,3),subj_fits,'VariableNames',{'Subject','Intercept','FoodCoef','TrinketCoef','R-Squared'});

fig1 = figure;
hold on
subj_strings = {};
for i=1:num_subjs
    subj_strings{end+1} = ['S',num2str(i)];
end
bar(1:num_subjs,subj_fits, 'FaceColor',[1 0.55 0], 'EdgeColor',[1 0.55 0])
set(gca, 'XTick', 1:num_subjs)
set(gca,'xticklabel',subj_strings)
ylabel('R-Squared')
xlabel('Subject')
title('Individual Differences in Regression Fit (Food and Trinket Model)', 'FontSize', 12)
