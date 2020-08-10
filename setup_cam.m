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
for i = 1:1:20
    pause(2);
    trigger(vid_temp);
    im = getdata(vid_temp,1);
    im = flipud(im);
    hold on;
    % the milliKelvin to C conversion is C = mK/1000 - 273.15
    % the temperature camera is giving readings in 1 unit = 10 mK
    imagesc(im/100-273.15);
    colormap(jet); colorbar;
end

stop(vid_temp);