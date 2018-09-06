function out = prep_tics3(wpt, w, h)
%%

d0 = DispString('init', wpt, '0', [-0.300*w, 0.315*h], floor(h/17), [255, 255, 255], []);
d1 = DispString('init', wpt, '1', [-0.180*w, 0.315*h], floor(h/17), [255, 255, 255], []);
d2 = DispString('init', wpt, '2', [-0.060*w, 0.315*h], floor(h/17), [255, 255, 255], []);
d3 = DispString('init', wpt, '3', [0.060*w, 0.315*h], floor(h/17), [255, 255, 255], []);
d4 = DispString('init', wpt, '4', [0.180*w, 0.315*h], floor(h/17), [255, 255, 255], []);
d5 = DispString('init', wpt, '5', [0.300*w, 0.315*h], floor(h/17), [255, 255, 255], []);

out = [d0,d1,d2,d3,d4,d5];

end