Panel_com('pc_dumping_mode');
pause(2);
Panel_com('ctr_reset');
pause(2);
disp 'Connected to Visual Display in Closed Loop Frame Dump'

filep = load(['E:\vikram\beta code for VR2\patterns_24panel\Pattern_011'],'pattern');
[rows, cols, numpats] = size(filep.pattern.Pats);

pause(2);



%% front oscillation that we used

q = -60:1:60;
q2 = 60:-1:-60;

qq = [q,q2];

for i = 1:1:10
    qq = [qq,qq];
end

qq = qq+384;
for i = 1:1:length(qq)
    send_pat = mod(qq(i),384);
    if(send_pat == 0)
        send_pat = 1;
    end
    send_pat
    framedump(filep.pattern.Pats(:,:,send_pat), filep.pattern.Panel_map, 24, 5, round(send_pat/numpats*32767), 0);
    pause(.05);
end


%% around and around

for i = 1:1:384*10
    send_pat = mod(i,384);
    if(send_pat == 0)
        send_pat = 1;
    end
    send_pat
    framedump(filep.pattern.Pats(:,:,send_pat), filep.pattern.Panel_map, 24, 5, round(send_pat/numpats*32767), 0);
    pause(.025);
end




%% 90 oscillation that we used

q = -60:1:60;
q2 = 60:-1:-60;

qq = [q,q2];

for i = 1:1:10
    qq = [qq,qq];
end

qq = qq+384+96;
for i = 1:1:length(qq)
    send_pat = mod(qq(i),384);
    if(send_pat == 0)
        send_pat = 1;
    end
    send_pat
    framedump(filep.pattern.Pats(:,:,send_pat), filep.pattern.Panel_map, 24, 5, round(send_pat/numpats*32767), 0);
    pause(.05);
end


%%%%%
q = -60:1:60;
q2 = 60:-1:-60;

qq = [q,q2];

for i = 1:1:10
    qq = [qq,qq];
end

qq = qq+384+96+96;
for i = 1:1:length(qq)
    send_pat = mod(qq(i),384);
    if(send_pat == 0)
        send_pat = 1;
    end
    send_pat
    framedump(filep.pattern.Pats(:,:,send_pat), filep.pattern.Panel_map, 24, 5, round(send_pat/numpats*32767), 0);
    pause(.05);
end
