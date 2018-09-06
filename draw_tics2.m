function draw_tics2(wpt, w, h, d)
%%
    w_dev = 0.005 * w;
    
    h_pntT = 0.74*h;
    h_pntB = 0.75*h;
    h_dev = 0.02 * h;
    
    Screen('FillRect', wpt, [255,255,255], [0.2*w,h_pntT,0.8*w,h_pntB]);
    Screen('FillRect', wpt, [255,255,255], [0.2*w - w_dev, h_pntT - h_dev, 0.2*w + w_dev, h_pntB + h_dev]);
    Screen('FillRect', wpt, [255,255,255], [0.32*w - w_dev, h_pntT - h_dev, 0.32*w + w_dev, h_pntB + h_dev]);
    Screen('FillRect', wpt, [255,255,255], [0.44*w - w_dev, h_pntT - h_dev, 0.44*w + w_dev, h_pntB + h_dev]);
    Screen('FillRect', wpt, [255,255,255], [0.56*w - w_dev, h_pntT - h_dev, 0.56*w + w_dev, h_pntB + h_dev]);
    Screen('FillRect', wpt, [255,255,255], [0.68*w - w_dev, h_pntT - h_dev, 0.68*w + w_dev, h_pntB + h_dev]);
    Screen('FillRect', wpt, [255,255,255], [0.8*w - w_dev, h_pntT - h_dev, 0.8*w + w_dev, h_pntB + h_dev]);
    DispString('draw', wpt, d(1));
    DispString('draw', wpt, d(2));
    DispString('draw', wpt, d(3));
    DispString('draw', wpt, d(4));
    DispString('draw', wpt, d(5));
    DispString('draw', wpt, d(6));

end