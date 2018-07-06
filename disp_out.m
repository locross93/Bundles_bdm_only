function disp_out(wpt, w, h, valueBDM, dur)
%%

    if isequal(valueBDM,100)
        str_val = DispString('init', wpt, ['NO RESPONSE'], [0, 0], floor(w/12), [255,255,255], []);
    else
        str_val = DispString('init', wpt, ['$',num2str(valueBDM)], [0, 0], floor(w/10), [255,255,255], []);
    end
    DispString('draw', wpt, str_val)
    
    Screen(wpt,'Flip');
    t_strt = GetSecs;
    while GetSecs < t_strt + dur
    end

    DispString('clear', str_val);

end