clear all;
close all;


subID='010-1';

subID_fMRI='101-3';
%Modified to have similarity measure as part of regression model. 6/21/18
%WG

%Received from Logan 6/1/2018 WG
%Modified to work with new pilot data 6/1/2018 WG

object_similarity_matrix=dlmread('word2vec_item_similarity.csv');


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




%Specify script parameters


temp_file = ['data/item_list_sub_',subID_fMRI,'.mat'];
load(temp_file)

bdm_item_subset_ind=ismember(bdm_item,bdm_item_seq);
bdm_item_subset=bdm_item(bdm_item_subset_ind);
bdm_item=bdm_item_subset;
bdm_item_value=bdm_item_value(bdm_item_subset_ind);

bdm_item_category = bdm_item>=71; %0 is food. 1 is trinket.



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


bdm_bundle_similarity=zeros(size(bdm_bundle_value));
bdm_bundle_items_sort=sort(bdm_bundle_items,2);
for bundle=1:length(bdm_bundle_value)
    if bdm_bundle_items_sort(bundle,1)~=bdm_bundle_items_sort(bundle,2)
        bdm_bundle_similarity(bundle)=object_similarity_matrix(object_similarity_matrix(:,1)==bdm_bundle_items_sort(bundle,1) & object_similarity_matrix(:,2)==bdm_bundle_items_sort(bundle,2),3);
    else
        bdm_bundle_similarity(bundle)=1; %Identical objects have a similarity of 1.
    end
end


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

LM_leftright=fitlm(zscore([bdm_bundle_item_values bdm_bundle_similarity]),zscore(bdm_bundle_value),'VarNames',{'LeftItemValue','RightItemValue','ItemSimilarity','BundleValue'},'Intercept',false)
fprintf('R2 value: %f \n', LM_leftright.Rsquared.Adjusted);
beta=LM_leftright.Coefficients.Estimate;
subplot(2,2,3)
PredictedValues=feval(LM_leftright,[bdm_bundle_item_values bdm_bundle_similarity]);
plot(PredictedValues,bdm_bundle_value,'.','MarkerSize',20);
xlabel('Predicted value from LM');
ylabel('Reported value');
title('Left vs Right regression');
xlim([0 max([PredictedValues; 20])])
ylim([0 20]);
text(0.5,18,sprintf('R2 value: %0.3f \n\\beta1: %0.3f \n\\beta2: %0.3f \n\\beta3: %0.3f', LM_leftright.Rsquared.Adjusted, beta(1), beta(2), beta(3)));

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

bdm_mixedbundle_similarity=zeros(size(bdm_mixedbundle_value));
for bundle=1:length(bdm_mixedbundle_value)
    if bdm_mixedbundle_items(bundle,1)~=bdm_mixedbundle_items(bundle,2)
        bdm_mixedbundle_similarity(bundle)=object_similarity_matrix(object_similarity_matrix(:,1)==bdm_mixedbundle_items(bundle,1) & object_similarity_matrix(:,2)==bdm_mixedbundle_items(bundle,2),3);
    else
        bdm_mixedbundle_similarity(bundle)=1; %Identical objects have a similarity of 1.
    end
end

if remove_errors
    error_ind=any(bdm_mixedbundle_item_values==-1,2);
    bdm_mixedbundle_item_values=bdm_mixedbundle_item_values(~error_ind);
    bdm_mixedbundle_value=bdm_mixedbundle_value(~error_ind);
end

LM_foodtrinket=fitlm(zscore([bdm_mixedbundle_item_values bdm_mixedbundle_similarity]),zscore(bdm_mixedbundle_value),'VarNames',{'FoodValue','TrinketValue','ItemSimilarity','BundleValue'},'Intercept',false)
fprintf('R2 value: %f \n', LM_foodtrinket.Rsquared.Adjusted);
beta=LM_foodtrinket.Coefficients.Estimate;
subplot(2,2,4);
PredictedValues=feval(LM_foodtrinket,[bdm_mixedbundle_item_values bdm_mixedbundle_similarity]);
plot(PredictedValues,bdm_mixedbundle_value,'.','MarkerSize',20);
xlabel('Predicted value from LM');
ylabel('Reported value');
title('Food vs trinket regression');
xlim([0 max([PredictedValues; 20])])
ylim([0 20]);
text(0.5,18,sprintf('R2 value: %0.3f \n\\beta1: %0.3f \n\\beta2: %0.3f \n\\beta3: %0.3f', LM_foodtrinket.Rsquared.Adjusted, beta(1), beta(2),beta(3)));

%% Checking value vs visual features

image_type='food'; %trinket or food
try
    load(sprintf('%sLowVisualFeatures.mat',image_type))
catch
    orig_file_dir=sprintf('/Users/WhitneyGriggs/Box Sync/UCLA MSTP/Summer Rotation 2018/Logan Cross Project/Bundles_0601/GitHub_Bundles_bdm/Bundles_bdm_only/NewObjects/WithoutText/imgs_%s/',image_type);
    
    imagesToLoad=dir([orig_file_dir '*.jpg']);
    imagesToLoad=sort_nat({imagesToLoad.name});
    
    mean_intensity=zeros(length(imagesToLoad),3);
    mean_luminance=zeros(length(imagesToLoad),1);
    img_contrast=zeros(length(imagesToLoad),1);
    mean_hsv=zeros(length(imagesToLoad),3);
    for i=1:length(imagesToLoad)
        img=imread([orig_file_dir imagesToLoad{i}]);
        for j=1:3
            mean_intensity(i,j)=mean2(img(:,:,j));
        end
        mean_luminance(i)=mean2(luminance(img));
        img_contrast(i)=std2(luminance(img));
        img_hsv=rgb2hsv(img);
        for j=1:3
            mean_hsv(i,j)=mean2(img_hsv(:,:,j));
        end
        
 
        grayImage{i}=double(rgb2gray(img));

       %% =======================================================
        % get list of pixels without black background
        %% 
       
        thresholdValue = 10;

        
        MaskImage=double(grayImage{i});
        grayImage{i}(MaskImage< thresholdValue)=NaN;
        CurrentGrayImg=grayImage{i};
        
   


    %% =======================================================
    % spatial frequency
    %% =======================================================
    CheckSpatial=1;
    if CheckSpatial
        GradPic{i}=imgradient(CurrentGrayImg); %derivatives are large near strong image edges, and small in flat regions of an image
        GradMean(i)=nanmean(nanmean(GradPic{i})); % the higher the mean, the higher the spatial resulotion of the pic.

    end
        
        
        
 
        
        sprintf('Percent done: %0.2f percent',100*i/length(imagesToLoad))
    end
    
    save(sprintf('%sLowVisualFeatures.mat',image_type),'mean_intensity', 'mean_luminance', 'img_contrast', 'mean_hsv','GradMean')
end

[~,order]=sort(bdm_item);
bdm_item_value_sort=bdm_item_value(order);

if strcmp(image_type,'food')
    range=1:70;
else
    range=71:110;
end

figure;
set(gcf,'units','normalized','outerposition',[0 0 1 1]);
set(gcf,'Paperpositionmode','auto','Papersize',[20 20]);


subplot(2,2,1)
plot(mean_luminance,bdm_item_value_sort(range),'k.');
title('Luminance vs value');
xlabel('Luminance');
ylabel('WTP Value');

subplot(2,2,2)
plot(img_contrast,bdm_item_value_sort(range),'k.');
title('Contrast vs value');
xlabel('Contrast');
ylabel('WTP Value');

subplot(2,2,3)
color={'r','g','b'};
for i=1:3
    hold on;
    plot(mean_intensity(:,i),bdm_item_value_sort(range),sprintf('%s.',color{i}));
    hold off;
end
title('Intensity vs value');
xlabel('Color intensity');
ylabel('WTP Value');

subplot(2,2,4)
color={'r','g','b'};
for i=1
    hold on;
    plot(mean_hsv(:,i),bdm_item_value_sort(range),sprintf('%s.',color{i}));
    hold off;
end
%legend('Hue','Saturation','Brightness');
legend('Hue');
title('HSV vs value');
xlabel('HSV intensity');
ylabel('WTP value');



LM_Hue=fitlm(zscore(mean_hsv(:,1)),zscore(bdm_item_value_sort(range)),'VarNames',{'Hue','ItemValue'})
LM_ColorValue=fitlm(zscore(mean_hsv(:,3)),zscore(bdm_item_value_sort(range)),'VarNames',{'ColorValue','ItemValue'})
LM_GradMean=fitlm(zscore(GradMean'),zscore(bdm_item_value_sort(range)),'VarNames',{'SpatFreq','ItemValue'})

plot(LM_GradMean)

% %% Subsampling to generate desired distribution
% std_bool=1;
% mdn=median(bdm_item_value);
% min_stdev=2;
% max_stdev=20;
% bin_height=5;
% counter=0;
% pvalue=0.1;
% while std_bool
%     counter=counter+1;
%     rdn_nums_food=randi(70,20,1);
%     rdn_nums_trinket=randi(40,20,1)+70;
%     bdm_food_subset_values=bdm_item_value(rdn_nums_food);
%     bdm_trinket_subset_values=bdm_item_value(rdn_nums_trinket);
%     bdm_subset_values=[bdm_food_subset_values; bdm_trinket_subset_values];
%     
%     
%     [counts, binedges]=histcounts(bdm_subset_values,5);
%     
%     
%     
%     pd=makedist('Uniform','Lower',1,'Upper',5);
%     [h,p]=kstest(counts,'CDF',pd);
%     
%     
%     
%     
%      %if median(bdm_subset_values)==mean(bdm_subset_values)...
%     if median(bdm_subset_values)>=4 ...
%         && std(bdm_subset_values)<=max_stdev && std(bdm_subset_values)>=min_stdev ...
%          %&& all(histcounts(bdm_food_subset_values,[0:1:20]) == histcounts(bdm_trinket_subset_values,[0:1:20]))
%     
%         % if all(histcounts(bdm_food_subset_values,[0:1:20]) == histcounts(bdm_trinket_subset_values,[0:1:20]))
%     %if p<0.001      
%         std_bool=0;
%     end
%     if mod(counter,5000)==0
%         counter
%     end
%     
%     if counter==1000000
%         break;
%     end
% end
% if counter~=1000000
% mean(bdm_subset_values)
% median(bdm_subset_values)
%     figure;
%     histogram([bdm_food_subset_values; bdm_trinket_subset_values],binedges)
%     %plot(counts)
%     
%     pd=makedist('Uniform','Lower',min(bdm_subset_values),'Upper',max(bdm_subset_values));
%     h=kstest(bdm_subset_values,'CDF',pd)
% end


