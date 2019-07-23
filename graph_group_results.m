%Initialize workspace
clearvars;
clc;

%Specify script parameters
%which subjects to analyze
subID_cell = {'005-1','006-1','007-1','008-1','009-1','010-1','011-1','012-1'}; 
split_by_category=1;

histogram_binedges=0:2:20; %Bin size of 2

all_subj_value = [];
all_subj_item = [];
for i=1:length(subID_cell)
    subID = subID_cell{i};
    temp_file = ['logs/bdm_items_sub_',subID,'.mat'];
    load(temp_file)
    all_subj_value = [all_subj_value value];
    all_subj_item = [all_subj_item item];
end

bdm_item_value_orig = all_subj_value;
no_response_ind=bdm_item_value_orig==100;
bdm_item_value=bdm_item_value_orig(~no_response_ind);
bdm_item_orig = all_subj_item;
bdm_item=bdm_item_orig(~no_response_ind);
bdm_item_category = bdm_item>71; %0 is food. 1 is trinket.

%individual item histogram across subjects
fig1 = figure;
if split_by_category
    item_category_counts=zeros(2,length(histogram_binedges)-1);
    for category=0:1
        item_category_counts(category+1,:)=histcounts(bdm_item_value(bdm_item_category==category),histogram_binedges);
    end
    bar(item_category_counts');
    legend('Food','Trinket');
else
    histogram(bdm_item_value,histogram_binedges)
    set(gca,'XTick',[1:2:19])
end
set(gca,'XTickLabel',{'0-1','2-3','4-5','6-7','8-9','10-11','12-13','14-15',...
    '16-17','18-20'});
title(sprintf('Invididual Item Bids - All Subjects'))
xlabel('Value')
ylabel('Count')

%individual item mean value across subjects
mean_all_items = mean(bdm_item_value);
SE_all_items = std(bdm_item_value)/sqrt(length(bdm_item_value)); 
food_value = bdm_item_value(find(bdm_item_category == 0));
mean_food_items = mean(food_value);
SE_food_items = std(food_value)/sqrt(length(food_value));
trinket_value = bdm_item_value(find(bdm_item_category == 1));
mean_trinket_items = mean(trinket_value);
SE_trinket_items = std(trinket_value)/sqrt(length(trinket_value));

means = [mean_all_items, mean_food_items, mean_trinket_items];
SEs = [SE_all_items, SE_food_items, SE_trinket_items];

fig2 = figure;
hold on
c = {'All Items','Food','Trinkets'};
bar(1:3,means, 'FaceColor',[1 0.55 0], 'EdgeColor',[1 0.55 0])
errorbar(1:3,means,SEs,'k.','LineWidth',2)
set(gca, 'XTick', [1 2 3])
set(gca,'xticklabel',c)
ylabel('Mean Value')
title('Mean Values for Individual Items', 'FontSize', 18)

%mean item value new items and old items across subjects
old_food_items = 1:56;
new_food_items = 57:70;

old_trinket_items = [1 2 3 7 8 9 10 11 12 14 15 17 19 20 21 24 27];
old_trinket_items = old_trinket_items + 100;
new_trinket_items = setdiff(100:140, old_trinket_items);
 
old_food_value = bdm_item_value(find(ismember(bdm_item, old_food_items) == 1));
mean_old_food_items = mean(old_food_value);
SE_old_food_items = std(old_food_value)/sqrt(length(old_food_value));

new_food_value = bdm_item_value(find(ismember(bdm_item, new_food_items) == 1));
mean_new_food_items = mean(new_food_value);
SE_new_food_items = std(new_food_value)/sqrt(length(new_food_value));

old_trinket_value = bdm_item_value(find(ismember(bdm_item, old_trinket_items) == 1));
mean_old_trinket_items = mean(old_trinket_value);
SE_old_trinket_items = std(old_trinket_value)/sqrt(length(old_trinket_value));

new_trinket_value = bdm_item_value(find(ismember(bdm_item, new_trinket_items) == 1));
mean_new_trinket_items = mean(new_trinket_value);
SE_new_trinket_items = std(new_trinket_value)/sqrt(length(new_trinket_value));

means = [mean_old_food_items, mean_new_food_items, mean_old_trinket_items, mean_new_trinket_items];
SEs = [SE_old_food_items, SE_new_food_items, SE_old_trinket_items, SE_new_trinket_items];

fig2 = figure;
hold on
c = {'Old Food','New Food','Old Trinket','New Trinket',};
bar(1:4,means, 'FaceColor',[1 0.55 0], 'EdgeColor',[1 0.55 0])
errorbar(1:4,means,SEs,'k.','LineWidth',2)
set(gca, 'XTick', [1 2 3 4])
set(gca,'xticklabel',c, 'FontSize', 7)
ylabel('Mean Value', 'FontSize', 12)
title('Old and New Item Mean Values', 'FontSize', 18)


