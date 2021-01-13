clear all;

sub_list = {'104','105'};

full_sub_list = {};
for sub_num=1:length(sub_list)
    temp_sub_num = sub_list(sub_num);
    sub_w_days = {strcat(temp_sub_num,'-1'), strcat(temp_sub_num,'-2'), strcat(temp_sub_num,'-3')};
    full_sub_list{end+1} = sub_w_days;
end
full_sub_list = cat(2, full_sub_list{:});

for sub_num=1:length(full_sub_list)
    subID=full_sub_list{sub_num}{1};
    output_dir_3col='/Users/logancross/Documents/Bundle_Value/fmri/GLM/Three_column/';
    output_dir_mat='/Users/logancross/Documents/Bundle_Value/fmri/GLM/SPM/timing_files';
    data_dir='/Users/logancross/Documents/Bundle_Value/stim_presentation/Bundles_fMRI/';

    %Load item and bundle BDM to get value information for items
    temp_file = [data_dir,'logs/bdm_items_sub_',subID,'.mat'];
    load(temp_file);
    item_value=[item value];

    temp_file = [data_dir,'logs/bdm_bundle_sub_',subID,'.mat'];
    load(temp_file);
    bundle_items=item;
    bundle_value=value;

    %create struct for SPM
    subj_struct.left_button = cell(5,1);
    subj_struct.right_button = cell(5,1);
    subj_struct.value_dur = cell(5,1);
    subj_struct.value_onset = cell(5,1);
    subj_struct.value_param = cell(5,1);
    subj_struct.value_categ = cell(5,1);

    for fMRIrun=1:5
        %Load choice info trial and load variables
        temp_file = [data_dir,'logs/choice_run',num2str(fMRIrun),'_sub_',subID,'.mat'];
        load(temp_file);
        reference_pos=ref_pos; %Denotes position of reference amount. 1=Reference amount on right. 2=Ref amount of left
        trial_choice=choice; %Denotes reference vs item/bundle. 0=Reference bid. 1=Item/bundle
        trial_items=item;

        %Load timing file and load variables
        temp_file = [data_dir,'logs/choice_run',num2str(fMRIrun),'_sub_',subID,'_time.mat'];
        load(temp_file);
        DurationITI=durITI;
        timeChoice=time_DEC;
        timeITI=time_ITI;
        timeOut=time_OUT;
        time_col_labels={'Choice Time Start and End (2 col)', 'Outcome Time Start and End (2 col)', 'ITI Time Start and End (2 col)',};
        condensed_time=[timeChoice timeOut timeITI(2:end,:) ];

        ErrorTrial_ind=trial_choice==100;
        condensed_time_clean=condensed_time(~ErrorTrial_ind,:);

        %Left vs right button press
        left_buttonpress_ind=(reference_pos'==1 & trial_choice==1) | (reference_pos'==2 & trial_choice==0);
        right_buttonpress_ind=(reference_pos'==1 & trial_choice==0) | (reference_pos'==2 & trial_choice==1);

        left_buttonpress_times= condensed_time(left_buttonpress_ind,:);
        right_buttonpress_times=condensed_time(right_buttonpress_ind,:);


        %Type of choice
        refBid_choice_times=condensed_time(trial_choice==0,:);
        itemBundle_choice_times=condensed_time(trial_choice==1,:);


        %Item vs bundle choice
        item_trial_ind=item(:,2)==-1;
        bundle_trial_ind=item(:,2)~=-1;


        %Value of item/bundle in each trial
        trial_value=ones(length(trial_items),1)*-1;
        for t=1:length(trial_items)
            if trial_items(t,2)==-1
                trial_value(t)=item_value(trial_items(t,1)==item_value(:,1),2);
            else
                bundle_value_ind=(trial_items(t,1)==bundle_items(:,1) & trial_items(t,2)==bundle_items(:,2)) | (trial_items(t,1)==bundle_items(:,2) & trial_items(t,2)==bundle_items(:,1));
                trial_value(t)=bundle_value(bundle_value_ind); 
            end
        end
        trial_value_clean=trial_value(~ErrorTrial_ind);
        %make 0 for items and 1 for bundles to put in struct
        bundle_bool_clean=bundle_trial_ind(~ErrorTrial_ind);

        output_text={'LeftButton','RightButton','Value'};

        %put in struct and save
        subj_struct.left_button{fMRIrun} = left_buttonpress_times(:,2);
        subj_struct.right_button{fMRIrun} = right_buttonpress_times(:,2);
        subj_struct.value_onset{fMRIrun} = condensed_time_clean(:,1);
        subj_struct.value_dur{fMRIrun} = condensed_time_clean(:,2)-condensed_time_clean(:,1);
        subj_struct.value_param{fMRIrun} = trial_value_clean;
        subj_struct.value_categ{fMRIrun} = bundle_bool_clean;

    end

    %save as a .mat file
    save([output_dir_mat,'/sub',subID,'_timing'],'subj_struct')
end