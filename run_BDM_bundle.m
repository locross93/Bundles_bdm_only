function run_BDM_bundle(subID)
%% run_BDM_bundle('888-1')
%% run_BDM_bundle('020-1')

try

    debug = 0;
    
    KbName('UnifyKeyNames');
    
    Screen('Preference','SkipSyncTests', 1);
    
    % Load image files for the subject
    file_items = ['data/item_list_sub_',subID];
    load(file_items) % item_ids is loaded
    bundle_list = bundle_item_seq;
    num_trials = length(bundle_list);
    
    % Set window pointer
    if debug
        %[wpt, rect] = Screen('OpenWindow', 0, [0, 0, 0], [0 0 800 600] * 1.5); w = rect(3); h = rect(4);
        [wpt, rect] = Screen('OpenWindow', 0, [0, 0, 0], [0 0 1800 900]); w = rect(3); h = rect(4);
    else
        [wpt, rect] = Screen('OpenWindow', 0, [0, 0, 0]); w = rect(3); h = rect(4);
    end
    
    Screen('BlendFunction', wpt, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('Preference','TextRenderer', 1)
    
    % Preparation
    durITI = 0.5;
    durOUT = 0.5;
    %d_tics = prep_tics_bundle(wpt, w, h);
    w_bin = linspace(w * 0.2, w * 0.8, 6);
    str_question = DispString('init', wpt, 'How much are you willing to pay for this bundle?', [0,-h/2.75], floor(h/17), [255, 255, 255], []);
    
    % Prepare data
    time_ITI = []; time_DEC = []; time_OUT = [];
    value = []; item = []; init_V = []; num_L = []; num_R = [];
    
    % Ready
    disp_ready(wpt, w, h);
    
    % Start BDM
    time_zero = GetSecs;
    for i = 1:num_trials
        
        % ITI
        disp(['trial #',num2str(i),': ',num2str(bundle_list(i,:))])
        time_ITIstrt = GetSecs - time_zero;
        disp_fix(wpt, w, h, durITI)
        time_ITIend = GetSecs - time_zero;
        time_ITI = [time_ITI; [time_ITIstrt, time_ITIend]];
        
        % BDM
        if bundle_list(i,1) < 100
            shown_item1 = ['images/WithoutText/imgs_food/item_',num2str(bundle_list(i,1)),'.jpg'];
            itm_img1 = DispImage('init', wpt, shown_item1, [-w/8.0,-h/15], w/100, [100,100]);
        else
            shown_item1 = ['images/WithoutText/imgs_trinkets/item_',num2str(bundle_list(i,1)-100),'.jpg'];
            itm_img1 = DispImage('init', wpt, shown_item1, [-w/8.0,-h/15], w/100, [100,100]);
        end
        if bundle_list(i,2) < 100
            shown_item2 = ['images/WithoutText/imgs_food/item_',num2str(bundle_list(i,2)),'.jpg'];
            itm_img2 = DispImage('init', wpt, shown_item2, [w/8.0,-h/15], w/100, [100,100]);
        else
            shown_item2 = ['images/WithoutText/imgs_trinkets/item_',num2str(bundle_list(i,2)-100),'.jpg'];
            itm_img2 = DispImage('init', wpt, shown_item2, [w/8.0,-h/15], w/100, [100,100]);
        end
        
        %target = ceil(rand() * length(w_bin));
        %init_valueBDM = 4 * (target - 1) / (length(w_bin) - 1);numL_tmp = 0; numR_tmp = 0;
        
        FlushEvents
        time_DECstrt = GetSecs - time_zero;
        bid=100;
        while 1
            DispImage('draw', wpt, itm_img1);
            DispImage('draw', wpt, itm_img2);
            DispString('draw', wpt, str_question);
            bid_display(wpt, w, h, bid)
            Screen(wpt,'Flip');
            
            keyRes = GetChar;
            [keyIsDown,secs,keyCode] = KbCheck;
            keyName = KbName(find(keyCode));
            %disp('Pressed')
            %disp(keyName(1))
            %key_num = str2num(keyRes);
            if length(keyName) > 0 && ischar(keyName)
                key_num = str2num(keyName(1));
            else
                key_num = [];
            end
            if ~isempty(key_num)
                if bid == 100
                %first starting trial, go from blank to first number press
                    bid = key_num;
                elseif bid == 1 && isempty(key_num) == 0
                %if a 1 is typed first a number can be entered after it
                    bid = 10 + key_num;
                elseif bid == 2 && isempty(key_num) == 0
                %if a 2 is typed first only 0 entered after it
                    bid = 20;
                end
            end
            
            %input your bid directly
            if isequal(keyName,'Return')
                if bid~=100
                    break
                end
            elseif isequal(keyName,'BackSpace')
                bid = 100;
            elseif isequal(keyName,'DELETE')
                bid = 100;
            elseif isequal(keyName,'q')
                Screen('CloseAll');
                FlushEvents
                break
            end
            FlushEvents
        end
        time_DECend = GetSecs - time_zero;
        time_DEC = [time_DEC; [time_DECstrt, time_DECend]];
        valueBDM = bid;
        
        % OUTCOME (FEEDBACK)
        time_OUTstrt = GetSecs - time_zero;
        disp_out(wpt, w, h, valueBDM, durOUT)
        time_OUTend = GetSecs - time_zero;
        time_OUT = [time_OUT; [time_OUTstrt, time_OUTend]];
        
        % save data
        value = [value; valueBDM];
        item = [item; bundle_list(i,:)];
       
        DispImage('clear', itm_img1);
        DispImage('clear', itm_img2);
        
    end 
    
    % data save and closing
    fname_log = ['logs/bdm_bundle_sub_',subID];
    save(fname_log,'value','item','init_V','num_L','num_R');
    
    durITI = 4;
    time_ITIstrt = GetSecs - time_zero;
    disp_fix(wpt, w, h, durITI)
    time_ITIend = GetSecs - time_zero;
    time_ITI = [time_ITI; [time_ITIstrt, time_ITIend]];
    
    fname_log_time = ['logs/bdm_bundle_sub_',subID,'_time'];
    save(fname_log_time, 'time_ITI', 'time_DEC', 'time_OUT');
    
    %save in fmri folder too
    fmri_folder = '/Users/locro/Documents/Bundle_Value/stim_presentation/Bundles_fmri/';
    fmri_fname_log = [fmri_folder,'logs/bdm_bundle_sub_',subID];
    save(fmri_fname_log,'value','item','init_V','num_L','num_R');
    
    fmri_fname_log_time = [fmri_folder,'logs/bdm_bundle_sub_',subID,'_time'];
    save(fmri_fname_log_time, 'time_ITI', 'time_DEC', 'time_OUT');
    
    
    Screen('CloseAll');

catch
    
    Screen('CloseAll');
    psychrethrow(psychlasterror);

end

end