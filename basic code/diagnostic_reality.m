figure; title('Blue abf trajectory, Green Matlab trajectory');
hold on;
world_size = 100;

%% Loading and plotting from ABF
%% Using my version of trajectory 
[D, SI, H] = abfload('2015_12_18_0000.abf');
x_pos = diff(unwrap(pi.*D(:,3)))./(2*pi);
y_pos = diff(unwrap(pi.*D(:,1)))./(2*pi);

x_pos2 = y_pos.*sin(pi.*D(2:end,2))   +   x_pos.*cos(pi.*D(2:end,2));
y_pos2 = y_pos.*cos(pi.*D(2:end,2))   -   x_pos.*sin(pi.*D(2:end,2));

x_pos3 = cumsum(x_pos2)+(world_size/2+1);
y_pos3 = cumsum(y_pos2)+(world_size/2+1);

x_pos3 = [(world_size/2+1); x_pos3];
y_pos3 = [(world_size/2+1); y_pos3];

plot(x_pos3,y_pos3,'b');

% Loading and plotting from Matlab real time
MatData = importdata('dat2.txt');
hold on;
plot(MatData(:,1),MatData(:,2),'g')

% Loading space map
load('dat2.mat');

% Visual Display over experiment (using ABF)
fig = figure; title('ABF trajectory with display');

sur = surface([mod(x_pos3,world_size),mod(x_pos3,world_size)],[mod(y_pos3,world_size),mod(y_pos3,world_size)],[x_pos3,x_pos3],[D(:,4), D(:,4)],...
    'facecol','no',...
    'edgecol','interp',...
    'linew',2);
set(gca,'ylim',[0 world_size]);
set(gca,'xlim',[0 world_size]);
colorbar;

% Heading over experiment (using ABF)
fig = figure; title('ABF trajectory with heading');

sur = surface([mod(x_pos3,world_size),mod(x_pos3,world_size)],[mod(y_pos3,world_size),mod(y_pos3,world_size)],[x_pos3,x_pos3],[D(:,2).*180, D(:,2).*180],...
    'facecol','no',...
    'edgecol','interp',...
    'linew',2);
set(gca,'ylim',[0 world_size]);
set(gca,'xlim',[0 world_size]);
colorbar;

% Time over experiment (using ABF)
fig = figure; title('ABF trajectory with time');

sur = surface([mod(x_pos3,world_size),mod(x_pos3,world_size)],[mod(y_pos3,world_size),mod(y_pos3,world_size)],[x_pos3,x_pos3],[transpose(1:1:length(D(:,4)))./1000, transpose(1:1:length(D(:,4)))./1000],...
    'facecol','no',...
    'edgecol','interp',...
    'linew',2);
set(gca,'ylim',[0 world_size]);
set(gca,'xlim',[0 world_size]);
colorbar

% Speed over experiment (using ABF)
fig = figure; title('ABF trajectory with speed (smooth 200 ms)');
sp = calc_speed(x_pos3,y_pos3,1000,2.2);
sur = surface([mod(x_pos3,world_size),mod(x_pos3,world_size)],[mod(y_pos3,world_size),mod(y_pos3,world_size)],[x_pos3,x_pos3],[(smooth(sp,200)), (smooth(sp,200))],...
    'facecol','no',...
    'edgecol','interp',...
    'linew',2);
set(gca,'ylim',[0 world_size]);
set(gca,'xlim',[0 world_size]);
colorbar

% PWM intensity over experiment
figure; title('Matlab trajectory with PWM');
hold on; colorbar;
surface([MatData(:,1),MatData(:,1)],[MatData(:,2),MatData(:,2)],[MatData(:,1),MatData(:,1)],[MatData(:,6),MatData(:,6)],...
    'facecol','no',...
    'edgecol','interp',...
    'linew',2);

% Time over experiment
figure; title('Matlab trajectory with time');
hold on; colorbar;
frate = 0.05;
time = transpose(0:frate:(length(MatData)./(1/frate)-frate));
surface([MatData(:,1),MatData(:,1)],[MatData(:,2),MatData(:,2)],[MatData(:,1),MatData(:,1)],[time, time],...
    'facecol','no',...
    'edgecol','interp',...
    'linew',2);

% Time over experiment
fig = figure; title('Matlab trajectory with time');
back_axes = fig.CurrentAxes;
colormap(back_axes,flipud(autumn));
imagesc([.5, length(space_map)-.5], [.5, length(space_map)-.5], transpose(space_map));
set(gca,'YDir','normal'); 
set(gca,'ylim',[0 world_size]);
set(gca,'xlim',[0 world_size]);
alpha .5
hold on;
front_axes = axes;
frate = 0.05;
time = transpose(0:frate:(length(MatData)./(1/frate)-frate));
colormap(front_axes,jet); caxis(front_axes,[0,max(time)]);
sur = surface([mod(MatData(:,1),world_size),mod(MatData(:,1),world_size)],[mod(MatData(:,2),world_size),mod(MatData(:,2),world_size)],[MatData(:,1),MatData(:,1)],[time, time],...
    'facecol','no',...
    'edgecol','interp',...
    'linew',1);
set(gca,'ylim',[0 world_size]);
set(gca,'xlim',[0 world_size]);
axis(front_axes,'off')
linkaxes([back_axes,front_axes]);

% Speed over experiment
fig = figure; title('Matlab trajectory with speed');
back_axes = fig.CurrentAxes;
colormap(back_axes,flipud(autumn));
imagesc([.5, length(space_map)-.5], [.5, length(space_map)-.5], transpose(space_map));
set(gca,'YDir','normal'); 
set(gca,'ylim',[0 world_size]);
set(gca,'xlim',[0 world_size]);
alpha .5
hold on;
front_axes = axes;
colormap(front_axes,jet); caxis(front_axes,[0,.05]);
speed = transpose(calc_speed(MatData(:,1), MatData(:,2),20,2.2));
sur = surface([mod(MatData(:,1),world_size),mod(MatData(:,1),world_size)],[mod(MatData(:,2),world_size),mod(MatData(:,2),world_size)],[MatData(:,1),MatData(:,1)],[speed, speed],...
    'facecol','no',...
    'edgecol','interp',...
    'linew',2);
set(gca,'ylim',[0 world_size]);
set(gca,'xlim',[0 world_size]);
axis(front_axes,'off')
linkaxes([back_axes,front_axes]);

% Speed over experiment (smooth)
fig = figure; title('Matlab trajectory with speed, smooth 1 sec');
back_axes = fig.CurrentAxes;
colormap(back_axes,flipud(autumn));
imagesc([.5, length(space_map)-.5], [.5, length(space_map)-.5], transpose(space_map));
set(gca,'YDir','normal'); 
set(gca,'ylim',[0 world_size]);
set(gca,'xlim',[0 world_size]);
alpha .5
hold on;
front_axes = axes;
colormap(front_axes,jet); caxis(front_axes,[0,.05]);
speed = smooth(transpose(calc_speed(MatData(:,1), MatData(:,2),20,2.2)),20);
sur = surface([mod(MatData(:,1),world_size),mod(MatData(:,1),world_size)],[mod(MatData(:,2),world_size),mod(MatData(:,2),world_size)],[MatData(:,1),MatData(:,1)],[speed, speed],...
    'facecol','no',...
    'edgecol','interp',...
    'linew',1);
set(gca,'ylim',[0 world_size]);
set(gca,'xlim',[0 world_size]);
axis(front_axes,'off')
linkaxes([back_axes,front_axes]);

% Speed over experiment (smooth)
fig = figure; title('Matlab trajectory with speed, smooth 1 sec');
speed = smooth(transpose(calc_speed(MatData(:,1), MatData(:,2),20,2.2)),20);
sur = surface([mod(MatData(:,1),world_size),mod(MatData(:,1),world_size)],[mod(MatData(:,2),world_size),mod(MatData(:,2),world_size)],[MatData(:,1),MatData(:,1)],[speed, speed],...
    'facecol','no',...
    'edgecol','interp',...
    'linew',2);


% Speed over experiment (smooth)
fig = figure; title('Matlab trajectory with speed, smooth .1 sec');
speed = smooth(transpose(calc_speed(MatData(:,1), MatData(:,2),20,2.2)),2);
sur = surface([mod(MatData(:,1),world_size),mod(MatData(:,1),world_size)],[mod(MatData(:,2),world_size),mod(MatData(:,2),world_size)],[MatData(:,1),MatData(:,1)],[speed, speed],...
    'facecol','no',...
    'edgecol','interp',...
    'linew',2);



