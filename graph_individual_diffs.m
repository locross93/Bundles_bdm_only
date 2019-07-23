%Initialize workspace
clearvars;
clc;

%Specify script parameters
%which subjects to analyze
subID_cell = {'005-1','006-1','007-1','008-1','009-1','010-1','011-1','012-1'};
num_subjs = length(subID_cell);

%plot bar graph of all subject means
mean_values = zeros(num_subjs,1);
se_values = zeros(num_subjs,1);
for i=1:num_subjs
    subID = subID_cell{i};
    temp_file = ['logs/bdm_items_sub_',subID,'.mat'];
    load(temp_file)
    mean_values(i) = mean(value);
    se_values(i) = std(value); %%/sqrt(length(value));
end

fig1 = figure;
hold on
subj_strings = {};
for i=1:num_subjs
    subj_strings{end+1} = ['S',num2str(i)];
end
bar(1:num_subjs,mean_values, 'FaceColor',[1 0.55 0], 'EdgeColor',[1 0.55 0])
errorbar(1:num_subjs,mean_values,se_values,'k.','LineWidth',2)
set(gca, 'XTick', 1:num_subjs)
set(gca,'xticklabel',subj_strings)
ylabel('Mean Value')
xlabel('Subject')
title('Individual Differences in Mean Value', 'FontSize', 18)

%plot bar graph of all subject medians
median_values = zeros(num_subjs,1);
for i=1:num_subjs
    subID = subID_cell{i};
    temp_file = ['logs/bdm_items_sub_',subID,'.mat'];
    load(temp_file)
    median_values(i) = median(value);
end

fig2 = figure;
hold on
bar(1:num_subjs,median_values, 'FaceColor',[1 0.55 0], 'EdgeColor',[1 0.55 0])
set(gca, 'XTick', 1:num_subjs)
set(gca,'xticklabel',subj_strings)
ylabel('Mean Value')
xlabel('Subject')
title('Individual Differences in Median Value', 'FontSize', 18)