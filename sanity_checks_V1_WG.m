function sanity_checks(subjectID)

if ~exist('subjectID','var')
    disp('No subject ID input. Using default of 999-1'
    subID= '999-1';
end

%Received from Logan 6/1/2018 WG
%Modified to work with new pilot data 6/1/2018 WG

%Initialize workspace
clearvars;
clc;

%Specify script parameters
split_by_category=1;
XTickLabels={'0-1','2-3','4-5','6-7','8-9','10-11','12-13','14-15',...
    '16-17','18-20'};
histogram_binedges=-0.5:1:20.5; %Bin size of 2

temp_file = ['logs/bdm_items_sub_',subID,'.mat'];
load(temp_file)
bdm_item_value_orig = value;
no_response_ind=bdm_item_value_orig==100;
bdm_item_value=bdm_item_value_orig(~no_response_ind);
bdm_item_orig = item;
bdm_item=bdm_item_orig(~no_response_ind);
bdm_item_category = bdm_item>71; %0 is food. 1 is trinket.


fig1 = figure;
set(gcf,'units','normalized','outerposition',[0 0 1 1]);
set(gcf,'Paperpositionmode','auto','Papersize',[20 20]);
subplot(2,2,1)
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
title(sprintf('Invididual Item Bids - Subject %s',subID))
xlabel('Value')
ylabel('Count')



temp_file = ['logs/bdm_bundle_sub_',subID,'.mat'];
load(temp_file)
bdm_bundle_value_orig = value;
no_response_ind=bdm_bundle_value_orig==100;
bdm_bundle_value=bdm_bundle_value_orig(~no_response_ind);
bdm_bundle_orig = item;
bdm_bundle_items=bdm_bundle_orig(~no_response_ind,:);
bdm_bundle_item_category = bdm_bundle_items>71; %0 is food. 1 is trinket.

bdm_bundle_category=zeros(length(bdm_bundle_value),1);
bdm_bundle_category(bdm_bundle_item_category(:,1)==0 & bdm_bundle_item_category(:,2)==0)=1; %Food bundle
bdm_bundle_category(bdm_bundle_item_category(:,1)==0 & bdm_bundle_item_category(:,2)==1)=2; %Mixed bundle
bdm_bundle_category(bdm_bundle_item_category(:,1)==1 & bdm_bundle_item_category(:,2)==0)=2; %Mixed bundle
bdm_bundle_category(bdm_bundle_item_category(:,1)==1 & bdm_bundle_item_category(:,2)==1)=3; %Trinket bundle


subplot(2,2,2)
if split_by_category
    bundle_category_counts=zeros(2,length(histogram_binedges)-1);
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
title(sprintf('Bundle Bids - Subject %s',subID))
xlabel('Value')
ylabel('Count')


%Not currently being used.
% run_num = 1;
% file_name= ['choice_run',num2str(run_num),'_sub_',subID];
%
% load(['logs/',file_name]);
% item_list = item;
% choice_list = choice;
%
% for run=2:5
%     file_name= ['choice_run',num2str(run),'_sub_',subID];
%     load(['logs/',file_name]);
%     item_list = [item_list; item];
%     choice_list = [choice_list; choice];
% end
%
% %where was there no response
% no_response = find(choice_list > 1);
% choice_list(no_response) = 2;
%
% fig3 = figure;
% histogram(choice_list)
% title('Choices vs Reference Money')
% xlabel('0: Money 1: Item')
% ylabel('Count')

%Assuming that first column is left item and 2nd column is right item.
%Linear regression across left (x1) and right (x2) item
%Bundle value=B1*x1+B2*x2+C
remove_errors=0;
for j=1:2
    for i=1:length(bdm_bundle_items(:,1))
        if any(bdm_item==bdm_bundle_items(i,j))
            bdm_bundle_item_values(i,j)=bdm_item_value(bdm_item==bdm_bundle_items(i,j));
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

LM_leftright=fitlm(bdm_bundle_item_values,bdm_bundle_value,'VarNames',{'LeftItem','RightItem','BundleValue'},'Intercept',false)
fprintf('R2 value: %f \n', LM_leftright.Rsquared.Ordinary);
subplot(2,2,3)
PredictedValues=feval(LM_leftright,bdm_bundle_item_values);
plot(PredictedValues,bdm_bundle_value,'.','MarkerSize',20);
xlabel('Predicted value from LM');
ylabel('Reported value');

%Linear regression across food (x1) and trinket item (x2) for mixed bundles
%Bundle value=B1*x1+B2*x2+C
bdm_mixedbundle_value=bdm_bundle_value(bdm_bundle_category==2,:);
bdm_mixedbundle_items=sort(bdm_bundle_items(bdm_bundle_category==2,:),2);
remove_errors=0;
for j=1:2
    for i=1:length(bdm_mixedbundle_items(:,1))
        if any(bdm_item==bdm_mixedbundle_items(i,j))
            bdm_mixedbundle_item_values(i,j)=bdm_item_value(bdm_item==bdm_mixedbundle_items(i,j));
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

LM_foodtrinket=fitlm(bdm_mixedbundle_item_values,bdm_mixedbundle_value,'VarNames',{'Food','Trinket','BundleValue'},'Intercept',false)
fprintf('R2 value: %f \n', LM_foodtrinket.Rsquared.Ordinary);

subplot(2,2,4);
PredictedValues=feval(LM_foodtrinket,bdm_bundle_item_values);
plot(PredictedValues,bdm_bundle_value,'.','MarkerSize',20);
xlabel('Predicted value from LM');
ylabel('Reported value');

end