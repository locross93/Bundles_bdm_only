function pay_subj_BDM(subID, item_id)
%% pay_subj_BDM('999-1', [8, 102])

max_price = 20;

debug = 0;

% Load log files
item_list = [];
value_list = [];

file_name = ['bdm_items_sub_',subID];
load(['logs/',file_name]);
item_list = item;
value_list = value;

% Load log files
bundle_list = [];
bundle_value_list = [];

%need to change this when you get real data
%file_name = ['dummy_bdm_bundle_sub_',subID];
file_name = ['bdm_bundle_sub_',subID];
load(['logs/',file_name]);
bundle_list = item;
bundle_value_list = value;

sub_bid = [];

if length(item_id) < 2
    idx = (item_list == item_id);
    sub_bid = value_list(idx);
    if isempty(sub_bid)
        disp('ERROR ITEM NOT FOUND')
    end
else
    for i=1:length(bundle_list)
        if bundle_list(i,:) == item_id
            sub_bid = bundle_value_list(i);
            break
        %item ids could be flipped
        elseif bundle_list(i,:) == fliplr(item_id)
            sub_bid = bundle_value_list(i);
            break
        end
    end
    if isempty(sub_bid)
        disp('ERROR ITEM NOT FOUND')
    end
end
com_bid = floor(rand() * max_price);

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
wait_img = DispString('init', wpt, 'Choosing trial from Task 1...', [0,0], floor(h/15), [255, 255, 255], []);
DispString('draw', wpt, wait_img); Screen(wpt,'Flip'); pause(3);

% 2nd display: "info for reward"
if length(item_id) < 2
    if item_id < 100
        shown_item = ['data/imgs_food/item_',num2str(item_id),'.jpg'];
        itm_img = DispImage('init', wpt, shown_item, [0,-h/6], w/50, [140000/w,140000/w]);
    elseif item_id > 100
        shown_item = ['data/imgs_trinkets/item_',num2str(item_id-100),'.jpg'];
        itm_img = DispImage('init', wpt, shown_item, [0,-h/6], w/50, [140000/w,140000/w]);
    end
else 
    %else its a bundle
    if item_id(1) < 100
        shown_item1 = ['data/imgs_food/item_',num2str(item_id(1)),'.jpg'];
        itm_img1 = DispImage('init', wpt, shown_item1, [-w/7.0,-h/15], w/100, [100,100]);
    else
        shown_item1 = ['data/imgs_trinkets/item_',num2str(item_id(1)-100),'.jpg'];
        itm_img1 = DispImage('init', wpt, shown_item1, [-w/7.0,-h/15], w/100, [100,100]);
    end
    if item_id(2) < 100
        shown_item2 = ['data/imgs_food/item_',num2str(item_id(2)),'.jpg'];
        itm_img2 = DispImage('init', wpt, shown_item2, [w/7.0,-h/15], w/100, [100,100]);
    else
        shown_item2 = ['data/imgs_trinkets/item_',num2str(item_id(2)-100),'.jpg'];
        itm_img2 = DispImage('init', wpt, shown_item2, [w/7.0,-h/15], w/100, [100,100]);
    end
end

sub_bid_img = DispString('init', wpt, ['Your bid: ',num2str(sub_bid)], [0,h*1.5/8], floor(h/20), [255, 255, 255], []);
com_bid_img = DispString('init', wpt, ['Price: ',num2str(com_bid)], [0,h*2/8], floor(h/20), [255, 255, 255], []);

if sub_bid < com_bid
    rwd_img = DispString('init', wpt, 'You do NOT get the item', [0,h*3/8], floor(h/20), [255, 255, 255], []);
else
    rwd_img = DispString('init', wpt, ['You get the item and pay $',num2str(com_bid)], [0,h*3/8], floor(h/20), [255, 255, 255], []);
end

condition = 'BDM';
save(['logs/payment/payment_sub_',subID],'item_id','sub_bid','com_bid', 'condition')

if length(item_id) < 2
    DispImage('draw', wpt, itm_img); 
else
    DispImage('draw', wpt, itm_img1);
    DispImage('draw', wpt, itm_img2);
end

DispString('draw', wpt, sub_bid_img); DispString('draw', wpt, com_bid_img); DispString('draw', wpt, rwd_img);
Screen(wpt,'Flip');
FlushEvents
while 1
    if GetClicks == 1
        break;
    end
end

Screen('CloseAll');

if sub_bid < com_bid
    disp('You do NOT get the item')
else
    disp(['You get the item and pay $',num2str(com_bid)])
end
end