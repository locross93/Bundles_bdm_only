function disp_break(wpt, w, h)
%%

ready = DispString('init', wpt, 'READY', [0,0], floor(w/10), [255, 255, 255], []);
DispString('draw', wpt, ready);

Screen(wpt,'Flip');
FlushEvents
while 1
    if GetClicks == 1
        break;
    end
end

DispString('clear', ready);
end