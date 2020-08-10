% temp_reality input arguments are:


% 1) file_name you want to save to,
% 2) duration of experiment in seconds,
% 3) world_number (as defined in get_world function),
% 4) visual_display (see below for description)
% 5) frame_dump (see below for description)
% 6) pid_mode (see below for description)
% 7) angle_mode (laser is controlled by heading angle of fly)

% If visual_display is 0 then the open_loop_control.m code will be
% executed. This functionality has been deleted since closed
% loop is always used. It can be added back by adding a set of timers that
% can control  the Panel Control Box, or by modifying the frame dumping
% loop to dump a user specified array of frames.
% If > 0 then the number will be the pattern_number used in closed loop.

% If frame_dump is 1 then frame dump at 20Hz with rgain user defined. Rgain
% defines the mapping betweeen ball rotations and world rotations. Find
% variable in code below to set this variable.
% If frame_dump is 0 then the Panel Control Box will take control of the
% visual display. I would discourage the use of this mode because
% the code is currently written to integrate heading (adding up delta-headings)
% and therefore may drift from the estimate going to the panel controller.
% There are no drifts in any of the tests I have performed, but I still
% recommend re-writing the code for no integration (a very easy change) if
% you want to have the Panel Control Box take control of your visual
% display.

% If pid_mode is 1, then there will be closed loop temperature control.
% In this mode, the world should be specified in units of C
% (in get_world function) rather than in units of duty cycle fraction
% If using this mode, please close the Temperature Camera in ResearchIR
% software so that Matlab can take control.

% Please do not have the FireFlyMV camera that will be trigerred/saved open
% in FlyCap (if you would like a synchronized movie of the fly, this code
% is currently commented out, and this camera is currently not mounted).

% The NIDAQ's must be in Single Ended and RSE mode! RSE mode reduces the
% noise significantly (otherwise there appear to be ground fluctuations)
% particularly when Panel Controller is connected to NIDAQ

% daq.getDevices will get NI devices connected to the computer
% In the initial setup, devices were as follows:
% index Vendor Device ID          Description
% ----- ------ --------- ------------------------------
% 1     ni     Dev6      National Instruments PCIe-6351
% 2     ni     Dev5      National Instruments PCIe-6351

% Dev 4 is used in this Matlab code
% Dev 5 is for streaming in WinEDR

function temp_reality_jump(file_name, duration, world_num, visual_display, dump_mode, pid_mode, angle_mode, jump_mode)

% the current x and y position of the fly in the virtual world
% x and y are in units of full ball rotations
global x;
global y;
global head_angle;

% used for integration (previous values from last integration)
global xp;
global yp;
global headp;

xp = [];
yp = [];
headp = [];

global xp120;
global yp120;
global headp120;
global prev_jump;
global jump;
global jump_cnt;
global man_jump;
global curr_speed;
global curr_rot;
global curr_std;

xp120 = zeros(20*120,1);
yp120 = zeros(20*120,1);
headp120 = zeros(20*120,1);
prev_jump = 1;
jump = 0;
man_jump = 0;
jump_cnt = 0;
curr_speed = 0;
curr_rot = 0;
curr_std = 0;

% the user defined virtual world
global space_map;
global current_spacemap;
global time_elapsed;

time_elapsed = 0;

% handles to manipulate plots
global draw_map;
global plot_axes_hnd;
global display_axes_hnd;
global dutytext;

% used for masking fly in temperature camera and pid control
% pid control is currently using only the last 3 samples for integration
% control (see length of prev_error)
global flymask;
global fly_temperature;
global prev_error;
global prev_duty;
global im;

fly_temperature = [];
prev_duty = 0;
prev_error = zeros(1,3);

% the arduino object for laser control with PWM and the duty cycle
global a;
global duty;
duty = 0;

% the world size (the world will wrap around every world_size)
global world_size;
world_size = 32;

% file for writing
global write_file;

% pattern file
global filep;

% rgain is the mapping of the number of ball rotations to the
% world rotations. An rgain of 2 means that 1 ball rotation
% (a full 360 on the ball) rotates the fly twice in the virtual world.
% A rgain of 0.5 means the fly needs to rotate the ball twice (a 720)
% before it rotates once in the virtual world. Rgain does not affect
% translation, only rotation. Changing rgain will make the visual display
% move faster (or slower) in closed loop frame dump mode.

global rgain;
rgain = 1;

if(~dump_mode && rgain ~= 1)
    disp 'Rgain must be 1, exiting'
end

% tgain is the translational mapping. That is if tgain is .1, then 1
% ball rotation forward (or to side) only moves the fly .1 units in the world.
% A tgain of 10 means that 1 ball rotation forward (or to side) moves the fly
% 10 units in the world. Changing tgain will not affect the visual duisplay
% (since visual display does not care about translation)

global tgain;
tgain = 1;

% Matlab plotting speed in Hz
plot_speed = 0.5;

% starting coordinates of fly
x = world_size/2+1;
y = world_size/2+1;
head_angle = 0;

% current visual display pattern and offset of world
global pattern_xnum;
pattern_xnum = -1;
global current_visualoffset;
current_visualoffset = 0;
global current_openloop_mode;
current_openloop_mode = 0;

% initialize output text file
write_file = fopen([file_name '.txt'],'w');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% user defined virtual world in x, y coordinates
% values must be between 0 and 1 these values control
% the duty cycle of the 1000Hz PWM from Arduino Uno

% calls the get_world function which defines the worlds
% you want to use
space_map = get_world(world_num, world_size);
current_spacemap = world_num;

% make sure the duty cycle in the world cannot be greater than 0.3
if(~pid_mode)
    if(max(space_map) > .3)
        disp 'Duty cycle greater than 0.3, exiting'
        return;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NIDAQ object initialization for input
s = daq.createSession('ni');

% NIDAQ object initialization for output
% s2 = daq.createSession('ni');

% In0 is sideward (x)
% In1 is heading
% In2 is forward (y)
% In3 is pattern x_num

In0 = addAnalogInputChannel(s,'Dev6', 1, 'Voltage');
In1 = addAnalogInputChannel(s,'Dev6', 3, 'Voltage');
In2 = addAnalogInputChannel(s,'Dev6', 6, 'Voltage');
In3 = addAnalogInputChannel(s,'Dev6', 10, 'Voltage');

% Out0 is duty cycle output
% Out1 is camera trigger
% Out0 = addAnalogOutputChannel(s2,'Dev6', 0, 'Voltage');
% Out1 = addAnalogOutputChannel(s2,'Dev6', 1, 'Voltage');

% These channels are not currently being used
% addCounterOutputChannel(s,'Dev6', 0, 'PulseGeneration');
% addCounterOutputChannel(s,'Dev6', 1, 'PulseGeneration');

In0.TerminalConfig = 'SingleEnded';
In1.TerminalConfig = 'SingleEnded';
In2.TerminalConfig = 'SingleEnded';
In3.TerminalConfig = 'SingleEnded';

s.Rate = 1000;
s.DurationInSeconds = duration;
s.NotifyWhenDataAvailableExceeds = 50;

% s2.Rate = 1000;
% s2.IsContinuous = true;

disp 'Connected to NIDAQ'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Arduino object initialization
% if(isempty(a))
%     a = arduino('COM7');
% end

% Set intial PWM duty cycle
%writePWMDutyCycle(a,'D11',duty);

disp 'Connected to Arduino (PWM laser)'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Visual display initialization
% closed loop
if(visual_display > 0)
    if(~dump_mode)
        Panel_com('set_mode', [3 0]);
        Panel_com('set_pattern_id', visual_display);
        Panel_com('set_ao', [3 1000]);
        Panel_com('send_gain_bias', [1, 0, 0, 0]);
        Panel_com('start');
        disp 'Connected to Visual Display in Closed Loop'
    else
        Panel_com('pc_dumping_mode');
        pause(2);
        Panel_com('ctr_reset');
        pause(2);
        disp 'Connected to Visual Display in Closed Loop Frame Dump'
    end
end

% for open loop panel control
if(visual_display == 0)
    cnt = 0;
    Panel_com('set_mode', [0 0]);
    Panel_com('set_ao', [3 1000]);
    Panel_com('send_gain_bias', [0, 0, 0, 0]);
    open_loop_display_gain = 10;
    Panel_com('all_off');
    disp 'Connected to Visual Display in Open Loop'
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FireFly MV camera initialization
% filemov1 = [file_name];
% vid = videoinput('pointgrey', 2, 'Mono8_640x480');
% src = getselectedsource(vid);
% src.Shutter = 5; %shutter must be small to get 20Hz
% src.Exposure = 30;
% vid.FramesPerTrigger = 1;
% vid.LoggingMode = 'disk';
% vid.TriggerRepeat = Inf;
% %vid.ROIPosition = [160 120 480 240];
% triggerconfig(vid, 'hardware', 'fallingEdge', 'externalTriggerMode0-Source0');
% diskLogger = VideoWriter(filemov1, 'Uncompressed AVI');
% diskLogger.FrameRate = 20;
% vid.DiskLogger = diskLogger;
%
% preview(vid);
% start(vid);
%
% disp 'FireFlyMV camera initialized and ready for triggers';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Thermal camera FLIR A655sc Initialization
% (connected using Gigabit Ethernet)

close all;

if(pid_mode >= 1)
    vid_temp = videoinput('gige', 1, 'Mono16');
    src_temp = getselectedsource(vid_temp);
    vid_temp.FramesPerTrigger = 1;
    
    % % setup w/o windowing
    % src_temp.IRFrameRate = 'Rate50Hz';
    % src_temp.IRFormat = 'TemperatureLinear10mK';
    % set(vid_temp,'FramesPerTrigger',1);  % capture 1 frame every time vid_temp is triggered
    % set(vid_temp,'TriggerRepeat',Inf);   % infinite amount of triggers
    % triggerconfig(vid_temp, 'Manual');   % trigger vid_temp manually within program
    % vid_temp.ROIPosition = [230 200 100 100];
    
    % setup w/ windowing
    src_temp.IRFormat = 'TemperatureLinear10mK';
    set(vid_temp,'FramesPerTrigger',1);  % capture 1 frame every time vid_temp is triggered
    set(vid_temp,'TriggerRepeat',Inf);   % infinite amount of triggers
    triggerconfig(vid_temp, 'Manual');   % trigger vid_temp manually within program
    src_temp.IRWindowing = 'Quarter';    % quarter windowing allows 200Hz acquistion instead of 50Hz (full window)
    pause(3);                            % windowing often takes some time to be set
    
    % be careful to not make a ROI greater than 640x120 during quarter
    % windowing everything will stop working and both the camera and the
    % computer will have to be restarted.
    vid_temp.ROIPosition = [0 0 630 110];
    
    start(vid_temp);
    pause(1);
    trigger(vid_temp);
    im = getdata(vid_temp,1);
    im = flipud(im);
    flytempfig = figure; hold on; pause(1)
    % the milliKelvin to C conversion is C = mK/1000 - 273.15
    % the temperature camera is giving readings in 1 unit = 10 mK
    imagesc(im/100-273.15);
    colormap(jet); colorbar
    
    % acquiring region of fly for temperature estimate and pid control
    disp 'Zoom into fly and then press any button'
    zoom on; pause(1); pause; zoom off;
    disp 'Draw polygon around region to compute mean temperature';
    pause(1);
    flymask = roipoly;
    
    disp 'FLIR A655sc Initialized';
end

% Timer function for temperature camera
% (currently using camera in doIntegration loop)
% tmr_plottemp = timer('ExecutionMode', 'FixedRate', ...
%     'Period', 1/20, ...
%     'TimerFcn', {@timer_for_temp_camera});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create a new figure for real-time plotting draw the visual display
close all;
FigA =  figure('position',[200 200 700 700]);
hold on;
if(visual_display > 0)
    t = title({['Translational gain (tgain) = ' num2str(tgain)]; ['Rotational gain (rgain) = ' num2str(rgain)]; 'Closed Loop Mode'});
end
if(visual_display == 0)
    t = title({['Translational gain (tgain) = ' num2str(tgain)]; ['Rotational gain (rgain) = ' num2str(rgain)]; 'Open Loop Mode'});
end

set(t, 'FontSize', 10);

% plotting the visual display around the world map
visual_display_cmap = zeros(256,3);
visual_display_cmap(:,2) = 0:1/256:1-1/256;

% if in closed loop start with the pattern
if(visual_display > 0)
    visdisplay_string = pad_zeros_for_pattern(visual_display);
    filep = load(['E:\vikram\beta code for VR2\patterns_24panel\' visdisplay_string],'pattern');
    [rows, cols, ~] = size(filep.pattern.Pats);
    gs_val = filep.pattern.gs_val;
    [sx,sy,sz] = cylinder(rows,cols);
    tmp_pat = [];
    tmp_pat(:,:,1) = zeros(rows,cols);
    tmp_pat(:,:,2) = flipud(filep.pattern.Pats(:,:,1));
    tmp_pat(:,:,3) = zeros(rows,cols);
    warp(sx,sy,sz, flipud(tmp_pat./((2^gs_val)-1)),visual_display_cmap);
end

% if in open loop start with blank
if(visual_display == 0)
    [sx,sy,sz] = cylinder(4,96);
    warp(sx,sy,sz,zeros(4,96,3),visual_display_cmap);
end

view([-179.4, 87]);

set(gca,'color','none')
set(gca,'xtick',[]);
set(gca,'xcolor','none');
set(gca,'ytick',[]);
set(gca,'ycolor','none');
set(gca,'ztick',[]);
set(gca,'zcolor','none');
colormap(gca,visual_display_cmap);

% creating the axis for the world plot in middle of display
display_axes_pos = get(gca,'position');
display_axes_hnd = gca;
plot_axes_pos = display_axes_pos;
plot_axes_pos(3:4) = plot_axes_pos(3:4)/2;
plot_axes_pos(1) = display_axes_pos(1)+display_axes_pos(3)/2-plot_axes_pos(3)/2;
plot_axes_pos(2) = display_axes_pos(2)+display_axes_pos(4)/2-plot_axes_pos(4)/2;

% plot and format world plot
plot_axes_hnd = axes('position', plot_axes_pos);
set(FigA,'CurrentAxes',plot_axes_hnd);
hold on;
xlabel('front of arena');
draw_map = imagesc([.5, length(space_map)-.5], [.5, length(space_map)-.5], transpose(space_map));
set(gca,'xlim',[0 world_size]);
set(gca,'ylim',[0 world_size]);
set(gca,'YDir','reverse');
set(gca,'XDir','reverse');
alpha(draw_map,.5);
colormap(plot_axes_hnd,flipud(autumn));
c = colorbar;
cpos = c.Position;
cpos(3) = 0.5*cpos(3);
cpos(4) = 0.5*cpos(4);
cpos(2) = cpos(2)+0.5*cpos(4);
cpos(1) = cpos(1)+.27;
c.Position = cpos;
set(plot_axes_hnd,'position', plot_axes_pos);
set(plot_axes_hnd,'Ycolor',[0 0 0]);
set(plot_axes_hnd,'Xcolor',[0 0 0]);

current_pos = scatter(mod(x,world_size),mod(y,world_size),12,'b','filled');
current_quiver = quiver(mod(x,world_size),mod(y,world_size), sin(head_angle(end)),cos(head_angle(end)),'ob','LineWidth',1,'Markersize',1);
current_history = plot(mod(x,world_size),mod(y,world_size),'k');
hold off;

% Timer function for real-time plotting loop
% The most recent timing tests were done with this at 0.5 Hz. Please do a
% timing test if you would like to make this update faster.
tmr_plot = timer('ExecutionMode', 'FixedRate', ...
    'Period', 1/plot_speed, ...
    'TimerFcn', {@timer_for_realtimeplot});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create timers that can change the virtual world
% tmr_worldchange1 = timer('ExecutionMode', 'SingleShot', ...
%     'StartDelay',300, ...
%     'TimerFcn', {@world_change_1});
% 
% tmr_worldchange2 = timer('ExecutionMode', 'SingleShot', ...
%    'StartDelay',3600, ...
%    'TimerFcn', {@world_change_2});

% tmr_worldchange2 = timer('ExecutionMode', 'SingleShot', ...
%    'StartDelay',3600, ...
%    'TimerFcn', {@world_change_2});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create buttons and text boxes
% This button is to stop the program
btn1 = uicontrol('Style', 'pushbutton', 'String', 'Stop',...
    'Position', [20 20 80 20],...
    'Callback', @bpress1);

% This button is to change the world
btn2 = uicontrol('Style', 'edit', 'String', num2str(current_spacemap),...
    'Position', [20 45 80 20],...
    'Callback', @bpress2);

txt2 = uicontrol('Style','text',...
    'Position',[20 70 80 20],...
    'String','Change World');

% This textbox gives you real time parameters
dutytext = uicontrol('Style','text',...
    'Position',[10 200 125 150],...
    'String','Duty');

if(visual_display >0)
    % This button is to offset heading (only avaible in closed loop
    % mode)
    btn3 = uicontrol('Style', 'edit', 'String', num2str(current_visualoffset),...
        'Position', [20 100 80 20],...
        'Callback', @bpress3);

    txt3 = uicontrol('Style','text',...
        'Position',[20 120 80 30],...
        'String','Offset Heading (0 to 360)');
end

disp([num2str(plot_speed) 'Hz Plotting Initialized']);

disp('Do NOT Zoom and Pan (these will cause timing delays)');
disp('I will add back this functionality at some point ...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Will call doIntegration after x number of samples
% (currently 1000 / 50 = 20Hz)
lh1 = addlistener(s,'DataAvailable', @doIntegration);

% This is the initial output data queue (required for session to start)
% queueOutputData(s2,[duty.*ones(500,1), 5.*ones(500,1)]);

% Start output session and pause for queue to be depeleted
% startBackground(s2);

% Pause 5 second before starting, this ensures that the visual display has
% started
disp 'Pausing 5 seconds'
pause(5);
disp 'Pausing finished'

% Initialize timers and trial identifiers
trial_id = 0;
tic;

% Start experiment
startBackground(s);
start(tmr_plot);
% start(tmr_plottemp);
%  start(tmr_worldchange1);
%  start(tmr_worldchange2);

% Set initial output
% outputSingleScan(s2,[duty, 5]);
% writeDigitalPin(a,'D3',0);

% This loop keeps the code running till the session finishes
% It seems odd to pause every 1/500 sec, but the timing tests (6/7/16)
% show this is the best to keep the integration loop running every 50 ms.
% larger pauses, s.wait(), wait(s), or waiting for a timer to finish
% execution did not work as well!

while(s.IsRunning)
    pause(1/500);
end

if(~s.IsRunning)
    %writePWMDutyCycle(a,'D11',0);
    stop(tmr_plot);
    delete(tmr_plot);
    % stop(tmr_plottemp);
    % delete(tmr_plottemp);
    if(pid_mode)
        stop(vid_temp);
        delete(vid_temp);
    end
%      stop(tmr_worldchange1);
%      delete(tmr_worldchange1);
%      stop(tmr_worldchange2);
%      delete(tmr_worldchange2);
    
    Panel_com('all_off');
    % stop(vid);
    % delete(vid);
    % stop(s2);
    Panel_com('stop');
    fclose(write_file);
    % save([file_name '.mat'],'space_map');
    % savefig(FigA,[file_name '.fig']);
    fclose(serial(a.Port));
    disp 'All files saved'
    fclose('all');
    clear all;
end

    function timer_for_temp_camera(~, ~)
    end

    function world_change_1(~, ~)
        current_spacemap = 46;
        space_map = get_world(current_spacemap, world_size);
        draw_map.CData = transpose(space_map);
        trial_id = 1;
    end

    function world_change_2(~, ~)
        current_spacemap = 47;
        space_map = get_world(current_spacemap, world_size);
        draw_map.CData = transpose(space_map);
        trial_id = 2;
    end

    function timer_for_realtimeplot(~, ~)
        % update the scatter point for fly current position
        current_pos.XData = mod(x,world_size);
        current_pos.YData = mod(y,world_size);
        
        % update the quiver arrow for fly current position
        current_quiver.XData = mod(x,world_size);
        current_quiver.YData = mod(y,world_size);
        current_quiver.UData = sin(head_angle(end));
        current_quiver.VData = cos(head_angle(end));
        
        % update the history
        current_history.XData = [current_history.XData, mod(x,world_size)];
        current_history.YData = [current_history.YData, mod(y,world_size)];
        
        set(dutytext,'String',['Duty = ' num2str(duty) char(10) 'FlyTemp = ' num2str(fly_temperature) char(10) 'TimeElap = ' num2str(time_elapsed) char(10) 'JumpCnt = ' num2str(jump_cnt) char(10) 'Sp3s = ' num2str(curr_speed) char(10) 'Std120s = ' num2str(curr_std) char(10) 'NetDist120s = ' num2str(curr_rot) char(10) 'PrevJump = ' num2str(prev_jump/20)]);
        
        % zoom in on fly (this code was slowing the program down)
        %set(FigA,'CurrentAxes',plot_axes_hnd);
        %set(plot_axes_hnd,'xlim',[mod(x, world_size)-5 mod(x, world_size)+5]);
        %set(plot_axes_hnd,'ylim',[mod(y, world_size)-5 mod(y, world_size)+5]);
    end

    function doIntegration(~, event)
        
        % Write PWM to NIDAQ output and falling edge camera trigger to
        % Arduino (currently disabled)
        % outputSingleScan(s2,[duty, 5]);
        % writeDigitalPin(a,'D3',1);
        
        time_elapsed = time_elapsed + 1/20;
        
        % Acquire a FLIR temperature camera image
        if (pid_mode)
            trigger(vid_temp);
            im = getdata(vid_temp,1);
            im = flipud(im);
            fly_temperature = mean(im(flymask))/100 - 273.15;
        end
        
        % FicTrac output is between 0 and 10. This is being sent to the
        % NIDAQ board.
        
        % Need to convert to radians, then unwrap, and then integrate
        % using my version of the sin/cos transformation
        
        % this is more accurate than previous versions where we did
        % not concatenate the last timepoint from the previous recording to
        % the first of the next (this is required to get perfect diffs.
        
        % this will be run if the loop is being executed for the first
        % time, and xp has not been initialized
        if(isempty(xp))
            x_pos1 = diff(unwrap([pi*event.Data(:,1)./5]))./(2*pi);
            y_pos1 = diff(unwrap([pi*event.Data(:,3)./5]))./(2*pi);
            
            head_angle = head_angle(end) + cumsum(diff(unwrap(pi.*event.Data(1:end,2)./5)).*rgain);
            head_angle = mod(head_angle,2*pi);
        else
            x_pos1 = diff(unwrap(pi*[xp; event.Data(:,1)]./5))./(2*pi);
            y_pos1 = diff(unwrap(pi*[yp; event.Data(:,3)]./5))./(2*pi);
            
            head_angle = head_angle(end) + cumsum(diff(unwrap(pi.*[headp; event.Data(1:end,2)]./5)).*rgain);
            head_angle = mod(head_angle,2*pi);
        end
        
        x_pos2 = y_pos1.*sin(head_angle)   +   x_pos1.*cos(head_angle);
        y_pos2 = y_pos1.*cos(head_angle)   -   x_pos1.*sin(head_angle);
        
        % apply the translational gain before adding the dx and dy to the
        % previous position
        x = tgain.*sum(x_pos2)+x;
        y = tgain.*sum(y_pos2)+y;
        
        % save all the last values from this loop, so they can be used in
        % the next
        xp = event.Data(end,1);
        yp = event.Data(end,3);
        headp = event.Data(end,2);
        pattern_xnum = event.Data(end,4);
        
        % save values from previous 2 min for stats (like wheter to jump)
        xp120 = [x; xp120];
        xp120 = xp120(1:(120*20));
        
        yp120 = [y; yp120];
        yp120 = yp120(1:(120*20));
        
        headp120 = [head_angle(end); headp120];
        headp120 = headp120(1:(120*20));
        
        if(jump)
            jump = 0;
        end
        [jump, curr_speed, curr_std, curr_rot] = jump_or_nojump(xp120,yp120,headp120,prev_jump,time_elapsed*20,.79*pi);
        if(jump  && (jump_mode == 1))
            prev_jump = time_elapsed*20;
           %tmp_angle = mod(head_angle(end)+(180/360*2*pi),2*pi);
           sgn = rand([1,1]);
           sgn(sgn<0.5) = -1;
           sgn(sgn>=0.5) = 1;
           tmp_angle = mod(head_angle(end)+sgn*(90/360*2*pi),2*pi);

%             if(tmp_angle > (2*pi*310/360))
%                 tmp_angle = 2*pi*310/360;
%             end
%             if(tmp_angle < (2*pi*50/360))
%                 tmp_angle = 2*pi*50/360;
%             end
            head_angle(end) = tmp_angle;
            jump_cnt = jump_cnt+1;
        else
            jump = 0;
        end
        
        if(angle_mode == 0)
            desired_dutyortemp = space_map(ceil(mod(x,world_size)),ceil(mod(y,world_size)));
        end
        
        if(angle_mode > 0)
            if(head_angle(end) == 0)
                desired_dutyortemp = space_map(1);
            else
                desired_dutyortemp = space_map(ceil(head_angle(end)./(2*pi)*3600));
            end
        end
        
        if(pid_mode)
            prev_error(1:2) = prev_error(2:3);
            if(isempty(fly_temperature))
                fly_temperature = desired_dutyortemp;
            end
            prev_error(end) = desired_dutyortemp - fly_temperature;
            
            kp = 0.015;
            kd = 0.5;
            ki = 0.02;
            
            duty = prev_error(end).*kp +  (prev_error(end) - prev_error(end-1)).*kd + sum(prev_error).*ki + prev_duty;
            duty = min(duty,.5);
            duty = max(duty, 0);
            prev_duty = duty;
        else
            duty = desired_dutyortemp;
            % fly temperaure will be fixed at -1 if you are not in pid_mode
            fly_temperature = -1;
        end
        
        % Set PWM depending on the point in space
        %writePWMDutyCycle(a,'D11',duty);
        
        % Frame dump to display
        % send_pat is the pattern that is currently being dumped
        % it will be fixed at 1 if you are not in frame_dump mode
        
        send_pat = 1;
        if(dump_mode)
            [rows, cols, numpats] = size(filep.pattern.Pats);
            if(head_angle(end) ~= 0)
                send_pat = numpats+1-ceil(head_angle(end)./(2*pi)*numpats);
                framedump(filep.pattern.Pats(:,:,send_pat), filep.pattern.Panel_map, 24, 5, round(send_pat/numpats*32767), round((jump+man_jump)/10*32767));
            else
                send_pat = 1;
                framedump(filep.pattern.Pats(:,:,send_pat), filep.pattern.Panel_map, 24, 5, round(send_pat/numpats*32767), round((jump+man_jump)/10*32767));
            end
        end
        
        % Writing to file the following
        % col 1: x position of fly in world
        % col 2: y position of fly in world
        % col 3: heading angle from FicTrac (between 0 and 2pi)
        % col 4: side position of ball from FicTrac (between 0 and 10)
        % col 5: forward position of ball from FicTrac (between 0 and 10)
        % col 6: duty cycle of laser
        % col 7: current spacemap being used
        % col 8: pattern_xnum on visual display (not used in frame_dump
        % mode)
        % col 9: mode the program was run in (visual_display)
        % col 10: tgain value
        % col 11: rgain value
        % col 12: open loop control mode identifier
        % col 13: trial id
        % col 14: fly temperature (used only in pid_mode)
        % col 15: the desired duty or temperature
        % col 16: pattern sent (used in frame_dump mode)
        % col 17: time elapsed between writes
        % col 18: is there a auto jump or manual jump
        
        elp = toc; tic;
        write_to_file = [x; y; head_angle(end); event.Data(end,1); event.Data(end,3); duty; current_spacemap; pattern_xnum; visual_display; tgain; rgain; current_openloop_mode; trial_id; fly_temperature; desired_dutyortemp; send_pat; elp; (jump+man_jump)];
        fprintf(write_file,'%3f %3f %3f %3f %3f %12.8f %3f %3f %3f %3f %3f %3f %3f %3f %3f %3f %3f %3f\r\n',write_to_file);
        
        if(man_jump)
            man_jump = 0;
        end
        
        % Write PWM to NIDAQ and rising edge camera reset to Arduino
        % outputSingleScan(s2,[duty, 0]);
        % outputSingleScan(s2,[event.Data(end,2)./(5), 0]);
        % writeDigitalPin(a,'D3',0);
    end

    function bpress1(~,~)
        stop(s);
    end

    function bpress2(hObject,~)
        current_spacemap = str2num(hObject.String);
        space_map = get_world(current_spacemap, world_size);
        draw_map.CData = transpose(space_map);
    end

    function bpress3(hObject,callbackdata)
        current_visualoffset = str2num(hObject.String);
        head_angle = mod(head_angle+(current_visualoffset/360*2*pi),2*pi);
        jump_cnt = jump_cnt+1;
        man_jump = 1;
    end

    function s = pad_zeros_for_pattern(vis_display)
        if(vis_display < 10)
            s = ['Pattern_00' num2str(vis_display) '.mat'];
        end
        
        if(vis_display >= 10 && vis_display < 99)
            s = ['Pattern_0' num2str(vis_display) '.mat'];
        end
        
        if(vis_display >= 100)
            s = ['Pattern_' num2str(vis_display) '.mat'];
        end
    end

end
