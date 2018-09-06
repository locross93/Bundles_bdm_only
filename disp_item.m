function disp_item(wpt, w, h, shown_item, dur)
%%

itm_img = DispImage('init', wpt, shown_item, [0,0], w/40, [100,100]);
DispImage('draw', wpt, itm_img);
Screen(wpt,'Flip');
t_strt = GetSecs;
while GetSecs < t_strt + dur
end

DispImage('clear', itm_img);

end