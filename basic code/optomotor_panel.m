
Panel_com('set_mode', [0 0]); % ol, x dimension
Panel_com('set_pattern_id', 2); % stripe at back left corner
GAIN = 8;

for t = 1:5 
    Panel_com('set_ao', [3 0]);        
    pause(1)
    Panel_com('send_gain_bias', [-GAIN, 0, 0, 0]);
    Panel_com('set_ao', [3 1000]);
    Panel_com('start')
    pause(5);
    Panel_com('stop')
    Panel_com('set_ao', [3 0]);    
    pause(1)
    Panel_com('send_gain_bias', [+GAIN, 0, 0, 0]);
    Panel_com('start')
    Panel_com('set_ao', [3 2000]);    
    pause(5);
    Panel_com('stop')
end