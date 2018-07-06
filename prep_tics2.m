function out = prep_tics2(wpt, w, h)
%%

d0 = DispString('init', wpt, 'Not at all', [-0.325*w, 0.315*h], floor(h/17), [255, 255, 255], []);
d4 = DispString('init', wpt, 'Very much', [0.325*w, 0.315*h], floor(h/17), [255, 255, 255], []);

out = [d0,d4];

end