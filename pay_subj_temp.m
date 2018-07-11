function pay_subj_temp(subID)



%% pay_subj('999-1')
%% pay_subj('004-3')

% item id
%under 100 for food, over 100 for trinkets
%003
%item_id = [9 37];

%004
item_id = [70 112];

%flip a coin to determine whether trial is from BDM or choice trials
p = rand;
if p > 0.5
    %BDM
    pay_subj_BDM(subID,item_id);
else
    %CHOICE
    pay_subj_choice(subID, item_id);
end

end