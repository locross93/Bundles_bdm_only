

y ~ b1 + (x1^b2 + x2^b3)^(1/b4)


modelfun = @(b,x)b(1) + b(2)*x(:,1).^b(3) + ...
    b(4)*x(:,2).^b(5);
beta0 = [-50 500 -1 500 -1];
mdl = fitnlm(tbl,modelfun,beta0)

y = bdm_bundle_value;
X = bdm_bundle_item_values;
modelfun = @(b,x)b(1) + (b(2)*x(:,1).^b(3) + b(4)*x(:,2).^b(5)).^(1/b(6));
beta0 = [1 1 1 1 1 1];
mdl = fitnlm(X,y,modelfun,beta0)

y = bdm_bundle_value;
X = bdm_bundle_item_values;
modelfun = @(b,x)b(1) + (b(2)*x(:,1).^b(3) + b(4)*x(:,2).^b(5));
beta0 = [1 1 1 1 1];
mdl = fitnlm(X,y,modelfun,beta0)


y = bdm_bundle_value;
X = bdm_bundle_item_values;
modelfun = @(b,x)b(1) + (x(:,1).^b(2) + x(:,2).^b(3)).^(1/b(4));
beta0 = [-0.2 -0.2 -0.2 -0.2];
mdl = fitnlm(X,y,modelfun,beta0)

LM_leftright=fitlm([bdm_bundle_item_values],bdm_bundle_value,'VarNames',{'LeftItemValue','RightItemValue','BundleValue'},'Intercept',intercept)

modelfun = @(b,x)b(1) + (x(:,1).^b(2) + x(:,2).^b(3)).^(1/b(4));
beta0 = [0.2 0.2 0.2 0.2];
mdl = fitnlm(bdm_mixedbundle_item_values,bdm_mixedbundle_value,modelfun,beta0)

LM_foodtrinket=fitlm(bdm_mixedbundle_item_values,bdm_mixedbundle_value,'VarNames',{'FoodValue','TrinketValue','BundleValue'},'Intercept',intercept)
