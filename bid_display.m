function bid_display(wpt, w, h, bid)

    Screen('FillRect', wpt, [255,255,255], [(2.5/6)*w,(7/10)*h,(3.5/6)*w,(9.5/10)*h]);
    if bid < 10
        bid_string = num2str(bid);
        bid_input = DispString('init', wpt, bid_string, [0,0.325*h], floor(h/6), [255, 0, 0], []);
        DispString('draw', wpt, bid_input);
    elseif bid >= 10 && bid < 21
        bid_string = num2str(bid);
        bid_input = DispString('init', wpt, bid_string, [-0.005*w,0.325*h], floor(h/6), [255, 0, 0], []);
        DispString('draw', wpt, bid_input);
    end


end