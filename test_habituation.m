clear all;

plot_by_subj = true;

all_diff_d1_d2 = [];
all_diff_d1_d3 = [];
all_diff_d2_d3 = [];

sub_list = {'101','102','103','104','105','106','107','108','109','110','111','112','113','114'};
%sub_list = {'101','102','103'};
for sub_num=1:length(sub_list)
    subID = sub_list{sub_num};
    
    run_num = 1;
    temp_file = ['logs/bdm_items_sub_',subID,'-',num2str(run_num),'.mat'];
    load(temp_file)
    day1_item_value = value;
    day1_items = item;
    
    run_num = 2;
    temp_file = ['logs/bdm_items_sub_',subID,'-',num2str(run_num),'.mat'];
    load(temp_file)
    day2_item_value = value;
    day2_items = item;
    
    run_num = 3;
    temp_file = ['logs/bdm_items_sub_',subID,'-',num2str(run_num),'.mat'];
    load(temp_file)
    day3_item_value = value;
    day3_items = item;
    
    %then take difference between day1 and day2
    [same_items, inds1, inds2] = intersect(day1_items,day2_items);
    diff_d1_d2 = day1_item_value(inds1) - day2_item_value(inds2);
    
    %then take difference between day1 and day3
    [same_items, inds1, inds3] = intersect(day1_items,day3_items);
    diff_d1_d3 = day1_item_value(inds1) - day3_item_value(inds3);
    
    %then take difference between day2 and day3
    [same_items, inds2, inds3] = intersect(day2_items,day3_items);
    diff_d2_d3 = day2_item_value(inds2) - day3_item_value(inds3);
    
    if plot_by_subj
        mean_d1_d2 = mean(diff_d1_d2);
        std_d1_d2 = std(diff_d1_d2);
        mean_d1_d3 = mean(diff_d1_d3);
        std_d1_d3 = std(diff_d1_d3);
        mean_d2_d3 = mean(diff_d2_d3);
        std_d2_d3 = std(diff_d2_d3);

        mean_diffs = [mean_d1_d2, mean_d1_d3, mean_d2_d3];
        std_diffs = [std_d1_d2, std_d1_d3, std_d2_d3];
        
        figure
        hold on
        c = {'Day 1 - Day 2','Day 1 - Day 3','Day 2 - Day 3'};
        bar(1:3,mean_diffs, 'FaceColor',[1 0.55 0], 'EdgeColor',[1 0.55 0])
        errorbar(1:3,mean_diffs,std_diffs,'k.','LineWidth',2)
        set(gca, 'XTick', [1 2 3])
        set(gca,'xticklabel',c)
        ylabel('Difference in Value')
        title(['Mean Difference in Item Bids Across Days Subj',subID], 'FontSize', 18)
    end
    
    all_diff_d1_d2 = [all_diff_d1_d2; diff_d1_d2];
    all_diff_d1_d3 = [all_diff_d1_d3; diff_d1_d3];
    all_diff_d2_d3 = [all_diff_d2_d3; diff_d2_d3];
    
end

mean_d1_d2 = mean(all_diff_d1_d2);
std_d1_d2 = std(all_diff_d1_d2);
mean_d1_d3 = mean(all_diff_d1_d3);
std_d1_d3 = std(all_diff_d1_d3);
mean_d2_d3 = mean(all_diff_d2_d3);
std_d2_d3 = std(all_diff_d2_d3);

mean_diffs = [mean_d1_d2, mean_d1_d3, mean_d2_d3];
std_diffs = [std_d1_d2, std_d1_d3, std_d2_d3];

figure
hold on
c = {'Day 1 - Day 2','Day 1 - Day 3','Day 2 - Day 3'};
bar(1:3,mean_diffs, 'FaceColor',[1 0.55 0], 'EdgeColor',[1 0.55 0])
errorbar(1:3,mean_diffs,std_diffs,'k.','LineWidth',2)
set(gca, 'XTick', [1 2 3])
set(gca,'xticklabel',c)
ylabel('Difference in Value')
title('Mean Difference in Item Bids Across Days', 'FontSize', 18)

fig2 = figure;
subplot(3,1,1);
h1 = histogram(all_diff_d1_d2, 'FaceColor', [1 0 0], 'EdgeColor',[1 0 0]);
xlim([-8 8])
xlabel('Difference in Value')
ylabel('Count')
title('Difference in Item Bids: Day 1 - Day 2', 'FontSize', 14)

subplot(3,1,2);
h1 = histogram(all_diff_d1_d3, 'FaceColor', [1 0 0], 'EdgeColor',[1 0 0]);
xlim([-8 8])
xlabel('Difference in Value')
ylabel('Count')
title('Difference in Item Bids: Day 1 - Day 3', 'FontSize', 14)

subplot(3,1,3);
h1 = histogram(all_diff_d2_d3, 'FaceColor', [1 0 0], 'EdgeColor',[1 0 0]);
xlim([-8 8])
xlabel('Difference in Value')
ylabel('Count')
title('Difference in Item Bids: Day 2 - Day 3', 'FontSize', 14)
    
    
    