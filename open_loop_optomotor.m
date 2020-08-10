% open_loop_control defines the open loop operations that will be executed
% in temp_reality.

function current_pattern_id = open_loop_optomotor(cnt, plot_speed, gain)

%set number of repetitions and pattern ID number to loop through
%9 is all panels, 10 through 13 go one row at a time, top to bottom
    for patterns 9:1:13
        
        %for panel control open loop
        current_pattern_id = patterns;
        
        if(cnt == 0)
            Panel_com('set_pattern_id', current_pattern_id);
        end
        
        if(mod(cnt,60*plot_speed)==0*plot_speed)
            Panel_com('stop')
            Panel_com('set_ao', [3 0]);
            Panel_com('send_gain_bias', [-1.*gain, 0, 0, 0]);
            Panel_com('start')
        end
        
        if (mod(cnt,60*plot_speed)==10*plot_speed)
            Panel_com('stop')
            Panel_com('set_ao', [3 1000]);
            Panel_com('send_gain_bias', [0, 0, 0, 0]);
            Panel_com('start')
        end
        
        if (mod(cnt,60*plot_speed)==30*plot_speed)
            Panel_com('stop')
            Panel_com('set_ao', [3 2000]);
            Panel_com('send_gain_bias', [gain, 0, 0, 0]);
            Panel_com('start')
        end
        
        if (mod(cnt,60*plot_speed)==40*plot_speed)
            Panel_com('stop')
            Panel_com('set_ao', [3 1000]);
            Panel_com('send_gain_bias', [0, 0, 0, 0]);
            Panel_com('start')
    end
end
end