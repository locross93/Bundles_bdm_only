clear all;
close all;


subID='009-1';


%Specify script parameters


temp_file = ['logs/bdm_items_sub_',subID,'.mat'];
load(temp_file)
bdm_item_value_orig = value;
no_response_ind=bdm_item_value_orig==100;
bdm_item_value=bdm_item_value_orig(~no_response_ind);
bdm_item_orig = item;
bdm_item=bdm_item_orig(~no_response_ind);
bdm_item_category = bdm_item>=71; %0 is food. 1 is trinket.


% temp_file = ['logs/bdm_bundle_sub_',subID,'.mat'];
% load(temp_file)
% bdm_bundle_value_orig = value;
% no_response_ind=bdm_bundle_value_orig==100;
% bdm_bundle_value=bdm_bundle_value_orig(~no_response_ind);
% bdm_bundle_orig = item;
% bdm_bundle_items=bdm_bundle_orig(~no_response_ind,:);
% bdm_bundle_item_category = bdm_bundle_items>=71; %0 is food. 1 is trinket.

food_value_matrix_orig=[bdm_item(bdm_item_category==0) bdm_item_value(bdm_item_category==0)];
trinket_value_matrix_orig=[bdm_item(bdm_item_category==1) bdm_item_value(bdm_item_category==1)];




trinket_value_matrix=trinket_value_matrix_orig;
food_value_matrix=food_value_matrix_orig;
max_food_value=max(food_value_matrix(:,2));
max_trinket_value=max(trinket_value_matrix(:,2));
maxValue_in_bin(1)=min(max_food_value, max_trinket_value);
items_per_bin=4;
%Food and trinketbins
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
end

trinket_values=[];
food_values=[];
for bin=1:5
    trinket_values=[trinket_values; bin_objects_trinket{bin}(:,2)];
    food_values=[food_values; bin_objects_food{bin}(:,2)];
end

figure();
histogram(trinket_values)
hold on;
histogram(food_values)
hold off;
legend('Trinkets','Foods');

fprintf('Trinket median: %0.1f  food median: %0.1f',median(trinket_values),median(food_values))
figure();
for bin=1:5
    subplot(2,3,bin)
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

kurtosis([trinket_values; food_values])-1.8
skewness([trinket_values; food_values])


% %% Subsampling to generate desired distribution
% run_loop=1;
% 
% %test_distribution=repmat([1:5; 1:5],1,4);
% 
% counter=0;
% 
% while run_loop
%     counter=counter+1;
%     rdn_nums_food=randi(70,20,1);
%     rdn_nums_trinket=randi(40,20,1)+70;
%     bdm_subset_itemNumbers=[rdn_nums_food; rdn_nums_trinket];
%     bdm_food_subset_values=bdm_item_value(rdn_nums_food);
%     bdm_trinket_subset_values=bdm_item_value(rdn_nums_trinket);
%     bdm_subset_values=[bdm_food_subset_values; bdm_trinket_subset_values];
%     
%     %bdm_subset_values=[test_distribution(1,:)'; test_distribution(2,:)'];
%     
%     [counts, binedges,item_locations]=histcounts(bdm_subset_values,5);
%     
%     numfoods_in_bin=zeros(5,1);
%     numtrinkets_in_bin=zeros(5,1);
%     
%     if (all(counts==10) || all(counts==8))
%         for i=1:5
%             if counts(i)~=0
%                 numfoods_in_bin(i)=nnz(bdm_subset_itemNumbers(item_locations==i)<71);
%                 numtrinkets_in_bin(i)=nnz(bdm_subset_itemNumbers(item_locations==i)>=71);
%             end
%         end
%     end
%     
%     if all(numfoods_in_bin>=4) && all(numtrinkets_in_bin>=4)
%         run_loop=0;
%     end
%     
%     if mod(counter,5000)==0
%         counter
%     end
%     
%     if counter==1000000
%         break;
%     end
% end
% if counter~=1000000
%     median(bdm_item_value)
%     figure;
%     histogram(bdm_subset_values,binedges)
%     %plot(counts)
%     
%     pd=makedist('Uniform','Lower',min(bdm_subset_values),'Upper',max(bdm_subset_values));
%     h=kstest(bdm_subset_values,'CDF',pd)
% end
