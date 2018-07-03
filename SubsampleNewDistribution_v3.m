clear all;
close all;


subID='012-1';
saveflag=1;

%Specify script parameters


temp_file = ['logs/bdm_items_sub_',subID,'.mat'];
load(temp_file)
bdm_item_value_orig = value;
no_response_ind=bdm_item_value_orig==100;
bdm_item_value=bdm_item_value_orig(~no_response_ind);
bdm_item_orig = item;
bdm_item=bdm_item_orig(~no_response_ind);
bdm_item_category = bdm_item>=71; %0 is food. 1 is trinket.


food_value_matrix_orig=[bdm_item(bdm_item_category==0) bdm_item_value(bdm_item_category==0)];
trinket_value_matrix_orig=[bdm_item(bdm_item_category==1) bdm_item_value(bdm_item_category==1)];

trinket_value_matrix=trinket_value_matrix_orig;
food_value_matrix=food_value_matrix_orig;
max_food_value=max(food_value_matrix(:,2));
max_trinket_value=max(trinket_value_matrix(:,2));
maxValue_in_bin(1)=min(max_food_value, max_trinket_value);
items_per_bin=4;
%Food and trinket bins
for bin=1:5
    minValue_in_bin(bin)=min(maxk(food_value_matrix(:,2)-maxValue_in_bin(bin),items_per_bin))+maxValue_in_bin(bin);
    if bin>1
        if minValue_in_bin(bin)==minValue_in_bin(bin-1)
            food_value_matrix_copy=food_value_matrix;
            food_value_matrix(food_value_matrix(:,2)>=minValue_in_bin(bin),:)=[];
            if isempty(food_value_matrix)
                sprintf('Overlapping bin values');
                food_value_matrix=food_value_matrix_copy;
            end
            minValue_in_bin(bin)=min(maxk(food_value_matrix(:,2)-maxValue_in_bin(bin),items_per_bin))+maxValue_in_bin(bin);
        end
    end
    maxValue_in_bin(bin+1)=minValue_in_bin(bin);
    if nnz(food_value_matrix(:,2)>minValue_in_bin(bin))>4
        FoodObjects = datasample(food_value_matrix(food_value_matrix(:,2)>minValue_in_bin(bin),1),4,'Replace',false);
        bin_objects_food{bin}=food_value_matrix(ismember(food_value_matrix(:,1),FoodObjects),:);
        
        TrinketObjects=datasample(trinket_value_matrix(trinket_value_matrix(:,2)>minValue_in_bin(bin) & trinket_value_matrix(:,2)<=maxValue_in_bin(bin),1),...
            min(nnz(trinket_value_matrix(:,2)>minValue_in_bin(bin) & trinket_value_matrix(:,2)<=maxValue_in_bin(bin)),4),'Replace',false);
        bin_objects_trinket{bin}=trinket_value_matrix(ismember(trinket_value_matrix(:,1),TrinketObjects),:);
    else
        bin_objects_food{bin}=food_value_matrix(food_value_matrix(:,2)>minValue_in_bin(bin),:);
        TrinketObjects=datasample(trinket_value_matrix(trinket_value_matrix(:,2)>minValue_in_bin(bin) & trinket_value_matrix(:,2)<=maxValue_in_bin(bin),1),...
            min(nnz(trinket_value_matrix(:,2)>minValue_in_bin(bin) & trinket_value_matrix(:,2)<=maxValue_in_bin(bin)),length(bin_objects_food{bin}(:,1))),'Replace',false);
        bin_objects_trinket{bin}=trinket_value_matrix(ismember(trinket_value_matrix(:,1),TrinketObjects),:);
    end
    extra_FoodObjects_needed=items_per_bin-length(bin_objects_food{bin}(:,1));
    extra_FoodObjects=datasample(food_value_matrix(food_value_matrix(:,2)==minValue_in_bin(bin),1),extra_FoodObjects_needed,'Replace',false);
    bin_objects_food{bin}=[bin_objects_food{bin}; food_value_matrix(ismember(food_value_matrix(:,1),extra_FoodObjects),:)];
    food_value_matrix(ismember(food_value_matrix(:,1),bin_objects_food{bin}(:,1)),:)=[];
    
    extra_TrinketObjects_needed=items_per_bin-length(bin_objects_trinket{bin}(:,1));
    if nnz(trinket_value_matrix(:,2)==minValue_in_bin(bin))>=extra_TrinketObjects_needed
        extra_TrinketObjects=datasample(trinket_value_matrix(trinket_value_matrix(:,2)==minValue_in_bin(bin),1),extra_TrinketObjects_needed,'Replace',false);
    else
        extra_TrinketObjects=trinket_value_matrix(trinket_value_matrix(:,2)==minValue_in_bin(bin),1);
    end
    
    extra_TrinketObjects_needed=extra_TrinketObjects_needed-length(extra_TrinketObjects);
    
    bin_objects_trinket{bin}=[bin_objects_trinket{bin}; trinket_value_matrix(ismember(trinket_value_matrix(:,1),extra_TrinketObjects),:)];
    trinket_value_matrix(ismember(trinket_value_matrix(:,1),bin_objects_trinket{bin}(:,1)),:)=[];
    
    extra_TrinketObjects=datasample(trinket_value_matrix(trinket_value_matrix(:,2)>minValue_in_bin(bin) & trinket_value_matrix(:,2)<=maxValue_in_bin(bin),1),...
        min(nnz(trinket_value_matrix(:,2)>minValue_in_bin(bin) & trinket_value_matrix(:,2)<=maxValue_in_bin(bin)),extra_TrinketObjects_needed),'Replace',false);
end


if (minValue_in_bin(5)~=0 && min(bdm_item_value)==0) || (minValue_in_bin(5)~=1 && min(bdm_item_value)==1)
    
    food_value_matrix=food_value_matrix_orig;
    trinket_value_matrix=trinket_value_matrix_orig;
    for bin=1:3
        trinket_value_matrix(ismember(trinket_value_matrix(:,1),bin_objects_trinket{bin}(:,1)),:)=[];
        food_value_matrix(ismember(food_value_matrix(:,1),bin_objects_food{bin}(:,1)),:)=[];
    end
    
    maxValue_in_bin(4)=minValue_in_bin(4);
    minValue_in_bin(5)=min(bdm_item_value);
    minValue_in_bin(4)=minValue_in_bin(4)/2;
    maxValue_in_bin(5)=minValue_in_bin(4);
   for bin=4:5
      replacementObjects_food=datasample(food_value_matrix(food_value_matrix(:,2)>=minValue_in_bin(bin) & food_value_matrix(:,2)<=maxValue_in_bin(bin),1),...
          min(nnz(food_value_matrix(:,2)>=minValue_in_bin(bin) & food_value_matrix(:,2)<=maxValue_in_bin(bin)),4),'Replace',false);
      replacementObjects_trinkets=datasample(trinket_value_matrix(trinket_value_matrix(:,2)>=minValue_in_bin(bin) & trinket_value_matrix(:,2)<=maxValue_in_bin(bin),1),...
          min(nnz(trinket_value_matrix(:,2)>=minValue_in_bin(bin) & trinket_value_matrix(:,2)<=maxValue_in_bin(bin)),4),'Replace',false);
      
      bin_objects_trinket{bin}=trinket_value_matrix(ismember(trinket_value_matrix(:,1),replacementObjects_trinkets),:);
      trinket_value_matrix(ismember(trinket_value_matrix(:,1),bin_objects_trinket{bin}(:,1)),:)=[];
      bin_objects_food{bin}=food_value_matrix(ismember(food_value_matrix(:,1),replacementObjects_food),:);
      food_value_matrix(ismember(food_value_matrix(:,1),bin_objects_food{bin}(:,1)),:)=[];
   end
end

for bin=1:5
    expansion=0;
   while length(bin_objects_trinket{bin}(:,1))<4
       extra_TrinketObjects_needed=4-length(bin_objects_trinket{bin}(:,1));
       extra_TrinketObjects=datasample(trinket_value_matrix(trinket_value_matrix(:,2)>=minValue_in_bin(bin)-expansion & trinket_value_matrix(:,2)<=maxValue_in_bin(bin)+expansion,1),...
        min(nnz(trinket_value_matrix(:,2)>=minValue_in_bin(bin)-expansion & trinket_value_matrix(:,2)<=maxValue_in_bin(bin)+expansion),extra_TrinketObjects_needed),'Replace',false);
    
    bin_objects_trinket{bin}=[bin_objects_trinket{bin}; trinket_value_matrix(ismember(trinket_value_matrix(:,1),extra_TrinketObjects),:)];
    trinket_value_matrix(ismember(trinket_value_matrix(:,1),bin_objects_trinket{bin}(:,1)),:)=[];
    
    expansion=expansion+1;
   end
   
   expansion=0;
  while length(bin_objects_food{bin}(:,1))<4
       extra_FoodObjects_needed=4-length(bin_objects_food{bin}(:,1));
       extra_FoodObjects=datasample(food_value_matrix(food_value_matrix(:,2)>=minValue_in_bin(bin)-expansion & food_value_matrix(:,2)<=maxValue_in_bin(bin)+expansion,1),...
        min(nnz(food_value_matrix(:,2)>=minValue_in_bin(bin)-expansion & food_value_matrix(:,2)<=maxValue_in_bin(bin)+expansion),extra_FoodObjects_needed),'Replace',false);
    
    bin_objects_food{bin}=[bin_objects_food{bin}; food_value_matrix(ismember(food_value_matrix(:,1),extra_FoodObjects),:)];
    food_value_matrix(ismember(food_value_matrix(:,1),bin_objects_food{bin}(:,1)),:)=[];
    
    expansion=expansion+1;
   end
end

trinket_values=[];
food_values=[];
for bin=1:5
    trinket_values=[trinket_values; bin_objects_trinket{bin}(:,2)];
    food_values=[food_values; bin_objects_food{bin}(:,2)];
end

figure();
set(gcf,'units','normalized','outerposition',[0 0 1 1]);
subplot(2,6,[1:3 7:9])
histogram(trinket_values)
hold on;
histogram(food_values)
hold off;
legend('Trinkets','Foods');
title('Sequential search method');

fprintf('Trinket median: %0.1f  food median: %0.1f \ntrinket mean: %0.1f food mean: %0.1f \nexcess kurtosis: %0.2f \nskewness: %0.2f \nexcess variance: %0.2f',...
    median(trinket_values),median(food_values),mean(trinket_values),mean(food_values),kurtosis([trinket_values; food_values])-1.8,skewness([trinket_values; food_values]),...
    var([trinket_values; food_values],1)-power(max([trinket_values; food_values])-min([trinket_values; food_values]),2)/12)
for bin=1:5
    if bin<4
        subplot(2,6,3+bin)
    else
        subplot(2,6,6+bin)
    end
    histogram(bin_objects_trinket{bin}(:,2))
    hold on;
    histogram(bin_objects_food{bin}(:,2))
    hold off;
    if bin==1
        legend('Trinkets','Foods');
    end
    title(sprintf('Bin #%d',6-bin))
end
maxValue_in_bin(1:5)
minValue_in_bin

if saveflag

    saveas(gcf,[sprintf('Figures/SubsampledDistribution_SequentialSearchMethod_Subject_%s_generated_%s', subID,date) '.jpg'])
   
end

