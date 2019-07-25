function pay_subj(subID)


%% pay_subj('800-1')
%% pay_subj('999-1')
%% pay_subj('017-1')


%pick a trial at random to pay subject









% item id
%under 100 for food, over 100 for trinkets
file_name = ['logs/payment/selected_items_sub_',subID];
load(file_name)

item_id = ItemsToUse;


%800
%item_id = [134];
%item_id = [117 51];

%BDM
pay_subj_BDM(subID,item_id);

end