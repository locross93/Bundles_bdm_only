function pay_run1(subID)
%%

% Load log files
item_list = [];
value_list = [];
for i = 1:4
    file_name = ['bdm_',num2str(i),'_sub_',subID];
    load(['logs/',file_name]);
    item_list = [item_list; item];
    value_list = [value_list; value];
end

% item id
item_id = 28;
idx = (item_list == item_id);
val_tmp = value_list(idx);
idx_tmp = randperm(length(find(idx)));
sub_bid = val_tmp(idx_tmp(1));
com_bid = floor(rand() * 4);

%%%%% Display for the subject %%%%%

% Set window pointer
[wpt, rect] = Screen('OpenWindow', 0, [0, 0, 0], [0 0 800 600]); w = rect(3); h = rect(4);
%[wpt, rect] = Screen('OpenWindow', 1, [0, 0, 0]); w = rect(3); h = rect(4);
Screen('BlendFunction', wpt, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Waiting
wait_img = DispString('init', wpt, 'Wait...', [0,0], floor(h/10), [255, 255, 255], []);
DispString('draw', wpt, wait_img); Screen(wpt,'Flip'); pause(3);

% 2nd display: "info for reward"
shown_item = ['data/imgs/item_',num2str(item_id),'.jpg'];
itm_img = DispImage('init', wpt, shown_item, [0,-h/6], w/50, [100,100]);
sub_bid_img = DispString('init', wpt, ['Your bid: ',num2str(sub_bid)], [0,h/8], floor(h/20), [255, 255, 255], []);
com_bid_img = DispString('init', wpt, ['Price: ',num2str(com_bid)], [0,h*2/8], floor(h/20), [255, 255, 255], []);

if sub_bid < com_bid
    rwd_img = DispString('init', wpt, 'You do NOT get the item', [0,h*3/8], floor(h/20), [255, 255, 255], []);
else
    rwd_img = DispString('init', wpt, ['You get the item and pay $',num2str(com_bid)], [0,h*3/8], floor(h/20), [255, 255, 255], []);
end

save(['logs/payment/payment_sub_',subID],'item_id','sub_bid','com_bid')

DispImage('draw', wpt, itm_img); DispString('draw', wpt, sub_bid_img); DispString('draw', wpt, com_bid_img); DispString('draw', wpt, rwd_img);
Screen(wpt,'Flip');
FlushEvents
while 1
    if GetClicks == 1
        break;
    end
end

Screen('CloseAll');

end