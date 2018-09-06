
all_subIDs = {'005-1','006-1','007-1','008-1','009-1','010-1','011-1','012-1'};
num_subjs = length(all_subIDs);

item_mean = zeros(num_subjs,1);
item_var = zeros(num_subjs,1);
bundle_mean = zeros(num_subjs,1);
bundle_var = zeros(num_subjs,1);

for i=1:num_subjs
    subID = all_subIDs{i};
    %load item data
    temp_file = ['logs/bdm_items_sub_',subID,'.mat'];
    load(temp_file)
    bdm_item_value_orig = value;
    no_response_ind=bdm_item_value_orig==100;
    bdm_item_value=bdm_item_value_orig(~no_response_ind);
    item_mean(i) = mean(bdm_item_value);
    item_var(i) = var(bdm_item_value);
    
    
    %load bundle data
    temp_file = ['logs/bdm_bundle_sub_',subID,'.mat'];
    load(temp_file)
    bdm_bundle_value_orig = value;
    no_response_ind=bdm_bundle_value_orig==100;
    bdm_bundle_value=bdm_bundle_value_orig(~no_response_ind);
    bundle_mean(i) = mean(bdm_bundle_value);
    bundle_var(i) = var(bdm_bundle_value);
end

T = table(all_subIDs',item_mean, item_var, bundle_mean, bundle_var);