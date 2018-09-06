function disp_out(wpt, w, h, value, dur)
%%

    if isequal(value,100)
        str_val = DispString('init', wpt, ['NO RESPONSE'], [0, 0], floor(w/12), [255,255,255], []);
    elseif isfloat(value) | isinteger(value)
        str_val = DispString('init', wpt, ['$',num2str(value)], [0, 0], floor(w/10), [255,255,255], []);
    elseif ischar(value) | isstring(value)
        str_val = DispString('init', wpt, [value], [0, 0], floor(w/10), [255,255,255], []);
    end
    DispString('draw', wpt, str_val)
    
    Screen(wpt,'Flip');
    t_strt = GetSecs;
    while GetSecs < t_strt + dur
    end

    DispString('clear', str_val);

end