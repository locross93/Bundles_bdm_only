% Checks for best distribution
for i=1:1000
    subjectIDs={'005-1','006-1','007-1','008-1','009-1','010-1','011-1','012-1','800-1','802-1'};
    for subject=1:length(subjectIDs)
        for method=1:2
            if method==1
                subjectmeasures{subject}=SubsampleNewDistribution_function(subjectIDs{subject},method);
            else
                temp_measures=SubsampleNewDistribution_function(subjectIDs{subject},method);
                subjectmeasures{subject}=[subjectmeasures{subject}; temp_measures; subjectmeasures{subject}-temp_measures;sign(abs(subjectmeasures{subject})-abs(temp_measures))];
            end
        end
        method_performance(subject)=sum(subjectmeasures{subject}(4,5:6));
    end
    overall_performance(i)=sum(method_performance);
end
histogram(overall_performance)