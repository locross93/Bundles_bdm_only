function res_nums = draw_res_nums(wpt, w, h, pst_V)
%%
w_bins = [0.23 0.41 0.59 0.77] * w  - 0.5 * w;
h_bins = 0.5 * h - 0.5 * h;

res_nums = zeros(length(pst_V),1);
for i = 1:length(pst_V)

    num_shown = [num2str(pst_V(i))];
    res_nums(i) = DispString('init', wpt, num_shown, [w_bins(i), h_bins], floor(w/10), [0,0,0], []);
    DispString('draw', wpt, res_nums(i))
    
end

end