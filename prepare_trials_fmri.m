%function prepare_trials_fmri(pilot_subID, fmri_subID)
%% prepare_trials_fmri('888-1', '101-1')
pilot_subID='009-1';
fmri_subID='103-1';

num_runs = 5;

f_name = ['data/item_subsample_',pilot_subID];
load(f_name)

f_items_all_days = [];
t_items_all_days = [];

%use the first item in every bin in all 3 scanning days
for bin=1:5
    f_items_all_days = [f_items_all_days; bin_objects_food{bin}(1,1)];
    t_items_all_days = [t_items_all_days; bin_objects_trinket{bin}(1,1)];
end


for day=1:3
    %use the rest of the items across the 3 days
    f_items_one_day = [];
    t_items_one_day = [];
    for bin=1:5
        item_ind = day+1;
        f_items_one_day = [f_items_one_day; bin_objects_food{bin}(item_ind,1)];
        t_items_one_day = [t_items_one_day; bin_objects_trinket{bin}(item_ind,1)];
    end
    %Prepare BDM ITEM

    %randomize the ordering of all the items for BDM Item
    bdm_item_seq = [f_items_all_days; f_items_one_day; t_items_all_days; t_items_one_day];
    idx_rnd = randperm(length(bdm_item_seq));
    bdm_item_seq = bdm_item_seq(idx_rnd);
    
    %get combinations of all items
    %create a N x 2 array of item pairs, starting with each item paired
    %with itself
    day_food_list = [f_items_all_days; f_items_one_day];
    day_trinket_list = [t_items_all_days; t_items_one_day];
    combo_list = [[day_food_list;day_trinket_list],[day_food_list;day_trinket_list]];
    all_items = [day_food_list; day_trinket_list];
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
    bundle_item_seq = combo_list(idx_rnd,:);
    lr_conds = lr_conds(idx_rnd);
    num_trials = length(bundle_item_seq);

    %flip the left right order of bundles with condition 2 
    for i=1:num_trials
        if lr_conds(i) == 2
            bundle_item_seq(i,:) = fliplr(bundle_item_seq(i,:));
        end
    end
    
    %Prepare 5 CHOICE RUNS
    
    %five repetitions of the same object
    %use -1 in the second column to distinguish individual item condition
    temp_negones = -1 * ones(length(all_items),1);
    item_trials = [all_items, temp_negones];
    
    %randomize bundle sequence
    idx_rnd = randperm(length(bundle_item_seq));
    rdm_bundle_item_seq = bundle_item_seq(idx_rnd,:);
    
    %divide into runs and put in cell
    total_trials = length(bundle_item_seq) + (length(all_items)*num_runs);
    trials_in_run = total_trials/num_runs;
    bundles_in_run = length(bundle_item_seq)/num_runs;
    choice_item_cell = cell(num_runs,1);
    for i=1:num_runs 
        ind1 = ((i-1)*bundles_in_run)+1;
        ind2 = i*bundles_in_run;
        run_sequence = [item_trials; rdm_bundle_item_seq(ind1:ind2,:)];
        idx_rnd = randperm(trials_in_run);
        choice_item_cell{i} = run_sequence(idx_rnd,:);
    end
    
    day_subID = [fmri_subID(1:3),'-',num2str(day)];
    f_name = ['data/item_list_sub_',day_subID];
    if isequal(exist([f_name,'.mat'],'file'),0)
        save(f_name,'bdm_item_seq','bundle_item_seq', 'choice_item_cell','f_items_all_days','t_items_all_days');
        disp('Done!')
    else
        disp('WARNING: The file already exists!')
    end
end

%end