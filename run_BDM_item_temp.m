function run_BDM_item_temp(subID)
%% temporary script for 106
%% run_BDM_item_temp('106-99')

try
    
    debug = 0;
    
    KbName('UnifyKeyNames');
    
    Screen('Preference','SkipSyncTests', 1);
    
    
    % Load image files for the subject day 1
    file_items1 = ['data/item_list_sub_106-1'];
    load(file_items1) % item_ids is loaded
    item_list1 = bdm_item_seq;
    
    % Load image files for the subject day 2
    file_items2 = ['data/item_list_sub_106-2'];
    load(file_items2) % item_ids is loaded
    item_list2 = bdm_item_seq;
    
    item_list_all = [item_list1; item_list2];
    item_list_unique = unique(item_list_all);
    idx_rnd = randperm(length(item_list_unique));
    item_list = item_list_unique(idx_rnd);
    
    % Set window pointer
    if debug
        %[wpt, rect] = Screen('OpenWindow', 0, [0, 0, 0], [0 0 960 540] * 1.5); w = rect(3); h = rect(4);
        [wpt, rect] = Screen('OpenWindow', 0, [0, 0, 0], [0 0 1800 900]); w = rect(3); h = rect(4);
    else
        [wpt, rect] = Screen('OpenWindow', 0, [0, 0, 0]); w = rect(3); h = rect(4);
    end
    
    Screen('BlendFunction', wpt, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('Preference','TextRenderer', 1)
    
    % Preparation
    durITI = 0.5;
    durOUT = 0.5;
    num_trials = length(item_list);
    %d_tics = prep_tics_item(wpt, w, h);
    w_bin = linspace(w * 0.2, w * 0.8, 6);
    str_question = DispString('init', wpt, 'How much are you willing to pay for this item?', [0,-h/2.75], floor(h/17), [255, 255, 255], []);
    
    % Prepare data
    time_ITI = []; time_DEC = []; time_OUT = [];
    value = []; item = []; init_V = []; num_L = []; num_R = [];
    
    % Ready
    disp_ready(wpt, w, h);
    
    % Start BDM
    time_zero = GetSecs;
    for i = 1:num_trials
        
        % ITI
        disp(['trial #',num2str(i),': ',num2str(item_list(i))])
        time_ITIstrt = GetSecs - time_zero;
        disp_fix(wpt, w, h, durITI)
        time_ITIend = GetSecs - time_zero;
        time_ITI = [time_ITI; [time_ITIstrt, time_ITIend]];
        
        % BDM
        if item_list(i) < 100
            shown_item = ['images/WithText/imgs_food/item_',num2str(item_list(i)),'.jpg'];
            itm_img = DispImage('init', wpt, shown_item, [0,-h/15], w/50, [140000/w,140000/w]);
        elseif item_list(i) > 100
            shown_item = ['images/WithText/imgs_trinkets/item_',num2str(item_list(i)-100),'.jpg'];
            itm_img = DispImage('init', wpt, shown_item, [0,-h/15], w/50, [140000/w,140000/w]);
        end
        
        FlushEvents
        time_DECstrt = GetSecs - time_zero;
        bid=100;
        while 1
            DispImage('draw', wpt, itm_img);
            DispString('draw', wpt, str_question);
            bid_display(wpt, w, h, bid)
            Screen(wpt,'Flip');
            
            keyRes = GetChar;
            [keyIsDown,secs,keyCode] = KbCheck;
            keyName = KbName(find(keyCode));
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
        item = [item; item_list(i)];
       
        DispImage('clear', itm_img);
        
    end 
    
    % data save and closing
    fname_log = ['logs/bdm_items_sub_',subID];
    save(fname_log,'value','item','init_V','num_L','num_R');
    
    value_day1 = -1*ones(20,1);
    value_day2 = -1*ones(20,1);
    for i=1:20
        temp_ind1 = find(item == item_list1(i));
        value_day1(i) = value(temp_ind1);
        temp_ind2 = find(item == item_list2(i));
        value_day2(i) = value(temp_ind2);
    end
    
    fname_log1 = ['logs/bdm_items_sub_106-1_corrected'];
    value = value_day1;
    item = item_list1;
    save(fname_log1,'value','item');
    
    fname_log2 = ['logs/bdm_items_sub_106-2'];
    value = value_day2;
    item = item_list2;
    save(fname_log2,'value','item');
    
    durITI = 2;
    time_ITIstrt = GetSecs - time_zero;
    disp_fix(wpt, w, h, durITI)
    time_ITIend = GetSecs - time_zero;
    time_ITI = [time_ITI; [time_ITIstrt, time_ITIend]];
    
    fname_log_time = ['logs/bdm_items_sub_',subID,'_time'];
    save(fname_log_time, 'time_ITI', 'time_DEC', 'time_OUT');
    
    Screen('CloseAll');

catch
    
    Screen('CloseAll');
    psychrethrow(psychlasterror);

end

end