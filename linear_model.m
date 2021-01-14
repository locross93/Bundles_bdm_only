%Initialize workspace
clearvars;
clc;

%can analyze one day or across all days
%fmri subjects include '101','102','103','104','105','106''107','108','109','110','111','112','113','114'
subID = '101';

%intercept
intercept = true;

%y bundle values, X - individual item values 
y = [];
X = [];
for day=1:3
    subID_day = [subID,'-',num2str(day)];
    temp_file = ['logs/bdm_items_sub_',subID_day,'.mat'];
    load(temp_file)
    bdm_item_value = value;
    bdm_item = item;
    temp_file = ['logs/bdm_bundle_sub_',subID_day,'.mat'];
    load(temp_file)
    bdm_bundle_value = value;
    bdm_bundle = item;

    y = [y; bdm_bundle_value];
    X_temp = zeros(length(bdm_bundle_value), 2);

    for j=1:length(bdm_bundle_value)
        temp_bundle = bdm_bundle(j,:);
        left_item_ind = find(bdm_item == temp_bundle(1));
        X_temp(j,1) = bdm_item_value(left_item_ind);
        right_item_ind = find(bdm_item == temp_bundle(2));
        X_temp(j,2) = bdm_item_value(right_item_ind);
    end
    X = [X; X_temp];
end

%Assuming that first column is left item and 2nd column is right item.
%Linear regression across left (x1) and right (x2) item
%Bundle value=B1*x1+B2*x2+C

%remove errors
error_ind=any(X==-1,2);
if max(error_ind) == 1
    X=X(~error_ind);
    y=y(~error_ind);
end

LM_leftright=fitlm(X,y,'VarNames',{'LeftItemValue','RightItemValue','BundleValue'},'Intercept',intercept)
fprintf('R2 value: %f \n', LM_leftright.Rsquared.Adjusted);
beta=LM_leftright.Coefficients.Estimate;

figure
PredictedValues=feval(LM_leftright,X);
%plot(PredictedValues,bdm_bundle_value,'.','MarkerSize',20);
binscatter(PredictedValues,y,[20 20])
colormap(gca,'parula')
axis equal
hold on
plot(y, y,'MarkerSize',10);
xlabel('Predicted value from LM');
ylabel('Reported value');
title(sprintf('Left vs Right regression - Subject %s',subID),'FontSize',18);
xlim([0 20])
xticks([0:2:20])
ylim([0 20]);
yticks([0:2:20])
if intercept
    text(12,4.5,sprintf('R2 value: %0.3f \n\\beta1 (intercept): %0.3f \n\\beta2 (left): %0.3f \n\\beta3 (right): %0.3f', LM_leftright.Rsquared.Adjusted, beta(1), beta(2), beta(3)),'FontSize',14);
else
    text(12,4.5,sprintf('R2 value: %0.3f \n\\beta1 (left): %0.3f \n\\beta2 (right): %0.3f', LM_leftright.Rsquared.Adjusted, beta(1), beta(2)),'FontSize',14);
end