close all;
clear all;

subjects={'005-1','006-1','007-1','008-1','009-1','010-1','011-1','012-1'};


%% Ranking objects by value

bdm_bundle_value_orig=[];
bdm_bundle_orig=[];
bdm_item_value_orig=[];
bdm_item_orig = [];

for subj=1:length(subjects)
   item_file = ['logs/bdm_items_sub_',subjects{subj},'.mat'];
   bundle_file= ['logs/bdm_bundle_sub_',subjects{subj},'_time.mat'];
    load(item_file); 
    load(bundle_file);
    bdm_item_value_orig = cat(1,bdm_item_value_orig,value);
    bdm_item_orig = cat(1,bdm_item_orig,item);
    decisionTime=time_DEC(:,2)-time_DEC(:,1);
    decisionTime_ind=ones(length(decisionTime),1);
    decisionTime_ind(1)=0;
    bdm_item_decisionTime_orig = cat(1,bdm_item_decisionTime_orig,decisionTime);
    decisionTime_ind_combined=cat(1,decisionTime_ind_combined,decisionTime_ind);
    
end


% Clean up any non-response errors
no_response_ind=bdm_item_value_orig==100;
bdm_item_value=bdm_item_value_orig(~no_response_ind);
bdm_item_value_subset=bdm_item_value_orig(~no_response_ind & decisionTime_ind_combined);
bdm_item=bdm_item_orig(~no_response_ind);
bdm_item_decisionTime=bdm_item_decisionTime_orig(~no_response_ind & decisionTime_ind_combined);
bdm_item_category = bdm_item>71; %0 is food. 1 is trinket.

objectnums=[1:70 101:140];
objectvalue_average=-1*ones(1,max(objectnums));
objectvalue_median=-1*ones(1,max(objectnums));
objectvalue_std=-1*ones(1,max(objectnums));
for obj=objectnums
    objectvalue_average(obj)=mean(bdm_item_value(bdm_item==obj));
    objectvalue_std(obj)=std(bdm_item_value(bdm_item==obj));
    objectvalue_median(obj)=median(bdm_item_value(bdm_item==obj));
end



[objectvalue_average_sort,sort_order]=sort(objectvalue_average,'descend');
objectvalue_average_sort=objectvalue_average_sort(1:length(objectnums));
objectvalue_std_sort=objectvalue_std(sort_order);
objectvalue_std_sort=objectvalue_std_sort(1:length(objectnums));
sort_order=sort_order(1:length(objectnums));


sort_order_food=sort_order(sort_order<101);
sort_order_trinket=sort_order(sort_order>=101);
objectvalue_average_sort_food=objectvalue_average_sort(sort_order<101);
objectvalue_average_sort_trinket=objectvalue_average_sort(sort_order>=101);
objectvalue_std_sort_food=objectvalue_std_sort(sort_order<101);
objectvalue_std_sort_trinket=objectvalue_std_sort(sort_order>=101);

food_mat=[sort_order_food' objectvalue_average_sort_food' objectvalue_std_sort_food'];
trinket_mat=[sort_order_trinket' objectvalue_average_sort_trinket' objectvalue_std_sort_trinket'];

figure;
plot(sort_order,objectvalue_average_sort,'k.');
hold on;
errorbar(sort_order,objectvalue_average_sort,objectvalue_std_sort,'k.');
hold off;
xlim([0 140])
ylim([-3 16]);
xlabel('Object number');
ylabel('Value with STD (dollars)');
set(gcf,'units','normalized','outerposition',[0 0 1 1]);
set(gcf,'Paperpositionmode','auto','Papersize',[20 20]);

%% Decision time
figure;
plot(bdm_item_decisionTime,bdm_item_value_subset,'.');
ylabel('Value of object');
xlabel('Decision time for object (sec)');

LM_TimeVsValue=fitlm(bdm_item_decisionTime,bdm_item_value_subset,'VarNames',{'Time','ItemValue'},'RobustOpts','on')

set(gcf,'units','normalized','outerposition',[0 0 1 1]);
set(gcf,'Paperpositionmode','auto','Papersize',[20 20]);

%% Regressions
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

LM_foodtrinket=fitlm(bdm_mixedbundle_item_values,bdm_mixedbundle_value,'VarNames',{'Food','Trinket','BundleValue'})

figure();
PredictedValues=feval(LM_foodtrinket,bdm_bundle_item_values);
plot(PredictedValues,bdm_bundle_value,'.','MarkerSize',20);
xlabel('Predicted value from LM');
ylabel('Reported value');

