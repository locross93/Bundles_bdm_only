function prep_pay_subj_fMRI(subID)

saveflag = true;
%% prep_pay_subj_fMRI('107-2')

file_name = ['data/item_list_sub_',subID];
load(file_name);

ItemsSeen = bdm_item_seq;
FoodItemsAllDays=f_items_all_days;
TrinketItemsAllDays=t_items_all_days;

%pick a trial at random to pay subject

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

%What items are both available and have been seen by subject
PossibleItems=ItemsSeen(ismember(ItemsSeen,AvailableItems));

if nnz(setdiff(PossibleItems,[FoodItemsAllDays; TrinketItemsAllDays]))>1
    PossibleItems=PossibleItems(~ismember(PossibleItems,[FoodItemsAllDays; TrinketItemsAllDays]));
    %Choose random number to choose between bundle or item
    rng('shuffle');
    BundleOrItem=rand;
    
    if BundleOrItem<0.5 %If random number less than 0.5, choose single item
        ItemsToUse=datasample(PossibleItems,1);
        
    else %If random number greater than 0.5, choose bundle
        ItemsToUse=sort(datasample(PossibleItems,2,'Replace',false)); %Could relax in future to allow duplicate item bundles, but currently not allowed.
    end
    
elseif nnz(setdiff(PossibleItems,[FoodItemsAllDays; TrinketItemsAllDays]))==1
    PossibleItems=PossibleItems(~ismember(PossibleItems,[FoodItemsAllDays; TrinketItemsAllDays]));
    ItemsToUse=datasample(PossibleItems,1);
    
else %No other option than to choose from All day Food or Trinket items
    
    %Choose random number to choose between bundle or item
    rng('shuffle');
    BundleOrItem=rand;
    
    if BundleOrItem<0.5 %If random number less than 0.5, choose single item
        ItemsToUse=datasample(PossibleItems,1);
    else %If random number greater than 0.5, choose bundle
        ItemsToUse=sort(datasample(PossibleItems,2,'Replace',false)); %Could relax in future to allow duplicate item bundles, but currently not allowed.
    end
    
    
end

%get item name
ItemsToUseNames = {};
for i=1:length(ItemsToUse)
    item_ind = find(ItemNumber == ItemsToUse(i));
    tempName = ItemName(item_ind);
    ItemsToUseNames(end + 1) = tempName;
end

if length(ItemsToUse)>1
    sprintf('Use items: %d %s\nUse items: %d %s',ItemsToUse(1), ItemsToUseNames{1}, ItemsToUse(2), ItemsToUseNames{2})
else
    sprintf('Use item: %d %s',ItemsToUse(1), ItemsToUseNames{1})
end

if saveflag
    save(['logs/payment/selected_items_sub_',subID],'ItemsToUse', 'ItemsToUseNames')
end
    
end