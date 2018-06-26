
function LinearModels=WG_analysis_pilotdata_v2b(subjectsToAnalyze,PlotFigure)
%Updated to handle z-scored data and incorporate object similarity 6/21/18
%WG

if ~exist('subjectsToAnalyze','var')
    subjects={'005-1','006-1','007-1','008-1','009-1','010-1','011-1','012-1'};
else
    subjects=subjectsToAnalyze;
end

if ~exist('PlotFigure','var')
    plotflag=0;
else
    plotflag=PlotFigure;
end

object_similarity_matrix=dlmread('word2vec_item_similarity.csv');


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

bdm_bundle_similarity=zeros(size(bdm_bundle_value));
bdm_bundleItems_sort=sort(bdm_bundleItems,2);
for bundle=1:length(bdm_bundle_value)
    if bdm_bundleItems_sort(bundle,1)~=bdm_bundleItems_sort(bundle,2)
        bdm_bundle_similarity(bundle)=object_similarity_matrix(object_similarity_matrix(:,1)==bdm_bundleItems_sort(bundle,1) & object_similarity_matrix(:,2)==bdm_bundleItems_sort(bundle,2),3);
    else
        bdm_bundle_similarity(bundle)=1; %Identical objects have a similarity of 1.
    end
end
independent_variables=[bdm_bundle_ItemValue];
%independent_variables=[bdm_bundle_ItemValue bdm_bundle_similarity];
dependent_variable=bdm_bundle_value;
Variable_Names={'LeftItemValue','RightItemValue','BundleValue'}



LM_leftright=fitlm(zscore(independent_variables),zscore(dependent_variable),'VarNames',Variable_Names,'Intercept',false)
fprintf('R2 value: %f \n', LM_leftright.Rsquared.Adjusted);
beta=LM_leftright.Coefficients.Estimate;
PredictedValues=feval(LM_leftright,independent_variables); %check validity of this line
if plotflag
    differentobjects=figure(1);
    set(gcf,'units','normalized','outerposition',[0 0 1 1]);
    set(gcf,'Paperpositionmode','auto','Papersize',[20 20]);
    subplot(2,3,2)
    plot(PredictedValues,dependent_variable,'.','MarkerSize',20);%check validity of this line
    xlabel('Predicted value from LM');
    ylabel('Reported value');
    title(sprintf('Overall regression - L v R: NumSubjects=%d',length(subjects)));
    text(0.5,18,sprintf('R2: %0.3f \n\\beta1: %0.3f \n\\beta2: %0.3f \n\\beta2: %0.3f',LM_leftright.Rsquared.Adjusted, beta(1), beta(2), beta(2)));
    ylim([0 20]);
    try
        xlim([0 max(PredictedValues)]);
    catch
        xlim([0 20]);
    end
end

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
bdm_mixedbundle_similarity=bdm_bundle_similarity(bdm_bundle_class==0);
for i=1:length(sort_order)
    bdm_mixedbundle_itemValues(i,:)=bdm_mixedbundle_itemValues(i,sort_order(i,:));
end

independent_variables=[bdm_mixedbundle_itemValues];
%independent_variables=[bdm_mixedbundle_itemValues bdm_mixedbundle_similarity];
dependent_variable=bdm_mixedbundle_value;
Variable_Names={'FoodValue','TrinketValue','BundleValue'};


LM_mixedbundle=fitlm(zscore(independent_variables),zscore(dependent_variable),'VarNames',Variable_Names,'Intercept',false)
fprintf('R2 value: %f \n', LM_mixedbundle.Rsquared.Adjusted);
beta=LM_mixedbundle.Coefficients.Estimate;

PredictedValues=feval(LM_mixedbundle,independent_variables); %Check validity of this line
if plotflag
    subplot(2,3,4)
    plot(PredictedValues,dependent_variable,'.','MarkerSize',20); %Check validity of this line
    xlabel('Predicted value from LM');
    ylabel('Reported value');
    title('Mixed bundle regression');
    text(0.5,18,sprintf('R2: %0.3f \n\\beta1: %0.3f \n\\beta2: %0.3f \n\\beta3: %0.3f',LM_mixedbundle.Rsquared.Adjusted, beta(1), beta(2), beta(3)));
    ylim([0 20]);
    try
        xlim([0 max(PredictedValues)]);
    catch
        xlim([0 20]);
    end
end
%Linear regression for food bundles or trinket bundles (L vs R analysis again)
%Bundle value=B1*x1 +B2*x2- No intercept term
if plotflag
sameobjects=figure(2);
set(gcf,'units','normalized','outerposition',[0 0 1 1]);
set(gcf,'Paperpositionmode','auto','Papersize',[20 20]);
end

for bdm_class=1:2
    independent_variables=[bdm_bundle_ItemValue(bdm_bundle_class==bdm_class,:)];
    %independent_variables=[bdm_bundle_ItemValue(bdm_bundle_class==bdm_class,:) bdm_bundle_similarity(bdm_bundle_class==bdm_class)];
    dependent_variable=bdm_bundle_value(bdm_bundle_class==bdm_class);
    VariableNames={'LeftItemValue','RightItemValue','BundleValue'};
    
    LM_class_leftright{bdm_class}=fitlm(zscore(independent_variables),zscore(dependent_variable),'VarNames',VariableNames,'Intercept',false);
    LM_class_leftright{bdm_class}
    fprintf('%s R2 value: %f \n',bdm_class_names{bdm_class+1}, LM_class_leftright{bdm_class}.Rsquared.Adjusted);
    beta=LM_class_leftright{bdm_class}.Coefficients.Estimate;
    PredictedValues=feval(LM_class_leftright{bdm_class},independent_variables); %Check validity of this line
    if plotflag
        figure(1);
        subplot(2,3,4+bdm_class)
        
        plot(PredictedValues,dependent_variable,'.','MarkerSize',20); %Check validity of this line
        xlabel('Predicted value from LM');
        ylabel('Reported value');
        title(sprintf('Regression for different object %s - L v R',bdm_class_names{bdm_class+1}));
        text(0.5,18,sprintf('R2: %0.3f \n\\beta1: %0.3f \n\\beta2: %0.3f \n\\beta3: %0.3f',LM_class_leftright{bdm_class}.Rsquared.Adjusted, beta(1), beta(2), beta(3)));
        ylim([0 20]);
        try
            xlim([0 max(PredictedValues)]);
        catch
            xlim([0 20]);
        end
    end
    
    
    
    try
        LM_class_same{bdm_class}=fitlm(bdm_bundle_ItemValue(bdm_bundle_class==bdm_class & bdm_bundle_same,1),bdm_bundle_value(bdm_bundle_class==bdm_class & bdm_bundle_same),'VarNames',{'ItemValue','BundleValue'},'Intercept',false);
        LM_class_same{bdm_class}
        fprintf('%s R2 value: %f \n',bdm_class_names{bdm_class+1}, LM_class_same{bdm_class}.Rsquared.Adjusted);
        beta=LM_class_same{bdm_class}.Coefficients.Estimate;
        PredictedValues=feval(LM_class_same{bdm_class},bdm_bundle_ItemValue(bdm_bundle_class==bdm_class & bdm_bundle_same,1));
        if plotflag
            figure(2);
            subplot(2,2,bdm_class);
            
            plot(PredictedValues,bdm_bundle_value(bdm_bundle_class==bdm_class & bdm_bundle_same),'.','MarkerSize',20);
            xlabel('Predicted value from LM');
            ylabel('Reported value');
            title(sprintf('Regression for same object %s - L v R',bdm_class_names{bdm_class+1}));
            
            text(0.5,18,sprintf('R2: %0.3f \n\\beta1: %0.3f',LM_class_same{bdm_class}.Rsquared.Adjusted, beta(1)));
            ylim([0 20]);
            try
                xlim([0 max(PredictedValues)]);
            catch
                xlim([0 20]);
            end
            
            subplot(2,2,2+bdm_class);
            plot(LM_class_same{bdm_class});
            ylim([0 20]);
            ylabel('Reported value');
            title(sprintf('Regression for same object %s - L v R',bdm_class_names{bdm_class+1}));
        end
    catch
        disp('Could not run analysis on same object bundles: insufficient trials');
    end
end

%% Output LinearModels

LinearModels={'LeftRight-All','MixedBundle','LeftRight-FoodBundles','LeftRight-TrinketBundles','LeftRight-SameFood','LeftRight-SameTrinket';
    LM_leftright,  LM_mixedbundle, LM_class_leftright{1}, LM_class_leftright{2},      LM_class_same{1},       LM_class_same{2}};


%% Save figures
if plotflag
if length(subjects)~=1
    saveas(differentobjects,[sprintf('Figures/RegressionsDifferentObjects_numSubjects_%d_generated_%s', length(subjects),date) '.jpg'])
    saveas(sameobjects,[sprintf('Figures/RegressionsSameObjects_numSubjects_%d_generated_%s', length(subjects),date) '.jpg'])
else
    saveas(differentobjects,[sprintf('Figures/RegressionsDifferentObjects_Subject_%s_generated_%s', subjects{1},date) '.jpg'])
    saveas(sameobjects,[sprintf('Figures/RegressionsSameObjects_Subject_%s_generated_%s', subjects{1},date) '.jpg'])
end
end

%% Close all
closeall=0;
if closeall
    close all
end

end