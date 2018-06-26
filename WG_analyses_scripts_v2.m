

%% Ranking objects by value

bdm_bundle_value_orig=[];
bdm_item_value_orig=[];
bdm_item_orig = [];
bdm_bundleItems_orig = [];
bdm_bundle_ItemValue_orig=[];

for subj=1:length(subjects)
    item_file = ['logs/bdm_items_sub_',subjects{subj},'.mat'];
    bundle_file= ['logs/bdm_bundle_sub_',subjects{subj},'.mat'];
    
    load(item_file);
    item_value=value;
    item_objnum=item;
    
    load(bundle_file);
    bundle_value=value;
    bundle_items=item;
    
    bdm_item_value_orig = cat(1,bdm_item_value_orig,item_value);
    bdm_item_orig = cat(1,bdm_item_orig,item_objnum);
    
    bdm_bundle_value_orig = cat(1,bdm_bundle_value_orig,bundle_value);
    bdm_bundleItems_orig = cat(1,bdm_bundleItems_orig,bundle_items);
    
    for j=1:2
        for i=1:length(bundle_items(:,1))
            bdm_bundle_item_values(i,j)=item_value(item_objnum==bundle_items(i,j));
        end
    end
    
    bdm_bundle_ItemValue_orig = cat(1,bdm_bundle_ItemValue_orig,bdm_bundle_item_values);
end

%%
% Clean up any non-response errors in individual items
no_response_ind=bdm_item_value_orig==100;
bdm_item_value=bdm_item_value_orig(~no_response_ind);
bdm_item=bdm_item_orig(~no_response_ind);

%Classify as food or trinket
bdm_item_category = bdm_item>71; %0 is food. 1 is trinket.

%Clean up bundles for any non-response errors
no_response_ind=bdm_bundle_value_orig==100 | any(bdm_bundle_ItemValue_orig==100,2);
bdm_bundle_value=bdm_bundle_value_orig(~no_response_ind);
bdm_bundle_ItemValue=bdm_bundle_ItemValue_orig(~no_response_ind,:);
bdm_bundleItems=bdm_bundleItems_orig(~no_response_ind,:);

%% Highest and Lowest Valued Single Objects

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

% figure;
% plot(sort_order,objectvalue_average_sort,'k.');
% hold on;
% errorbar(sort_order,objectvalue_average_sort,objectvalue_std_sort,'k.');
% hold off;
% xlim([0 140])
% ylim([-3 16]);
% xlabel('Object number');
% ylabel('Value with STD (dollars)');
% set(gcf,'units','normalized','outerposition',[0 0 1 1]);
% set(gcf,'Paperpositionmode','auto','Papersize',[20 20]);


%% Regressions

differentobjects=figure(1);
set(gcf,'units','normalized','outerposition',[0 0 1 1]);
set(gcf,'Paperpositionmode','auto','Papersize',[20 20]);
subplot(2,3,2)
LM_leftright=fitlm(bdm_bundle_ItemValue,bdm_bundle_value,'VarNames',{'LeftItem','RightItem','BundleValue'},'Intercept',false)
fprintf('R2 value: %f \n', LM_leftright.Rsquared.Ordinary);

PredictedValues=feval(LM_leftright,bdm_bundle_ItemValue);
plot(PredictedValues,bdm_bundle_value,'.','MarkerSize',20);
xlabel('Predicted value from LM');
ylabel('Reported value');
title(sprintf('Overall regression - L v R: NumSubjects=%d',length(subjects)));
text(0.5,18,sprintf('R2: %0.3f',LM_leftright.Rsquared.Ordinary));
ylim([0 20]);

%Define class of each bundle: Class 0: Mixed bundles, Class 1: Trinket
%bundles, Class 2: Food bundles
bdm_class_names={'Mixed','Trinket','Food'};
bdm_bundle_class=all(bdm_bundleItems>70,2);
bdm_bundle_class=bdm_bundle_class+(2*all(bdm_bundleItems<70,2));

%Find all bundles of same objects combined
bdm_bundle_same=bdm_bundleItems(:,1)==bdm_bundleItems(:,2);


%Linear regression across food (x1) and trinket item (x2) for mixed bundles
%Bundle value=B1*x1+B2*x2+0 - No intercept term
bdm_mixedbundle_value=bdm_bundle_value(bdm_bundle_class==0);
[~,sort_order]=sort(bdm_bundleItems(bdm_bundle_class==0,:),2);
bdm_mixedbundle_itemValues=bdm_bundle_ItemValue(bdm_bundle_class==0,:);
for i=1:length(sort_order)
    bdm_mixedbundle_itemValues(i,:)=bdm_mixedbundle_itemValues(i,sort_order(i,:));
end

LM_mixedbundle=fitlm(bdm_mixedbundle_itemValues,bdm_mixedbundle_value,'VarNames',{'Food','Trinket','BundleValue'},'Intercept',false)
fprintf('R2 value: %f \n', LM_mixedbundle.Rsquared.Ordinary);
subplot(2,3,4)
PredictedValues=feval(LM_mixedbundle,bdm_mixedbundle_itemValues);
plot(PredictedValues,bdm_mixedbundle_value,'.','MarkerSize',20);
xlabel('Predicted value from LM');
ylabel('Reported value');
title('Mixed bundle regression');
text(0.5,18,sprintf('R2: %0.3f',LM_mixedbundle.Rsquared.Ordinary));
ylim([0 20]);
%Linear regression for food bundles or trinket bundles (L vs R analysis again)
%Bundle value=B1*x1 +B2*x2- No intercept term

sameobjects=figure(2);
set(gcf,'units','normalized','outerposition',[0 0 1 1]);
set(gcf,'Paperpositionmode','auto','Papersize',[20 20]);

for bdm_class=1:2
    LM_class_leftright=fitlm(bdm_bundle_ItemValue(bdm_bundle_class==bdm_class,:),bdm_bundle_value(bdm_bundle_class==bdm_class),'VarNames',{'LeftItem','RightItem','BundleValue'},'Intercept',false)
    fprintf('%s R2 value: %f \n',bdm_class_names{bdm_class+1}, LM_class_leftright.Rsquared.Ordinary);
    figure(1);
    subplot(2,3,4+bdm_class)
    PredictedValues=feval(LM_class_leftright,bdm_bundle_ItemValue(bdm_bundle_class==bdm_class,:));
    plot(PredictedValues,bdm_bundle_value(bdm_bundle_class==bdm_class),'.','MarkerSize',20);
    xlabel('Predicted value from LM');
    ylabel('Reported value');
    title(sprintf('Regression for different object %s - L v R',bdm_class_names{bdm_class+1}));
    text(0.5,18,sprintf('R2: %0.3f',LM_class_leftright.Rsquared.Ordinary));
    ylim([0 20]);
    
    figure(2);
    subplot(1,2,bdm_class);
    LM_class_same=fitlm(bdm_bundle_ItemValue(bdm_bundle_class==bdm_class & bdm_bundle_same,:),bdm_bundle_value(bdm_bundle_class==bdm_class & bdm_bundle_same),'VarNames',{'LeftItem','RightItem','BundleValue'},'Intercept',false)
    fprintf('%s R2 value: %f \n',bdm_class_names{bdm_class+1}, LM_class_leftright.Rsquared.Ordinary);

    PredictedValues=feval(LM_class_leftright,bdm_bundle_ItemValue(bdm_bundle_class==bdm_class & bdm_bundle_same,:));
    plot(PredictedValues,bdm_bundle_value(bdm_bundle_class==bdm_class & bdm_bundle_same),'.','MarkerSize',20);
    xlabel('Predicted value from LM');
    ylabel('Reported value');
    title(sprintf('Regression for same object %s - L v R',bdm_class_names{bdm_class+1}));
    text(0.5,18,sprintf('R2: %0.3f',LM_class_leftright.Rsquared.Ordinary));
    ylim([0 20]);
end



%% Save figures
saveas(differentobjects,[sprintf('Figures/RegressionsDifferentObjects_numSubjects_%d_generated_%s', length(subjects),date) '.jpg'])
saveas(sameobjects,[sprintf('Figures/RegressionsSameObjects_numSubjects_%d_generated_%s', length(subjects),date) '.jpg'])

%% Close all
closeall=1;
if closeall
    close all
end