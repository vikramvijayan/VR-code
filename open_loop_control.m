% open_loop_control defines the open loop operations that will be executed
% in temp_reality.

function [current_pattern_id, current_open_mode] = open_loop_control(cnt, plot_speed, gain, previous_open_mode)

%for panel control open loop
current_pattern_id = 9;
current_open_mode = previous_open_mode;

if(cnt == 0)
    Panel_com('set_pattern_id', current_pattern_id);
end

if(mod(cnt,60*plot_speed)==0*plot_speed)
    Panel_com('stop')
    Panel_com('set_ao', [3 0]);
    current_open_mode = -1;
    Panel_com('send_gain_bias', [-1.*gain, 0, 0, 0]);
    Panel_com('start')
end

if (mod(cnt,60*plot_speed)==10*plot_speed)
    Panel_com('stop')
    Panel_com('set_ao', [3 1000]);
    current_open_mode = 2;
    Panel_com('send_gain_bias', [0, 0, 0, 0]);
    Panel_com('start')
end

if (mod(cnt,60*plot_speed)==30*plot_speed)
    Panel_com('stop')
    Panel_com('set_ao', [3 2000]);
    current_open_mode = 1;
    Panel_com('send_gain_bias', [gain, 0, 0, 0]);
    Panel_com('start')
end

if (mod(cnt,60*plot_speed)==40*plot_speed)
    Panel_com('stop')
    Panel_com('set_ao', [3 1000]);
    current_open_mode = 2;
    Panel_com('send_gain_bias', [0, 0, 0, 0]);
    Panel_com('start')
end
end
