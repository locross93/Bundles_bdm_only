function pay_subj(subID)

saveflag = true;
debug = 0;

%% pay_subj('106-1')
%% pay_subj('004-3')











file_name = ['logs/payment/selected_items_sub_',subID];
load(file_name)

item_id = ItemsToUse';

%under 100 for food, over 100 for trinkets
%if necessary, input items directly
%004
%item_id = [5 131];

%flip a coin to determine whether trial is from BDM or choice trials
p = rand;
if p > 0.5
    %BDM
    pay_subj_BDM(subID, item_id, saveflag, debug);
else
    %CHOICE
    pay_subj_choice(subID, item_id, saveflag, debug);
end

end