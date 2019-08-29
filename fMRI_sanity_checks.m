%generic sanity check script for analyzing behavioral data in fMRI
%experiment

%Initialize workspace
clearvars;
clc;

%can analyze one day or across all day
subID = '106-3';

%intercept
intercept = true;

%Specify script parameters
split_by_category=1;
XTickLabels={'0-1','2-3','4-5','6-7','8-9','10-11','12-13','14-15',...
    '16-17','18-20'};
histogram_binedges=-0.5:1:20.5; %Bin size of 2

%load item data
if length(subID) == 5
    temp_file = ['logs/bdm_items_sub_',subID,'.mat'];
    load(temp_file)
    bdm_item_value_orig = value;
    no_response_ind=bdm_item_value_orig==100;
    bdm_item_value=bdm_item_value_orig(~no_response_ind);
    bdm_item_orig = item;
    bdm_item=bdm_item_orig(~no_response_ind);
    bdm_item_category = bdm_item>=71; %0 is food. 1 is trinket.
elseif length(subID) == 3
    bdm_item_value_orig = [];
    bdm_item_orig = [];
    for i=1:3
        subID_temp = [subID,'-',num2str(i)];
        temp_file = ['logs/bdm_items_sub_',subID_temp,'.mat'];
        load(temp_file)
        bdm_item_value_orig = [bdm_item_value_orig; value];
        bdm_item_orig = [bdm_item_orig; item];
    end
    no_response_ind=bdm_item_value_orig==100;
    bdm_item_value=bdm_item_value_orig(~no_response_ind);
    bdm_item=bdm_item_orig(~no_response_ind);
    bdm_item_category = bdm_item>=71; %0 is food. 1 is trinket.
end

fig1 = figure;
set(gcf,'units','normalized','outerposition',[0.0 0.0 1.0 1.0]);
set(gcf,'Paperpositionmode','auto','Papersize',[20 20]);
subplot(3,2,1)
if split_by_category
    item_category_counts=zeros(2,length(histogram_binedges)-1);
    for category=0:1
        item_category_counts(category+1,:)=histcounts(bdm_item_value(bdm_item_category==category),histogram_binedges);
    end
    bar(repmat(0:1:20,2,1)',item_category_counts');
    legend('Food','Trinket');
    set(gca,'XTick',[0:1:20])
    xlim([-1 21]);
else
    histogram(bdm_item_value,histogram_binedges)
    set(gca,'XTick',[1:2:19])
end
if length(histogram_binedges)==10
set(gca,'XTickLabel',XTickLabels);
end
title(sprintf('Invididual Item Bids - Subject %s',subID),'FontSize',18)
xlabel('Value')
ylabel('Count')

%load bundle data
if length(subID) == 5
    temp_file = ['logs/bdm_bundle_sub_',subID,'.mat'];
    load(temp_file)
    bdm_bundle_value_orig = value;
    no_response_ind=bdm_bundle_value_orig==100;
    bdm_bundle_value=bdm_bundle_value_orig(~no_response_ind);
    bdm_bundle_orig = item;
    bdm_bundle_items=bdm_bundle_orig(~no_response_ind,:);
    bdm_bundle_item_category = bdm_bundle_items>=71; %0 is food. 1 is trinket.
elseif length(subID) == 3
    bdm_bundle_value_orig = [];
    bdm_bundle_orig = [];
    for i=1:3
        subID_temp = [subID,'-',num2str(i)];
        temp_file = ['logs/bdm_bundle_sub_',subID_temp,'.mat'];
        load(temp_file)
        bdm_bundle_value_orig = [bdm_bundle_value_orig; value];
        bdm_bundle_orig = [bdm_bundle_orig; item];
    end
    no_response_ind=bdm_bundle_value_orig==100;
    bdm_bundle_value=bdm_bundle_value_orig(~no_response_ind);
    bdm_bundle_items=bdm_bundle_orig(~no_response_ind,:);
    bdm_bundle_item_category = bdm_bundle_items>=71; %0 is food. 1 is trinket.
end

bdm_bundle_category=zeros(length(bdm_bundle_value),1);
bdm_bundle_category(bdm_bundle_item_category(:,1)==0 & bdm_bundle_item_category(:,2)==0)=1; %Food bundle
bdm_bundle_category(bdm_bundle_item_category(:,1)==0 & bdm_bundle_item_category(:,2)==1)=2; %Mixed bundle
bdm_bundle_category(bdm_bundle_item_category(:,1)==1 & bdm_bundle_item_category(:,2)==0)=2; %Mixed bundle
bdm_bundle_category(bdm_bundle_item_category(:,1)==1 & bdm_bundle_item_category(:,2)==1)=3; %Trinket bundle

subplot(3,2,2)
if split_by_category
    bundle_category_counts=zeros(3,length(histogram_binedges)-1);
    for category=1:3
        bundle_category_counts(category,:)=histcounts(bdm_bundle_value(bdm_bundle_category==category),histogram_binedges);
    end
    bar(repmat(0:1:20,3,1)',bundle_category_counts');
    legend('Food bundle','Mixed bundle','Trinket bundle');
    set(gca,'XTick',[0:1:20])
    xlim([-1 21]);
else
    histogram(bdm_bundle_value,histogram_binedges)
    set(gca,'XTick',[1:2:19])
end
if length(histogram_binedges)==10
    set(gca,'XTickLabel',XTickLabels);
end
title(sprintf('Bundle Bids - Subject %s',subID),'FontSize',18)
xlabel('Value')
ylabel('Count')

%Assuming that first column is left item and 2nd column is right item.
%Linear regression across left (x1) and right (x2) item
%Bundle value=B1*x1+B2*x2+C
remove_errors=0;
for j=1:2
    for i=1:length(bdm_bundle_items(:,1))
        if any(bdm_item==bdm_bundle_items(i,j))
            %for items valued every day, take the first value
            temp = bdm_item_value(bdm_item==bdm_bundle_items(i,j));
            bdm_bundle_item_values(i,j)=temp(1);
        else
            bdm_bundle_item_values(i,j)=-1; %Error code
            remove_errors=1;
        end
    end
end

if remove_errors
    error_ind=any(bdm_bundle_item_values==-1,2);
    bdm_bundle_item_values=bdm_bundle_item_values(~error_ind);
    bdm_bundle_value=bdm_bundle_value(~error_ind);
end


LM_leftright=fitlm([bdm_bundle_item_values],bdm_bundle_value,'VarNames',{'LeftItemValue','RightItemValue','BundleValue'},'Intercept',intercept)
fprintf('R2 value: %f \n', LM_leftright.Rsquared.Adjusted);
beta=LM_leftright.Coefficients.Estimate;
subplot(3,2,3)
PredictedValues=feval(LM_leftright,[bdm_bundle_item_values]);
plot(PredictedValues,bdm_bundle_value,'.','MarkerSize',20);
hold on
plot(bdm_bundle_value, bdm_bundle_value,'MarkerSize',10);
xlabel('Predicted value from LM');
ylabel('Reported value');
title(sprintf('Left vs Right regression - Subject %s',subID),'FontSize',18);
xlim([0 max([PredictedValues; 20])])
ylim([0 20]);
if intercept
    text(0.5,17,sprintf('R2 value: %0.3f \n\\beta1 (intercept): %0.3f \n\\beta2 (left): %0.3f \n\\beta3 (right): %0.3f', LM_leftright.Rsquared.Adjusted, beta(1), beta(2), beta(3)),'FontSize',16);
else
    text(0.5,17,sprintf('R2 value: %0.3f \n\\beta1 (left): %0.3f \n\\beta2 (right): %0.3f', LM_leftright.Rsquared.Adjusted, beta(1), beta(2)),'FontSize',16);
end

%plot histograms of actual data and predicted data
subplot(3,2,5)

bundle_glm_counts = zeros(2,length(histogram_binedges)-1);
bundle_glm_counts(1,:)=histcounts(bdm_bundle_value,histogram_binedges);
bundle_glm_counts(2,:)=histcounts(PredictedValues,histogram_binedges);

bar(repmat(0:1:20,2,1)',bundle_glm_counts');
legend('Data','Predictions');
set(gca,'XTick',[0:1:20])
xlim([-1 21]);
title(sprintf('Predicted Bundle Bids from Model - Subject %s',subID),'FontSize',18)
xlabel('Value')
ylabel('Count')


%Linear regression across food (x1) and trinket item (x2) for mixed bundles
%Bundle value=B1*x1+B2*x2+C
bdm_mixedbundle_value=bdm_bundle_value(bdm_bundle_category==2,:);
bdm_mixedbundle_items=sort(bdm_bundle_items(bdm_bundle_category==2,:),2);
bdm_mixedbundle_item_values = zeros(length(bdm_mixedbundle_items(:,1)),2);
remove_errors=0;
for j=1:2
    for i=1:length(bdm_mixedbundle_items(:,1))
        if any(bdm_item==bdm_mixedbundle_items(i,j))
            %for items valued every day, take the first value
            temp = bdm_item_value(bdm_item==bdm_mixedbundle_items(i,j));
            bdm_mixedbundle_item_values(i,j)=temp(1);
        else
            bdm_mixedbundle_item_values(i,j)=-1;
            remove_errors=1;
        end
    end
end

if remove_errors
    error_ind=any(bdm_mixedbundle_item_values==-1,2);
    bdm_mixedbundle_item_values=bdm_mixedbundle_item_values(~error_ind);
    bdm_mixedbundle_value=bdm_mixedbundle_value(~error_ind);
end

LM_foodtrinket=fitlm(bdm_mixedbundle_item_values,bdm_mixedbundle_value,'VarNames',{'FoodValue','TrinketValue','BundleValue'},'Intercept',intercept)
fprintf('R2 value: %f \n', LM_foodtrinket.Rsquared.Adjusted);
beta=LM_foodtrinket.Coefficients.Estimate;
subplot(3,2,4);
PredictedValues=feval(LM_foodtrinket,[bdm_mixedbundle_item_values]);
plot(PredictedValues,bdm_mixedbundle_value,'.','MarkerSize',20);
hold on
plot(bdm_mixedbundle_value, bdm_mixedbundle_value,'MarkerSize',10);
xlabel('Predicted value from LM');
ylabel('Reported value');
title(sprintf('Food vs trinket regression - Subject %s',subID),'FontSize',18);
xlim([0 max([PredictedValues; 20])])
ylim([0 20]);
if intercept
    text(0.5,17,sprintf('R2 value: %0.3f \n\\beta1 (intercept): %0.3f \n\\beta2 (left): %0.3f \n\\beta3 (right): %0.3f', LM_foodtrinket.Rsquared.Adjusted, beta(1), beta(2), beta(3)),'FontSize',16);
else
    text(0.5,17,sprintf('R2 value: %0.3f \n\\beta1 (left): %0.3f \n\\beta2 (right): %0.3f', LM_foodtrinket.Rsquared.Adjusted, beta(1), beta(2)),'FontSize',16);
end

%plot histograms of actual data and predicted data
subplot(3,2,6)

mix_bundle_glm_counts = zeros(2,length(histogram_binedges)-1);
mix_bundle_glm_counts(1,:)=histcounts(bdm_mixedbundle_value,histogram_binedges);
mix_bundle_glm_counts(2,:)=histcounts(PredictedValues,histogram_binedges);

bar(repmat(0:1:20,2,1)',mix_bundle_glm_counts');
legend('Data','Predictions');
set(gca,'XTick',[0:1:20])
xlim([-1 21]);
title(sprintf('Predicted Mixed Bundle Bids from Model - Subject %s',subID),'FontSize',18)
xlabel('Value')
ylabel('Count')

%plot bundle value vs sum of individual values
LM_leftright=fitlm([bdm_bundle_item_values],bdm_bundle_value,'VarNames',{'LeftItemValue','RightItemValue','BundleValue'},'Intercept',intercept);
beta=LM_leftright.Coefficients.Estimate;
fig2 = figure;
sum_of_values = sum(bdm_bundle_item_values,2);
plot(sum_of_values,bdm_bundle_value,'.','MarkerSize',20);
hold on
plot(sum_of_values, sum_of_values,'MarkerSize',10);
xlabel('Value of Sum of Individual Item Values','FontSize',16);
ylabel('Bundle Value','FontSize',16);
%title(sprintf('Bundle Value vs. Linear Sum - Subject %s',subID),'FontSize',18);
title(sprintf('Bundle Value vs. Linear Sum - Subject 001'),'FontSize',18);
xlim([0 max([PredictedValues; 20])])
ylim([0 20]);
if intercept
    %text(0.5,17,sprintf('R2 value: %0.3f \n\\beta1 (intercept): %0.3f \n\\beta2 (left): %0.3f \n\\beta3 (right): %0.3f', LM_leftright.Rsquared.Adjusted, beta(1), beta(2), beta(3)),'FontSize',16);
    text(0.5,17,sprintf('R^{2} value: %0.3f \n\\beta_{0} (intercept): %0.3f \n\\beta_{1} (item 1): %0.3f \n\\beta_{2} (item 2): %0.3f', LM_leftright.Rsquared.Adjusted, beta(1), beta(2), beta(3)),'FontSize',16);
else
    text(0.5,17,sprintf('R2 value: %0.3f \n\\beta1 (left): %0.3f \n\\beta2 (right): %0.3f', LM_leftright.Rsquared.Adjusted, beta(1), beta(2)),'FontSize',16);
end

%plot choice behavior
if str2num(subID(1:3)) >= 100 && length(subID) == 5
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
    num_missed = size(find(choice_list == 2), 1);

    fig3 = figure;
    histogram(choice_list)
    title(sprintf('Choices vs Reference Money - Subject %s',subID),'FontSize',18)
    set(gca,'XTick',[0:1:2])
    xlabel('0: Money 1: Item')
    ylabel('Count')
    text(1.65,10,sprintf('Num Missed Trials: %d', num_missed));
elseif str2num(subID(1:3)) >= 100 && length(subID) == 3
    item_list = [];
    choice_list = [];
    for day=1:3
        subID_temp = [subID,'-',num2str(day)];
        
        for run=1:5
            file_name= ['choice_run',num2str(run),'_sub_',subID_temp];
            load(['logs/',file_name]);
            item_list = [item_list; item];
            choice_list = [choice_list; choice];
        end
        
        %where was there no response
        no_response = find(choice_list > 1);
        choice_list(no_response) = 2;
        num_missed = size(find(choice_list == 2), 1);
    end
    fig3 = figure;
    histogram(choice_list)
    title(sprintf('Choices vs Reference Money - Subject %s',subID),'FontSize',18)
    set(gca,'XTick',[0:1:2])
    xlabel('0: Money 1: Item')
    ylabel('Count')
    text(1.65,10,sprintf('Num Missed Trials: %d', num_missed));
end

%temporary - save item list to csv
%error_inds = choice_list == 2;
%item_list_clean = item_list(~error_inds,:);
%mvpa_folder='/Users/logancross/Documents/Bundle_Value/mvpa/OpenfMRI_Format/';
%dlmwrite([mvpa_folder,'sub',subID,'/model/task_info/item_list.txt'],item_list_clean,'delimiter','\t')

