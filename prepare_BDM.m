function prepare_BDM(subID)
%% prepare_BDM('150424a')

close all;
%rng('shuffle');

load(['data/data_id_new']) % item_ids is loaded
idx_rnd = randperm(length(data_id_new));
item_rnd_idx = data_id_new(idx_rnd);

num_runs = 4;
num_items = length(item_rnd_idx);

item_id_sub = cell(num_runs,1);
item_id_sub{1} = item_rnd_idx(1:num_items/2);
item_id_sub{2} = item_rnd_idx([num_items/2+1]:end);
item_id_sub{3} = item_rnd_idx(1:num_items/2);
item_id_sub{4} = item_rnd_idx([num_items/2+1]:end);

f_name = ['data/item_id_sub_',subID];
if isequal(exist([f_name,'.mat'],'file'),0)
    save(f_name,'item_id_sub');
    disp('Done!')
else
    disp('WARNING: The file already exists!')
end

end