function draw_response(wpt, w, h)
%%

w_bins = [0.23 0.41 0.59 0.77] * w;
h_bins = 0.5 * h;

w_dev = 0.075 * w;
h_dev = 0.075 * w;
    
for i = 1:length(w_bins)
    
    Screen('FillRect', wpt, [255,255,0], [w_bins(i) - w_dev, h_bins - h_dev, w_bins(i) + w_dev, h_bins + h_dev]);
    
end 

end