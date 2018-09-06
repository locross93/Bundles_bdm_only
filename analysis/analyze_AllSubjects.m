close all;
clear all;

subjects={'001-1','002-1','003-1','004-1','005-1','006-1','007-1','008-1','009-1','010-1','011-1','012-1','800-1','802-1'};

old_models=cell(4,1);
new_models=cell(4,1);

for i=1:4
    old_models{i}=zeros(length(subjects),5);  %B1 p1 B2 p2 R2 for regression model
    new_models{i}=zeros(length(subjects),7); %B1 p1 B2 p2 B3 p3 R2 for regression model
end


for subjectID=1:length(subjects)
    %new model
   new_LinearModels=WG_analysis_pilotdata_v2b({subjects{subjectID}},0);
   for LM=1:4 %not analyzing same food or same trinket bundles using this script
       temp_LM=new_LinearModels{2,LM};
       beta=temp_LM.Coefficients.Estimate;
       pvalue=temp_LM.Coefficients.pValue;
       new_models{LM}(subjectID,[1 3 5])=[beta(1) beta(2) beta(3)];
       new_models{LM}(subjectID,[2 4 6])=[pvalue(1) pvalue(2) pvalue(3)];
       new_models{LM}(subjectID,7)=temp_LM.Rsquared.Adjusted;      
   end
   
   
   %old model
   old_LinearModels=WG_analysis_pilotdata_v2c({subjects{subjectID}},0);
   for LM=1:4
       temp_LM=old_LinearModels{2,LM};
       beta=temp_LM.Coefficients.Estimate;
       pvalue=temp_LM.Coefficients.pValue;
       old_models{LM}(subjectID,[1 3])=[beta(1) beta(2)];
       old_models{LM}(subjectID,[2 4])=[pvalue(1) pvalue(2)];
       old_models{LM}(subjectID,5)=temp_LM.Rsquared.Adjusted;      
   end
end
