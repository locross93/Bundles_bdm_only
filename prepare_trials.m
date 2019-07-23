function prepare_trials(subID)

saveflag = true;
%% prepare_trials('014-1')

close all;

%Had to add this because we use seeded random number generator below and 
%that was causing unexpected behavior. On each run of this code, it will
%now generate different random object/bundle. This can be standardized for
%each subject though.
rng('shuffle'); 

%Choose bundle or item for prize
%Parse Google spreadsheet into inventory list
inventory_spreadsheet=GetGoogleSpreadsheet('1q84oEM5O0mo-3749vGH7BrKuf5mzXFiddFsR_pe3rvQ');
emptycells=find(cellfun('isempty',inventory_spreadsheet));
for entry=emptycells'
    inventory_spreadsheet{entry}='-1'; %Replaces all empty cells in inventory with -1
end
ItemName=inventory_spreadsheet(2:112,1);
ItemNumber=cellfun(@str2num,inventory_spreadsheet(2:112,2));
ItemInventory=cellfun(@str2num,inventory_spreadsheet(2:112,3));

%What items are currently available
AvailableItems=ItemNumber(ItemInventory>=1);

%Choose random number to choose between bundle or item
BundleOrItem=rand;

if BundleOrItem<0.5 %If random number less than 0.5, choose single item
    disp('Use single item');
    ItemsToUse=datasample(AvailableItems,1);

    fprintf('Item number %d: %s \n', ItemsToUse,inventory_spreadsheet{find(ItemNumber==ItemsToUse)+1,1});
    inc_bundle_ids=[];
else %If random number greater than 0.5, choose bundle
    disp('Use bundle');
    ItemsToUse=sort(datasample(AvailableItems,2,'Replace',false));
    ItemsToUse=ItemsToUse';
    fprintf('Item number %d: %s \n', ItemsToUse(1),inventory_spreadsheet{find(ItemNumber==ItemsToUse(1))+1,1});
    fprintf('Item number %d: %s \n', ItemsToUse(2),inventory_spreadsheet{find(ItemNumber==ItemsToUse(2))+1,1});
    inc_bundle_ids=ItemsToUse;
end

%inc_bundle_ids = [3 8];

%get item name
ItemsToUseNames = {};
for i=1:length(ItemsToUse)
    item_ind = find(ItemNumber == ItemsToUse(i));
    tempName = ItemName(item_ind);
    ItemsToUseNames(end + 1) = tempName;
end

if saveflag
    save(['logs/payment/selected_items_sub_',subID],'ItemsToUse', 'ItemsToUseNames')
end

inc_food_ids = [];
inc_trinket_ids = [];
exc_food_ids = [];
exc_trinket_ids = [];

num_food = 70;
num_trinket = 40;
%how many trials, cant do every combo of bundles
num_trials = 220;

subj = str2num(subID(1:3));
subj_seed = 121 + subj;

%randomly permute food and trinket trials
rng(subj_seed)
food_ids = randperm(num_food);
rng(subj_seed)
trinket_ids = randperm(num_trinket);

%Prepare BDM ITEM

%randomize the ordering of all the items for BDM Item
%add 100 to the trinket IDs to distinguish them

bdm_item_seq = [food_ids, (trinket_ids + 100)];
idx_rnd = randperm(length(bdm_item_seq));
bdm_item_seq = bdm_item_seq(idx_rnd);

%get combinations of all items
%create a N x 2 array of item pairs, starting with each item paired
%with itself
day_food_list = food_ids;
day_trinket_list = (trinket_ids + 100);
combo_list = [[day_food_list';day_trinket_list'],[day_food_list';day_trinket_list']];
all_items = [day_food_list, day_trinket_list];
temp_combos = nchoosek(all_items, 2);
combo_list = [combo_list; temp_combos];

%randomly select NUM_TRIALS trials for this participant
idx_rnd = randperm(length(combo_list));
combo_list_subset = combo_list(idx_rnd(1:num_trials),:);

%include handpicked items if necessary
if length(inc_bundle_ids > 0)
    temp = intersect(find(combo_list(:,1) == inc_bundle_ids(1)), find(combo_list(:,2) == inc_bundle_ids(2)));
    if isempty(temp)
        %if no match, higher number item is in first column
        temp = intersect(find(combo_list(:,1) == inc_bundle_ids(2)), find(combo_list(:,2) == inc_bundle_ids(1)));
    end
    if temp > num_trials
        combo_list_subset(1,:) = combo_list(temp,:);
    end
end

%make half of the trials have food on left half with food on right
half_num = length(combo_list_subset)/2;
lr_conds = [ones(1,half_num)*1, ones(1,half_num)*2];
idx_rnd = randperm(half_num*2);
lr_conds = lr_conds(idx_rnd);

%randomize the ordering
num_trials = length(combo_list_subset);
idx_rnd = randperm(num_trials);
bundle_item_seq = combo_list_subset(idx_rnd,:);
lr_conds = lr_conds(idx_rnd);
num_trials = length(bundle_item_seq);

%flip the left right order of bundles with condition 2 
for i=1:num_trials
    if lr_conds(i) == 2
        bundle_item_seq(i,:) = fliplr(bundle_item_seq(i,:));
    end
end

f_name = ['data/item_list_sub_',subID];
if isequal(exist([f_name,'.mat'],'file'),0)
    save(f_name,'bdm_item_seq','bundle_item_seq');
    disp('Done!')
else
    disp('WARNING: The file already exists!')
end

end

function result = GetGoogleSpreadsheet(DOCID)
% result = GetGoogleSpreadsheet(DOCID)
% Download a google spreadsheet as csv and import into a Matlab cell array.
%
% [DOCID] see the value after 'key=' in your spreadsheet's url
%           e.g. '0AmQ013fj5234gSXFAWLK1REgwRW02hsd3c'
%
% [result] cell array of the the values in the spreadsheet
%
% IMPORTANT: The spreadsheet must be shared with the "anyone with the link" option
%
% This has no error handling and has not been extensively tested.
% Please report issues on Matlab FX.
%
% DM, Jan 2013
%
%DOCID='1q84oEM5O0mo-3749vGH7BrKuf5mzXFiddFsR_pe3rvQ'

loginURL = 'https://www.google.com'; 
csvURL = ['https://docs.google.com/spreadsheet/ccc?key=' DOCID '&output=csv&pref=2'];

%Step 1: go to google.com to collect some cookies
cookieManager = java.net.CookieManager([], java.net.CookiePolicy.ACCEPT_ALL);
java.net.CookieHandler.setDefault(cookieManager);
handler = sun.net.www.protocol.https.Handler;
connection = java.net.URL([],loginURL,handler).openConnection();
connection.getInputStream();

%Step 2: go to the spreadsheet export url and download the csv
connection2 = java.net.URL([],csvURL,handler).openConnection();
result = connection2.getInputStream();
result = char(readstream(result));

%Step 3: convert the csv to a cell array
result = parseCsv(result);

end

function data = parseCsv(data)
% splits data into individual lines
data = textscan(data,'%s','whitespace','\n');
data = data{1};
for ii=1:length(data)
   %for each line, split the string into its comma-delimited units
   %the '%q' format deals with the "quoting" convention appropriately.
   tmp = textscan(data{ii},'%q','delimiter',',');
   data(ii,1:length(tmp{1})) = tmp{1};
end

end

function out = readstream(inStream)
%READSTREAM Read all bytes from stream to uint8
%From: http://stackoverflow.com/a/1323535

import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;
byteStream = java.io.ByteArrayOutputStream();
isc = InterruptibleStreamCopier.getInterruptibleStreamCopier();
isc.copyStream(inStream, byteStream);
inStream.close();
byteStream.close();
out = typecast(byteStream.toByteArray', 'uint8'); 

end
