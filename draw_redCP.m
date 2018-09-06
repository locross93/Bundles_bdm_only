function draw_redCP(wpt,cp_L,cp_R,num_L,num_R)
%%

for i = 1:num_L
    DrawCircle('draw',wpt,cp_L{i}); 
end

for i = 1:num_R
    DrawCircle('draw',wpt,cp_R{i}); 
end

end