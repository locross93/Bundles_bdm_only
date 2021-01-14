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

%mixed effects analysis while treating subject as a random effect
all_subj_data = table(y,X_full(:,1),X_full(:,2),all_subIDs,'VariableNames',{'BundleValue','LItemValue','RItemValue','Subject'});
%lme = fitlme(tbl,'BundleValue ~ 1 + LItemValue + RItemValue + (1|Subject)')
lme = fitlme(all_subj_data,'BundleValue ~ 1 + LItemValue + RItemValue + (-1 + RItemValue|Subject) + (-1 + LItemValue|Subject) + (1|Subject)');

writetable(all_subj_data,'all_subj_data.csv');