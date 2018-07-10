function pay_subj_choice(subID, item_id)
%% pay_subj_choice('999-1', [8, 102])

max_price = 10;

debug = 0;

run_num = 1;
file_name= ['choice_run',num2str(run_num),'_sub_',subID];

load(['logs/',file_name]);
item_list = item;
choice_list = choice;

for run=2:5
    file_name= ['choice_run',num2str(run),'_sub_',subID];
    load(['logs/',file_name]);
    item_list = [item_list; item];
    choice_list = [choice_list; choice];
end

sub_choice = [];

if length(item_id) < 2
    for i=1:length(item_list)
        if item_list(i,:) == [item_id, -1]
            sub_choice = choice_list(i);
            med_bid = median_bid_item;
            break
        end
    end
    if isempty(sub_choice)
        disp('ERROR ITEM NOT FOUND')
    end
else
    for i=1:length(item_list)
        if item_list(i,:) == item_id
            sub_choice = choice_list(i);
            med_bid = median_bid_bundle;
            break
        %item ids could be flipped
        elseif item_list(i,:) == fliplr(item_id)
            sub_choice = choice_list(i);
            med_bid = median_bid_bundle;
            break
        end
    end
    if isempty(sub_choice)
        disp('ERROR ITEM NOT FOUND')
    end
end

%%%%% Display for the subject %%%%%

% Set window pointer
if debug
    [wpt, rect] = Screen('OpenWindow', 0, [0, 0, 0], [0 0 800 600]); w = rect(3); h = rect(4);
else
    [wpt, rect] = Screen('OpenWindow', 0, [0, 0, 0]); w = rect(3); h = rect(4);
end
Screen('BlendFunction', wpt, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Waiting
wait_img = DispString('init', wpt, 'Wait...', [0,0], floor(h/10), [255, 255, 255], []);
DispString('draw', wpt, wait_img); Screen(wpt,'Flip'); pause(2);
wait_img = DispString('init', wpt, 'Choosing trial from Task 2...', [0,0], floor(h/15), [255, 255, 255], []);
DispString('draw', wpt, wait_img); Screen(wpt,'Flip'); pause(3);


% 2nd display: "info for reward"
if length(item_id) < 2
    if item_id < 100
        shown_item = ['data/imgs_food/item_',num2str(item_id),'.jpg'];
        itm_img = DispImage('init', wpt, shown_item, [0,-h/6], w/50, [140000/w,140000/w]);
    elseif item_id > 100
        shown_item = ['data/imgs_trinkets/item_',num2str(item_id-100),'.jpg'];
        itm_img = DispImage('init', wpt, shown_item, [0,-h/6], w/10, [140000/w,140000/w]);
    end
else 
    %else its a bundle
    if item_id(1) < 100
        shown_item1 = ['data/imgs_food/item_',num2str(item_id(1)),'.jpg'];
        itm_img1 = DispImage('init', wpt, shown_item1, [-w/7.0,-h/15], w/100, [100,100]);
    else
        shown_item1 = ['data/imgs_trinkets/item_',num2str(item_id(1)-100),'.jpg'];
        itm_img1 = DispImage('init', wpt, shown_item1, [-w/7.0,-h/15], w/20, [100,100]);
    end
    if item_id(2) < 100
        shown_item2 = ['data/imgs_food/item_',num2str(item_id(2)),'.jpg'];
        itm_img2 = DispImage('init', wpt, shown_item2, [w/7.0,-h/15], w/100, [100,100]);
    else
        shown_item2 = ['data/imgs_trinkets/item_',num2str(item_id(2)-100),'.jpg'];
        itm_img2 = DispImage('init', wpt, shown_item2, [w/7.0,-h/15], w/20, [100,100]);
    end
end

%display subject's choice
if sub_choice == 1
    pay_string = ['You chose this item over $', num2str(med_bid)];
    rwd_img = DispString('init', wpt, pay_string, [0,h*3/8], floor(h/20), [255, 255, 255], []);
else
    pay_string = ['You chose $', num2str(med_bid),' over this item'];
    rwd_img = DispString('init', wpt, pay_string, [0,h*3/8], floor(h/20), [255, 255, 255], []);
end

condition = 'choice';
save(['logs/payment/payment_sub_',subID],'item_id','sub_choice','med_bid', 'condition')

if length(item_id) < 2
    DispImage('draw', wpt, itm_img); 
else
    DispImage('draw', wpt, itm_img1);
    DispImage('draw', wpt, itm_img2);
end

DispString('draw', wpt, rwd_img);
Screen(wpt,'Flip');
FlushEvents
while 1
    if GetClicks == 1
        break;
    end
end

Screen('CloseAll');

disp(pay_string)

end



