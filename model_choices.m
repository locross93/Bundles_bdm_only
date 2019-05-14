%run this with variables from fMRI_sanity_checks

correct_choices = [];

for i=1:length(item_list)
    if item_list(i,2) == -1
        item_ind = find(bdm_item == item_list(i,1));
        item_value = mean(bdm_item_value(item_ind));
        more_value_bool = item_value > median_bid_item;
        if more_value_bool == choice_list(i)
            correct_choices = [correct_choices; 1];
        else
            correct_choices = [correct_choices; 0];
        end
    end
end

disp('Percentage of correct individual item choices')
disp(mean(correct_choices))

%logistic regression for bundles

%find bundle trials
bundle_trials = find(item_list(:,2) ~= -1);
bundle_item_list = item_list(bundle_trials,:) ;
bundle_choice_list = choice_list(bundle_trials);

remove_errors=0;
for j=1:2
    for i=1:length(bundle_item_list(:,1))
        if any(bdm_item==bundle_item_list(i,j))
            %for items valued every day, take the first value
            temp = bdm_item_value(bdm_item==bundle_item_list(i,j));
            bundle_item_values(i,j)=temp(1);
        else
            bundle_item_values(i,j)=-1; %Error code
            remove_errors=1;
        end
    end
end

%remove error trials
not_error_inds = find(bundle_choice_list ~= 2);
bundle_item_values = bundle_item_values(not_error_inds,:);
bundle_choice_list = bundle_choice_list(not_error_inds);

[b,dev,stats] = glmfit(bundle_item_values,bundle_choice_list,'binomial','logit');
preds = glmval(b,bundle_item_values,'logit')';
preds_bin = round(preds);
acc = preds_bin' == bundle_choice_list;

disp('Logistic Regression Accuracy')
disp(mean(acc))