%Received from Logan 6/1/2018 WG
%Modified to work with new pilot data 6/1/2018 WG

%Initialize workspace
clearvars;
clc;

%Specify script parameters
subID = '020-1'; %800-1 802-1 888-1
split_by_category=1;

histogram_binedges=0:2:20; %Bin size of 2

temp_file = ['logs/bdm_items_sub_',subID,'.mat'];
load(temp_file)
bdm_item_value_orig = value;
no_response_ind=bdm_item_value_orig==100;
bdm_item_value=bdm_item_value_orig(~no_response_ind);
bdm_item_orig = item;
bdm_item=bdm_item_orig(~no_response_ind);
bdm_item_category = bdm_item>71; %0 is food. 1 is trinket.

mean_value=mean(bdm_item_value);
median_value=median(bdm_item_value);
std_value=std(bdm_item_value);

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
title(sprintf('Invididual Item Bids - Subject %s',subID))
xlabel('Value')
ylabel('Count')
%plot mean, median, std
max_bin_count=max(max(item_category_counts));
text(8.5,max_bin_count-4,sprintf('Mean: %0.1f \nMedian: %0.1f \nSTD: %0.1f',...
    mean_value,median_value,std_value),'FontSize',10);



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

mean_bvalue=mean(bdm_bundle_value);
median_bvalue=median(bdm_bundle_value);
std_bvalue=std(bdm_bundle_value);

fig2 = figure;
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
title(sprintf('Bundle Bids - Subject %s',subID))
xlabel('Value')
ylabel('Count')
b_max_bin_count=max(max(bundle_category_counts));
text(8.5,b_max_bin_count-7,sprintf('Mean: %0.1f \nMedian: %0.1f \nSTD: %0.1f',...
    mean_bvalue,median_bvalue,std_bvalue),'FontSize',10);

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

LM_leftright=fitlm(bdm_bundle_item_values,bdm_bundle_value,'VarNames',{'LeftItem','RightItem','BundleValue'})

figure();
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

% LM_foodtrinket=fitlm(bdm_mixedbundle_item_values,bdm_mixedbundle_value,'VarNames',{'Food','Trinket','BundleValue'})
% 
% figure();
% PredictedValues=feval(LM_foodtrinket,bdm_bundle_item_values);
% plot(PredictedValues,bdm_bundle_value,'.','MarkerSize',20);
% xlabel('Predicted value from LM');
% ylabel('Reported value');