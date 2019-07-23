subID = '004-3';

%%add different color coding for different conditions 

temp_file = ['logs/bdm_items_sub_',subID,'.mat'];
load(temp_file)
bdm_item_value = value;

fig1 = figure;
histogram(bdm_item_value)
title('Invididual Item Bids')
xlabel('Value')
ylabel('Count')

temp_file = ['logs/bdm_bundle_sub_',subID,'.mat'];
load(temp_file)
bdm_bundle_value = value;

fig2 = figure;
histogram(bdm_bundle_value)
title('Bundle Bids')
xlabel('Value')
ylabel('Count')

run_num = 1;
file_name= ['choice_run',num2str(run_num),'_sub_',subID];

load(['logs/',file_name]);
item_list = item;
choice_list = choice;

for run=2:5
    file_name= ['choice_run',num2str(run),'_sub_',subID];
    load(['logs/',file_name]);
    item_list = [item_list; item];
    choice_list = [choice_list; choice];
end

%where was there no response
no_response = find(choice_list > 1);
choice_list(no_response) = 2;

fig3 = figure;
histogram(choice_list)
title('Choices vs Reference Money')
xlabel('0: Money 1: Item')
ylabel('Count')
