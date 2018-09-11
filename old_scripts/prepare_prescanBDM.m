function prepare_prescanBDM(subID)
%% prepare_prescanBDM('999-1')

close all;

exc_food_ids = [];
exc_trinket_ids = [];
inc_food_ids = [];
inc_trinket_ids = [];

num_day_items = 20;
num_runs = 5;

num_food = 56;
num_trinket = 29;
day_idx = str2num(subID(end));
subj = str2num(subID(1:3));
subj_seed = 121 + subj;

rng(subj_seed)
food_ids = randperm(num_food);
rng(subj_seed)
trinket_ids = randperm(num_trinket);

str_ind = (day_idx*5) + 1;
end_ind = (day_idx+1)*5;

%%take the first 5 items (for food and trinkets) for each day
%%and take additional 5 new items each day 

item_ids = zeros(num_day_items/2,2);

item_ids(:,1) = [food_ids(1:5), food_ids(str_ind:end_ind)];
item_ids(:,2) = [trinket_ids(1:5), trinket_ids(str_ind:end_ind)];

%Prepare BDM ITEM

%randomize the ordering of all the items for BDM Item
%add 100 to the trinket IDs to distinguish them
bdm_item_seq = [item_ids(:,1); item_ids(:,2) + 100];
idx_rnd = randperm(length(bdm_item_seq));
bdm_item_seq = bdm_item_seq(idx_rnd);

%Prepare BDM ITEM
%get combinations of all items
%create a N x 2 array of item pairs, starting with each item paired
%with itself
day_food_list = item_ids(:,1)';
day_trinket_list = item_ids(:,2)';
combo_list = [[day_food_list';day_trinket_list'],[day_food_list';day_trinket_list']];
all_items = [day_food_list, day_trinket_list];
temp_combos = nchoosek(all_items, 2);
combo_list = [combo_list; temp_combos];

%make half of the trials have food on left half with food on right
half_num = length(combo_list)/2;
lr_conds = [ones(1,half_num)*1, ones(1,half_num)*2];
idx_rnd = randperm(half_num*2);
lr_conds = lr_conds(idx_rnd);

%randomize the ordering
num_trials = length(combo_list);
idx_rnd = randperm(num_trials);
bundle_list = combo_list(idx_rnd,:);
lr_conds = lr_conds(idx_rnd);
num_trials = length(bundle_list);

%flip the left right order of bundles with condition 2 
for i=1:num_trials
    if lr_conds(i) == 2
        bundle_list(i,:) = fliplr(bundle_list(i,:));
    end
end


%Prepare 5 CHOICE RUNS

%four repetitions of the same object
%use -1 in the second column to distinguish individual item condition
item_repeat = [all_items, all_items, all_items, all_items];
temp_negones = -1 * ones(length(item_repeat),1);
item_trials = [item_repeat', temp_negones];

%mix item and bundle trials together randomly
choice_item_seq = [item_trials; bundle_list];
idx_rnd = randperm(length(choice_item_seq));
choice_item_seq = choice_item_seq(idx_rnd,:);






% %%take the first 5 items (for food and trinkets) for each day
% %%and take additional 5 new items each day 
% for i = 1:num_days
%     str_ind = (i*5) + 1;
%     end_ind = (i+1)*5;
%     item_id_sub{i,1} = [food_ids(1:5), food_ids(str_ind:end_ind)];
%     item_id_sub{i,2} = [trinket_ids(1:5), trinket_ids(str_ind:end_ind)];
% end
% 

f_name = ['data/bdm_item_id_sub_',subID];
if isequal(exist([f_name,'.mat'],'file'),0)
    save(f_name,'item_id_sub');
    disp('Done!')
else
    disp('WARNING: The file already exists!')
end

end