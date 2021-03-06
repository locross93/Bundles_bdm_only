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
    temp_file = ['logs/bdm_bundle_sub_',subID,'.mat'];
    load(temp_file)
    all_subj_value = [all_subj_value; value];
    all_subj_item = [all_subj_item; item];
end

bdm_bundle_value_orig = all_subj_value;
no_response_ind=bdm_bundle_value_orig==100;
bdm_bundle_value=bdm_bundle_value_orig(~no_response_ind);
bdm_bundle_orig = all_subj_item;
bdm_bundle_items=bdm_bundle_orig(~no_response_ind,:);
bdm_bundle_item_category = bdm_bundle_items>71; %0 is food. 1 is trinket.

bdm_bundle_category=zeros(length(bdm_bundle_value),1);
bdm_bundle_category(bdm_bundle_item_category(:,1)==0 & bdm_bundle_item_category(:,2)==0)=1; %Food bundle
bdm_bundle_category(bdm_bundle_item_category(:,1)==0 & bdm_bundle_item_category(:,2)==1)=2; %Mixed bundle
bdm_bundle_category(bdm_bundle_item_category(:,1)==1 & bdm_bundle_item_category(:,2)==0)=2; %Mixed bundle
bdm_bundle_category(bdm_bundle_item_category(:,1)==1 & bdm_bundle_item_category(:,2)==1)=3; %Trinket bundle

fig1 = figure;
if split_by_category
    bundle_category_counts=zeros(2,length(histogram_binedges)-1);
    for category=1:3
        bundle_category_counts(category,:)=histcounts(bdm_bundle_value(bdm_bundle_category==category),histogram_binedges);
    end
    bar(bundle_category_counts');
    legend('Food bundle','Mixed bundle','Trinket bundle');
else
    histogram(bdm_bundle_value,histogram_binedges)
    set(gca,'XTick',[1:2:19])
end
set(gca,'XTickLabel',{'0-1','2-3','4-5','6-7','8-9','10-11','12-13','14-15',...
    '16-17','18-20'});
title(sprintf('Bundle Bids - All Subjects'))
xlabel('Value')
ylabel('Count')

fig2 = figure;
subplot(3,1,1);
food_bundles = bdm_bundle_value(find(bdm_bundle_category == 1));
h1 = histogram(food_bundles, histogram_binedges);
xlim([-1 21])
%xticklabels({'0' '2' '4' '6' '8' '10'})
%ax1 = axes('Position',[0 2 4 6 8 10]);
title('Food Bundles (all subjs)', 'FontSize', 14)
xlabel('Value')

ylabel('Count')

subplot(3,1,2);
trinket_bundles = bdm_bundle_value(find(bdm_bundle_category == 3));
h2 = histogram(trinket_bundles, histogram_binedges, 'FaceColor', 'r');
xlim([-1 21])
title('Trinket Bundles (all subjs)', 'FontSize', 14)
xlabel('Value')
ylabel('Count')

subplot(3,1,3);
mixed_bundles = bdm_bundle_value(find(bdm_bundle_category == 2));
h2 = histogram(mixed_bundles, histogram_binedges, 'FaceColor', 'g');
xlim([-1 21])
title('Mixed Bundles (all subjs)', 'FontSize', 14)
xlabel('Value')
ylabel('Count')

%individual bundles mean value across subjects
mean_all_bundles = mean(bdm_bundle_value);
SE_all_bundles = std(bdm_bundle_value)/sqrt(length(bdm_bundle_value)); 
mean_food_bundles = mean(food_bundles);
SE_food_bundles = std(food_bundles)/sqrt(length(food_bundles));
mean_trinket_bundles = mean(trinket_bundles);
SE_trinket_bundles = std(trinket_bundles)/sqrt(length(trinket_bundles));
mean_mixed_bundles = mean(mixed_bundles);
SE_mixed_bundles = std(mixed_bundles)/sqrt(length(mixed_bundles));

means = [mean_all_bundles, mean_food_bundles, mean_trinket_bundles, mean_mixed_bundles];
SEs = [SE_all_bundles, SE_food_bundles, SE_trinket_bundles, SE_mixed_bundles];

fig3 = figure;
hold on
c = {'All bundles','Food Bundles','Trinket Bundles', 'Mixed Bundles'};
bar(1:4,means, 'FaceColor',[1 0.55 0], 'EdgeColor',[1 0.55 0])
errorbar(1:4,means,SEs,'k.','LineWidth',2)
set(gca, 'XTick', [1 2 3 4])
set(gca,'xticklabel',c, 'FontSize', 7)
ylabel('Mean Value', 'FontSize', 12)
title('Mean Values for Bundles', 'FontSize', 18)
