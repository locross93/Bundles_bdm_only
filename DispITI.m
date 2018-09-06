function DispITI(wpt,fix,durITI)
%%    

DispString('draw', wpt, fix);
Screen(wpt,'Flip');
t_strt = GetSecs;
while GetSecs < t_strt + durITI
end
    
end