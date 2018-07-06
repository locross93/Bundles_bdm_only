function out = prep_tics(wpt, w, h)
%%

d0 = DispString('init', wpt, '$0', [-0.3*w, 0.315*h], floor(w/18), [255, 255, 255], []);
d1 = DispString('init', wpt, '$1', [-0.15*w, 0.315*h], floor(w/18), [255, 255, 255], []);
d2 = DispString('init', wpt, '$2', [0.00*w, 0.315*h], floor(w/18), [255, 255, 255], []);
d3 = DispString('init', wpt, '$3', [0.15*w, 0.315*h], floor(w/18), [255, 255, 255], []);
d4 = DispString('init', wpt, '$4', [0.30*w, 0.315*h], floor(w/18), [255, 255, 255], []);

out = [d0,d1,d2,d3,d4];

end