
function [jump, curr_sp0, curr_std, curr_rot] = jump_or_nojump(x,y,head, prev_jump,time, ballcirc)

curr_std6s = circ_std(head(1:120));
curr_std = circ_std(head);
curr_rot = ((x(1)-x(end))^2+(y(1)-y(end))^2)^.5*ballcirc;

curr_sp0 = 0;
for i = 1:1:60
    curr_sp0 = curr_sp0+((x(i)-x(i+1))^2+(y(i)-y(i+1))^2)^.5*ballcirc;
end

curr_sp1 = 0;
for i = 61:1:120
    curr_sp1 = curr_sp1+((x(i)-x(i+1))^2+(y(i)-y(i+1))^2)^.5*ballcirc;
end

curr_sp2 = 0;
for i = 121:1:180
    curr_sp2 = curr_sp2+((x(i)-x(i+1))^2+(y(i)-y(i+1))^2)^.5*ballcirc;
end

curr_sp3 = 0;
for i = 181:1:240
    curr_sp3 = curr_sp3+((x(i)-x(i+1))^2+(y(i)-y(i+1))^2)^.5*ballcirc;
end


curr_sp0 = curr_sp0/3;
curr_sp1 = curr_sp1/3;
curr_sp2 = curr_sp2/3;
curr_sp3 = curr_sp3/3;

if( (curr_sp0 > .5) && (curr_sp1 > .3) && (curr_sp2 > .3) && (curr_sp3 > .3) && (curr_std < .5) && (curr_std6s < .3) && (curr_rot > 5*ballcirc) && ((time-prev_jump) > 4*20*60))
    jump = 1;
else
    jump = 0;
end

end

