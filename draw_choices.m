function res_nums = draw_choices(wpt, w, h, ref_pos, med_bid_string)
%%

w_bins = [0.23 0.77] * w;
h_bins = 0.75 * h;

w_dev = 0.075 * w;
h_dev = 0.075 * w;

w2_bins = [0.23 0.77] * w  - 0.5 * w;
h2_bins = 0.25 * h;

if ref_pos == 1
    choice_string = {'ITEM', med_bid_string};
elseif ref_pos == 2
    choice_string = {med_bid_string, 'ITEM'};
end    
    
for i = 1:length(w_bins)
    
    Screen('FillRect', wpt, [255,255,0], [w_bins(i) - w_dev, h_bins - h_dev, w_bins(i) + w_dev, h_bins + h_dev]);
    
end 

res_nums = zeros(2,1);
for i = 1:length(w_bins)
    res_nums(i) = DispString('init', wpt, choice_string{i}, [w2_bins(i), h2_bins], floor(w/18), [0,0,0], []);
    DispString('draw', wpt, res_nums(i))
end

end