%ak_make_stim_patterns_for_mangotether_June2015()
function ak_make_stim_patterns_for_mangotether_July2015()
%create visual stim patterns for the magnotether experiments (Farid)
%Anmo Kim
%6/26/2015
%modified from ak_make_stim_patterns_for_itzel.m (Juley 2014)

% choosing pattern classes
disp('This script generates visual stim patterns for magnotether (12x4 panel array)"');
disp('Anmo Kim (7/31/2015)')
disp('[1] Unform fields (gray level=2^3)');
disp('[2] VERTICAL STRIPES & GRATINGS (gray level=2^3, period=8pixels)');
disp('[3] HORIZONTAL STRIPES & GRATINGS (gray level=2^3, period=8pixels)');
disp('[4] (sacaacde suppression behavior) spot/checkerboard/RandVGratings (gray level=2^3)');




bTask1=false;
bTask2=false;
bTask3=false;
bTask4=false;

ans=input('  type the task number (e.g.''1:2'', ''all'' for all, and ''q'' to quit) : ','s');
if(~isempty(ans))
    if(~isempty(findstr(ans,'all')))
        bTask1=true;
        bTask2=true;
        bTask3=true;
        bTask4=true;
    end
    
    if(~isempty(findstr(ans,'q')))
        return;
    end
    
    choices=str2num(ans);
    
    if(sum(choices==1)>0) bTask1=true; end %1
    if(sum(choices==2)>0) bTask2=true; end %2
    if(sum(choices==3)>0) bTask3=true; end %3
    if(sum(choices==4)>0) bTask4=true; end %3 
end






%shared parameters---------------------------------------------------------
pattern.gs_val = 3; 	% This pattern will use 8 intensity levels
arenawidth=96;
fullwidth=96;
% pattern.num_panels = 48; 	% This is the number of unique Panel IDs required.
% pattern.Panel_map = [12 8 4 11 7 3 10 6 2  9 5 1;...
%     24 20 16 23 19 15 22 18 14 21 17 13;...
%     36 32 28 35 31 27 34 30 26 33 29 25;...
%     48 44 40 47 43 39 46 42 38 45 41 37];
% arenaheight=32;
pattern.num_panels = 48; 	% This is the number of unique Panel IDs required.
pattern.Panel_map = [12 8 4 11 7 3 10 6 2  9 5 1;...
    24 20 16 23 19 15 22 18 14 21 17 13;...
    36 32 28 35 31 27 34 30 26 33 29 25;...
    48 44 40 47 43 39 46 42 38 45 41 37];
arenaheight=32;
buffer_frames = 24;







%==================== UNIFORM FIELD PATTERN ===================================
if(bTask1)
    
    pattern.gs_val=3;
    nGraylevel=2^pattern.gs_val;
    
    pat=ones(arenaheight,arenawidth,nGraylevel*2-1,1)*(nGraylevel-1);
    
    %uniform gray level patterns
    for j=1:2:size(pat,3)
        pat(:,:,j,1)=(j-1)/2;
    end
    for j=2:2:size(pat,3)
        pat(:,:,j,end)=(j-2)/2;
        pat(1:2:end,2:2:end,j,end)=j/2;
        pat(2:2:end,1:2:end,j,end)=j/2;
    end
    
    pat=round(pat);
    
    
    %put the medium brightness pattern at the first position
    pat=pat(:,:,[nGraylevel:end 1:(nGraylevel-1)],:);
    
    
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat;
    pattern.x_num = size(pat,3); 	% There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat,4);
    pattern.row_compression = 0;
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
    
    
    save(['pattern01_uniform_field_gs' num2str(pattern.gs_val) '_n' num2str(pattern.num_panels)], 'pattern');
end








%====================VERTICAL STRIPES & GRATINGS====================================
if(bTask2)
    %make vertical stripes
    
    %single stripe of different width values
    stripeW=[2 3 4 6 8];
    nGraylevel=2^(pattern.gs_val);
    
    %============== one stripe veritical patterns ========================
    %initial pattern (pat1)
    pat1=ones(arenaheight,fullwidth,length(stripeW))*(nGraylevel-1);
    for i=1:length(stripeW)
        pat1(:,1:stripeW(i),i)=0;
    end
    
    
    xperiod=1;yperiod=1;
    for i=1:length(stripeW)
        [a b]=findperiods(pat1(:,:,i));
        xperiod=max(xperiod,a);yperiod=max(yperiod,b);
    end
    
    if(yperiod==1)
        pattern.row_compression=1;
        %with row_compression==1, a sinlgle pixel row is generated
        %for a panel, and all 8 pixel rows will display this pattern
        height=arenaheight/8;
        pat1=pat1(1:height,:,:);
    else
        pattern.row_compression=0;
    end
    
    
    %compose the full pattern
    pat=zeros(height,fullwidth,xperiod*(nGraylevel-1),length(stripeW)+1);
    
    for i=1:(size(pat,4)-1)
        fprintf(1,['making... - single VStripes pattern#' num2str(i) '\n']);
        for j=1:size(pat,3)
            pat(:,:,j,i)=ShiftMatrix2(pat1(:,:,i),(j-1)/(nGraylevel-1),'r','y');
        end
    end
    
    %trim patterns for 12/20 panels
    pat=pat(:,1:arenawidth,:,:);
    
    
    
    %uniform gray level patterns
    for j=1:2:size(pat,3)
        pat(:,:,j,end)=mod(ceil(j/2),nGraylevel);
    end
    for j=2:2:size(pat,3)
        pat(:,:,j,end)=mod(j/2,nGraylevel);
        pat(1:2:end,2:2:end,j,end)=mod(j/2+1,nGraylevel);
        pat(2:2:end,1:2:end,j,end)=mod(j/2+1,nGraylevel);
    end
    
    pat=round(pat);
    
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat;
    pattern.x_num = size(pat,3); 	% There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
    
    save(['pattern02_oneVStripe_gs' num2str(pattern.gs_val) '_n' num2str(pattern.num_panels)], 'pattern');
    
        
        
        
        
    
    
    %============== vertical grating patterns ========================
    %initial pattern (pat1)
    pat1=ones(arenaheight,fullwidth,length(stripeW))*(nGraylevel-1);
    
    
    for i=1:length(stripeW)
        nbands=floor(fullwidth/stripeW(i)/2);
        for j=1:nbands
            pat1(:,round((j-1)*(fullwidth/nbands))+(1:stripeW(i)),i)=0;
        end
    end
    
    
%     xperiod=1;yperiod=1;
%     for i=1:length(stripeW)
%         [a b]=findperiods(pat1(:,:,i));
%         xperiod=max(xperiod,a);yperiod=max(yperiod,b);
%     end
    xperiod=96;
    yperiod=1;
    
    if(yperiod==1)
        pattern.row_compression=1;
        %with row_compression==1, a sinlgle pixel row is generated
        %for a panel, and all 8 pixel rows will display this pattern
        height=arenaheight/8;
        pat1=pat1(1:height,:,:);
    else
        pattern.row_compression=0;
    end
    
    
    
    
    %compose the full pattern
    pat=zeros(height,fullwidth,xperiod*(nGraylevel-1),length(stripeW)+1);
    
    for i=1:(size(pat,4)-1)
        fprintf(1,['making... - VGratings pattern#' num2str(i) '\n']);
        for j=1:size(pat,3)
            pat(:,:,j,i)=ShiftMatrix2(pat1(:,:,i),(j-1)/(nGraylevel-1),'r','y');
        end
    end
    
    
    
    %trim patterns for 12/20 panels
    pat=pat(:,1:arenawidth,:,:);
    
    
    
    
    %uniform gray level patterns
    for j=1:2:size(pat,3)
        pat(:,:,j,end)=mod((j-1)/2,nGraylevel);
    end
    for j=2:2:size(pat,3)
        pat(:,:,j,end)=mod((j-2)/2,nGraylevel);
        pat(1:2:end,2:2:end,j,end)=mod(j/2,nGraylevel);
        pat(2:2:end,1:2:end,j,end)=mod(j/2,nGraylevel);
    end
    
    
    pat=round(pat);
    
    
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat;
    pattern.x_num = size(pat,3); 	% There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
    
    save(['pattern03_VGrating_gs' num2str(pattern.gs_val) '_n' num2str(pattern.num_panels)], 'pattern');
    
end










%====================HORIZONTAL STRIPES/GRATINGS ==========================
if(bTask3)
    %make horizontal stripes
    
    
    %single stripe of different width values
    stripeW=[2 3 4 6 8];%the stripe width
    fullheight=48;
    nGraylevel=2^(pattern.gs_val);%number of gray levels
    
    
    %============== one stripe horizontal patterns ========================
    %initial pattern (pat1)
    pat1=ones(fullheight,fullwidth,length(stripeW))*(nGraylevel-1);
    for i=1:length(stripeW)
        pat1((1:stripeW(i)),:,i)=0;
    end
    
    
    pattern.row_compression=0;
    
    
    pat=zeros(arenaheight,fullwidth,length(stripeW)+1,(arenaheight+max(stripeW))*(nGraylevel-1));
    
    for i=1:(size(pat,3)-1)
        fprintf(1,['making... - single HStripes pattern#' num2str(i) '\n']);
        for j=1:size(pat,4)
            temp=ShiftMatrix2(pat1(:,:,i),(j-1)/(nGraylevel-1),'d','y');
            pat(:,:,i,j)=temp((1:arenaheight)+stripeW(i),:);
        end
    end
    
    pat=round(pat);
    
    %uniform gray level patterns
    for j=1:2:size(pat,4)
        pat(:,:,5,j)=mod(ceil(j/2),nGraylevel);
    end
    for j=2:2:size(pat,4)
        pat(:,:,5,j)=mod(j/2,nGraylevel);
        pat(1:2:end,2:2:end,5,j)=mod(j/2+1,nGraylevel);
        pat(2:2:end,1:2:end,5,j)=mod(j/2+1,nGraylevel);
    end
    
    
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat;
    pattern.x_num = size(pat,3); 	% There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
    save(['pattern04_oneHStripe_gs' num2str(pattern.gs_val) '_n' num2str(pattern.num_panels)], 'pattern');
    
    
    
    
    
    
    
    
    
    %============== horizontal grating patterns  ========================
    nGraylevel=2^(pattern.gs_val);%number of gray levels
    
    fullheight=arenaheight;
    if(length(stripeW)>1)
        fullheight=lcm(stripeW(1),stripeW(2));
        if(length(stripeW)>2)
            for j=3:length(stripeW)
                fullheight=lcm(fullheight,stripeW(j));
            end
        end
        while(fullheight<arenaheight)
            fullheight=fullheight*min(stripeW);
        end
    end
    
    
    %initial pattern (pat1)
    pat1=ones(fullheight,fullwidth,length(stripeW))*(nGraylevel-1);
    
    for i=1:length(stripeW)
        nbands=ceil(fullheight/stripeW(i)/2);
        for j=1:nbands
            pat1(round((j-1)*(stripeW(i)*2))+(1:stripeW(i)),:,i)=0;
        end
    end
    
    xperiod=1;%yperiod=1;
    for i=1:length(stripeW)
        [a b]=findperiods(pat1(:,:,i));
        xperiod=max(xperiod,a);%yperiod=max(yperiod,b);
    end
    
    yperiod=stripeW(1)*2;
    if(length(stripeW)>1)
        yperiod=lcm(stripeW(1)*2,stripeW(2)*2);
        if(length(stripeW)>2)
            for j=3:length(stripeW)
                yperiod=lcm(yperiod,stripeW(j)*2);
            end
        end
    end
    
    
    %remake the initial pattern with yperiod height
    pat1=ones(yperiod,fullwidth,length(stripeW))*(nGraylevel-1);
    for i=1:length(stripeW)
        nbands=ceil(yperiod/stripeW(i)/2);
        for j=1:nbands
            pat1(round((j-1)*(stripeW(i)*2))+(1:stripeW(i)),:,i)=0;
        end
    end
    
    pattern.row_compression=0;
    
    
    pat=zeros(yperiod,fullwidth,length(stripeW)+1,yperiod*(nGraylevel-1));
    for i=1:length(stripeW)
        fprintf(1,['making... -  HGrating pattern#' num2str(i) '\n']);
        for j=1:size(pat,4)
            pat(:,:,i,j)=ShiftMatrix2(pat1(:,:,i),(j-1)/(nGraylevel-1),'u','y');
        end
    end
    
    pat=round(pat(1:arenaheight,1:arenawidth,:,:));
    
    
    %uniform gray level patterns
    for j=1:2:size(pat,4)
        pat(:,:,length(stripeW)+1,j)=mod(ceil(j/2),nGraylevel);
    end
    for j=2:2:size(pat,4)
        pat(:,:,length(stripeW)+1,j)=mod(j/2,nGraylevel);
        pat(1:2:end,2:2:end,end,j)=mod(j/2+1,nGraylevel);
        pat(2:2:end,1:2:end,end,j)=mod(j/2+1,nGraylevel);
    end
    
    
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat;
    pattern.x_num = size(pat,3); 	% There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
    save(['pattern05_HGrating_gs' num2str(pattern.gs_val) '_n' num2str(pattern.num_panels)], 'pattern');
    
end
















%%%% [4] (sacaacde suppression behavior) spot/checkerboard/RandVGratings (gray level=2^3)
%=============== (sacaacde suppression behavior) spot/checkerboard/RandVGratings (gray level=2^3)===========
if(bTask4)
    nGraylevel=5;%reduced from 7 to match the net luminance of stripe stimuli 
                 %this is very important to achieve 1000 deg/s speed without jumping pixels
    spotsize=8;
    pattern.row_compression=1;
    height=arenaheight/8;%because of the row compression
    
    %create the initial pattern (pat1)
    ypos = 2;%y position of the spot 
    pat1=ones(height,fullwidth)*(nGraylevel-1);
    pat1(ypos,1:spotsize)=0;
    
    %compose the full pattern
    pat=zeros(height,fullwidth,fullwidth*(nGraylevel-1));
    for j=1:size(pat,3)
        pat(:,:,j)=ShiftMatrix2(pat1,(j-1)/(nGraylevel-1),'r','y');
    end
    
    pat2=round(pat);
    %pat2 is the base pattern. the actual patterns will be sampled from these sets based on the speed profile..
   
    
    %%%%%%% short rise saccade dynamics
    framerate=500;%500 frames/sec --> 2 ms
    duration=0.13;%in ms
    
    %use logistics function
    nframes=floor(duration/(1/framerate));
    dt=0.00001;
    
    t=0:dt:duration;%50 ms
    vel=1./(1+exp(-(t-.022)/2*210))-1./(1+exp(-(t-.082)/2*103));
    vel=vel-vel(1);
    vel(vel<0)=0;
    vel=(vel-min(vel))/(max(vel)-min(vel));
    maxvel=(1000/2.25)*(nGraylevel-1);%unit:xpos with nGrayLevel=5
    xdis=(maxvel*dt)*sum(vel);%displacement of xpos in 50 ms
    
    
    %%% pattern34_spot_center_to_R_gs %%%
    x0=1;
    x1=x0+ceil(xdis/(nGraylevel-1))*(nGraylevel-1);
    pos0=cumsum(vel);
    pos0=pos0./max(pos0);%normalization
    pos=pos0*(x1-x0)+x0;
    pos=interp1(t,pos,linspace(t(1),t(end),nframes));
    disp('making pattern06_spotN_RW ...');
    for j=1:nframes
        pat3(:,:,j)=pat2(:,:,round(pos(j)));
    end
    for j=(nframes+1):(nframes+10)
        %adding 10 buffer frames
        pat3(:,:,j)=pat3(:,:,nframes);
    end
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat3;
    pattern.x_num = size(pat3,3);    % There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat3,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
    save(['pattern06_spot_x1_RW_gs' num2str(pattern.gs_val) '_n'  num2str(pattern.num_panels)], 'pattern');
    
    
    
    
    
    
    %%%%%%% pattern35_spot_center_to_L_gs %%%%%%%
    x0=1;
    x1=x0-ceil(xdis/(nGraylevel-1))*(nGraylevel-1);
    pos0=cumsum(vel);
    pos0=pos0./max(pos0);%normalization
    pos=pos0*(x1-x0)+x0;
    pos=interp1(t,pos,linspace(t(1),t(end),nframes));
    pos(pos<1)=pos(pos<1)+size(pat2,3)-1;
    disp('making pattern07_spotN_LW ...');
    for j=1:nframes
        pat3(:,:,j)=pat2(:,:,round(pos(j)));
    end
    for j=(nframes+1):(nframes+10)
        %adding 10 buffer frames
        pat3(:,:,j)=pat3(:,:,nframes);
    end
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat3;
    pattern.x_num = size(pat3,3);    % There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat3,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
    save(['pattern07_spot_x1_LW_gs' num2str(pattern.gs_val) '_n'  num2str(pattern.num_panels)], 'pattern');
    
    
    
    
    
    
    %%% pattern08_spot_x2_RW_gs %%%
    x0=97;
    x1=x0+ceil(xdis/(nGraylevel-1))*(nGraylevel-1);
    pos0=cumsum(vel);
    pos0=pos0./max(pos0);%normalization
    pos=pos0*(x1-x0)+x0;
    pos=interp1(t,pos,linspace(t(1),t(end),nframes));
    disp('making pattern08_spot_x2_RW ...');
    for j=1:nframes
        pat3(:,:,j)=pat2(:,:,round(pos(j)));
    end
    for j=(nframes+1):(nframes+10)
        %adding 10 buffer frames
        pat3(:,:,j)=pat3(:,:,nframes);
    end
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat3;
    pattern.x_num = size(pat3,3);    % There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat3,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
    save(['pattern08_spot_x2_RW_gs' num2str(pattern.gs_val) '_n'  num2str(pattern.num_panels)], 'pattern');
    
    
    
    
    
    
    %%%%%%% pattern35_spot_center_to_L_gs %%%%%%%
    x0=97;
    x1=x0-ceil(xdis/(nGraylevel-1))*(nGraylevel-1);
    pos0=cumsum(vel);
    pos0=pos0./max(pos0);%normalization
    pos=pos0*(x1-x0)+x0;
    pos=interp1(t,pos,linspace(t(1),t(end),nframes));
    pos(pos<1)=pos(pos<1)+size(pat2,3)-1;
    disp('making pattern09_spot_x2_LW_gs ...');
    for j=1:nframes
        pat3(:,:,j)=pat2(:,:,round(pos(j)));
    end
    for j=(nframes+1):(nframes+10)
        %adding 10 buffer frames
        pat3(:,:,j)=pat3(:,:,nframes);
    end
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat3;
    pattern.x_num = size(pat3,3);    % There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat3,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
    save(['pattern09_spot_x2_LW_gs' num2str(pattern.gs_val) '_n'  num2str(pattern.num_panels)], 'pattern');
    
    
    
    
    
    %%% pattern10_spot_x3_RW_gs %%%
    x0=193;
    x1=x0+ceil(xdis/(nGraylevel-1))*(nGraylevel-1);
    pos0=cumsum(vel);
    pos0=pos0./max(pos0);%normalization
    pos=pos0*(x1-x0)+x0;
    pos=interp1(t,pos,linspace(t(1),t(end),nframes));
    disp('making pattern10_spot_x3_RW_gs ...');
    for j=1:nframes
        pat3(:,:,j)=pat2(:,:,round(pos(j)));
    end
    for j=(nframes+1):(nframes+10)
        %adding 10 buffer frames
        pat3(:,:,j)=pat3(:,:,nframes);
    end
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat3;
    pattern.x_num = size(pat3,3);    % There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat3,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
    save(['pattern10_spot_x3_RW_gs' num2str(pattern.gs_val) '_n'  num2str(pattern.num_panels)], 'pattern');
    
    
    
    
    
    
    %%%%%%% pattern35_spot_center_to_L_gs %%%%%%%
    x0=193;
    x1=x0-ceil(xdis/(nGraylevel-1))*(nGraylevel-1);
    pos0=cumsum(vel);
    pos0=pos0./max(pos0);%normalization
    pos=pos0*(x1-x0)+x0;
    pos=interp1(t,pos,linspace(t(1),t(end),nframes));
    pos(pos<1)=pos(pos<1)+size(pat2,3)-1;
    disp('making pattern11_spot_x3_LW_gs ...');
    for j=1:nframes
        pat3(:,:,j)=pat2(:,:,round(pos(j)));
    end
    for j=(nframes+1):(nframes+10)
        %adding 10 buffer frames
        pat3(:,:,j)=pat3(:,:,nframes);
    end
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat3;
    pattern.x_num = size(pat3,3);    % There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat3,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
    save(['pattern11_spot_x3_LW_gs' num2str(pattern.gs_val) '_n'  num2str(pattern.num_panels)], 'pattern');
    
    
    
    
    
    
    %%% pattern12_spot_x4_RW_gs %%%
    x0=289;
    x1=x0+ceil(xdis/(nGraylevel-1))*(nGraylevel-1);
    pos0=cumsum(vel);
    pos0=pos0./max(pos0);%normalization
    pos=pos0*(x1-x0)+x0;
    pos=round(interp1(t,pos,linspace(t(1),t(end),nframes)));
    pos(pos>size(pat2,3))=pos(pos>size(pat2,3))-size(pat2,3);
    disp('making pattern12_spot_x4_RW_gs ...');
    for j=1:nframes
        pat3(:,:,j)=pat2(:,:,pos(j));
    end
    for j=(nframes+1):(nframes+10)
        %adding 10 buffer frames
        pat3(:,:,j)=pat3(:,:,nframes);
    end
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat3;
    pattern.x_num = size(pat3,3);    % There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat3,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
    save(['pattern12_spot_x4_RW_gs' num2str(pattern.gs_val) '_n'  num2str(pattern.num_panels)], 'pattern');
    
    
    
    
    
    
    %%%%%%% pattern13_spot_x4_LW_gs %%%%%%%
    x0=289;
    x1=x0-ceil(xdis/(nGraylevel-1))*(nGraylevel-1);
    pos0=cumsum(vel);
    pos0=pos0./max(pos0);%normalization
    pos=pos0*(x1-x0)+x0;
    pos=interp1(t,pos,linspace(t(1),t(end),nframes));
    disp('making pattern13_spot_x4_LW_gs ...');
    for j=1:nframes
        pat3(:,:,j)=pat2(:,:,round(pos(j)));
    end
    for j=(nframes+1):(nframes+10)
        %adding 10 buffer frames
        pat3(:,:,j)=pat3(:,:,nframes);
    end
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat3;
    pattern.x_num = size(pat3,3);    % There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat3,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
    save(['pattern13_spot_x4_LW_gs' num2str(pattern.gs_val) '_n'  num2str(pattern.num_panels)], 'pattern');
    
    
    
    
    
    
    %%%%%%%%%%%%%%%%%% vertical bars moving left/right %%%%%%%%%%%%%%%%%%%
    barwidth=8;
    pattern.row_compression=1;
    height=arenaheight/8;%because of the row compression
    
    %create the initial pattern (pat1)
    ypos = 2;%y position of the bar 
    pat1=ones(height,fullwidth)*(nGraylevel-1);
    pat1(:,1:barwidth)=0;
    
    %compose the full pattern
    pat=zeros(height,fullwidth,fullwidth*(nGraylevel-1));
    for j=1:size(pat,3)
        pat(:,:,j)=ShiftMatrix2(pat1,(j-1)/(nGraylevel-1),'r','y');
    end
    
    pat2=round(pat);
    %pat2 is the base pattern. the actual patterns will be sampled from these sets based on the speed profile..
   
    
    %%%%%%% short rise saccade dynamics
    framerate=500;%500 frames/sec --> 2 ms
    duration=0.13;%in ms
    
    %use logistics function
    nframes=floor(duration/(1/framerate));
    dt=0.00001;
    
    t=0:dt:duration;%50 ms
    vel=1./(1+exp(-(t-.022)/2*210))-1./(1+exp(-(t-.082)/2*103));
    vel=vel-vel(1);
    vel(vel<0)=0;
    vel=(vel-min(vel))/(max(vel)-min(vel));
    maxvel=(1000/2.25)*(nGraylevel-1);%unit:xpos with nGrayLevel=5
    xdis=(maxvel*dt)*sum(vel);%displacement of xpos in 50 ms
    
    
    %%% pattern34_bar_center_to_R_gs %%%
    x0=1;
    x1=x0+ceil(xdis/(nGraylevel-1))*(nGraylevel-1);
    pos0=cumsum(vel);
    pos0=pos0./max(pos0);%normalization
    pos=pos0*(x1-x0)+x0;
    pos=interp1(t,pos,linspace(t(1),t(end),nframes));
    disp('making pattern14_barN_RW ...');
    for j=1:nframes
        pat3(:,:,j)=pat2(:,:,round(pos(j)));
    end
    for j=(nframes+1):(nframes+10)
        %adding 10 buffer frames
        pat3(:,:,j)=pat3(:,:,nframes);
    end
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat3;
    pattern.x_num = size(pat3,3);    % There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat3,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
    save(['pattern14_bar_x1_RW_gs' num2str(pattern.gs_val) '_n'  num2str(pattern.num_panels)], 'pattern');
    
    
    
    
    
    
    %%%%%%% pattern14_bar_x1_LW_gs %%%%%%%
    x0=1;
    x1=x0-ceil(xdis/(nGraylevel-1))*(nGraylevel-1);
    pos0=cumsum(vel);
    pos0=pos0./max(pos0);%normalization
    pos=pos0*(x1-x0)+x0;
    pos=interp1(t,pos,linspace(t(1),t(end),nframes));
    pos(pos<1)=pos(pos<1)+size(pat2,3)-1;
    disp('making pattern14_bar_x1_LW_gs ...');
    for j=1:nframes
        pat3(:,:,j)=pat2(:,:,round(pos(j)));
    end
    for j=(nframes+1):(nframes+10)
        %adding 10 buffer frames
        pat3(:,:,j)=pat3(:,:,nframes);
    end
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat3;
    pattern.x_num = size(pat3,3);    % There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat3,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
    save(['pattern15_bar_x1_LW_gs' num2str(pattern.gs_val) '_n'  num2str(pattern.num_panels)], 'pattern');
    
    
    
    
    
    
    %%% pattern15_bar_x2_RW_gs %%%
    x0=97;
    x1=x0+ceil(xdis/(nGraylevel-1))*(nGraylevel-1);
    pos0=cumsum(vel);
    pos0=pos0./max(pos0);%normalization
    pos=pos0*(x1-x0)+x0;
    pos=interp1(t,pos,linspace(t(1),t(end),nframes));
    disp('making pattern15_bar_x2_RW_gs ...');
    for j=1:nframes
        pat3(:,:,j)=pat2(:,:,round(pos(j)));
    end
    for j=(nframes+1):(nframes+10)
        %adding 10 buffer frames
        pat3(:,:,j)=pat3(:,:,nframes);
    end
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat3;
    pattern.x_num = size(pat3,3);    % There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat3,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
    save(['pattern16_bar_x2_RW_gs' num2str(pattern.gs_val) '_n'  num2str(pattern.num_panels)], 'pattern');
    
    
    
    
    
    
    %%%%%%% pattern16_bar_x2_LW_gs %%%%%%%
    x0=97;
    x1=x0-ceil(xdis/(nGraylevel-1))*(nGraylevel-1);
    pos0=cumsum(vel);
    pos0=pos0./max(pos0);%normalization
    pos=pos0*(x1-x0)+x0;
    pos=interp1(t,pos,linspace(t(1),t(end),nframes));
    pos(pos<1)=pos(pos<1)+size(pat2,3)-1;
    disp('making pattern16_bar_x2_LW_gs ...');
    for j=1:nframes
        pat3(:,:,j)=pat2(:,:,round(pos(j)));
    end
    for j=(nframes+1):(nframes+10)
        %adding 10 buffer frames
        pat3(:,:,j)=pat3(:,:,nframes);
    end
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat3;
    pattern.x_num = size(pat3,3);    % There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat3,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
    save(['pattern17_bar_x2_LW_gs' num2str(pattern.gs_val) '_n'  num2str(pattern.num_panels)], 'pattern');
    
    
    
    
    
    %%% pattern17_bar_x3_RW_gs %%%
    x0=193;
    x1=x0+ceil(xdis/(nGraylevel-1))*(nGraylevel-1);
    pos0=cumsum(vel);
    pos0=pos0./max(pos0);%normalization
    pos=pos0*(x1-x0)+x0;
    pos=interp1(t,pos,linspace(t(1),t(end),nframes));
    disp('making pattern17_bar_x3_RW_gs ...');
    for j=1:nframes
        pat3(:,:,j)=pat2(:,:,round(pos(j)));
    end
    for j=(nframes+1):(nframes+10)
        %adding 10 buffer frames
        pat3(:,:,j)=pat3(:,:,nframes);
    end
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat3;
    pattern.x_num = size(pat3,3);    % There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat3,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
    save(['pattern18_bar_x3_RW_gs' num2str(pattern.gs_val) '_n'  num2str(pattern.num_panels)], 'pattern');
    
    
    
    
    
    
    %%%%%%% pattern18_bar_x3_LW_gs %%%%%%%
    x0=193;
    x1=x0-ceil(xdis/(nGraylevel-1))*(nGraylevel-1);
    pos0=cumsum(vel);
    pos0=pos0./max(pos0);%normalization
    pos=pos0*(x1-x0)+x0;
    pos=interp1(t,pos,linspace(t(1),t(end),nframes));
    pos(pos<1)=pos(pos<1)+size(pat2,3)-1;
    disp('making pattern18_bar_x3_LW_gs ...');
    for j=1:nframes
        pat3(:,:,j)=pat2(:,:,round(pos(j)));
    end
    for j=(nframes+1):(nframes+10)
        %adding 10 buffer frames
        pat3(:,:,j)=pat3(:,:,nframes);
    end
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat3;
    pattern.x_num = size(pat3,3);    % There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat3,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
    save(['pattern19_bar_x3_LW_gs' num2str(pattern.gs_val) '_n'  num2str(pattern.num_panels)], 'pattern');
    
    
    
    
    
    
    %%% pattern19_bar_x4_RW_gs %%%
    x0=289;
    x1=x0+ceil(xdis/(nGraylevel-1))*(nGraylevel-1);
    pos0=cumsum(vel);
    pos0=pos0./max(pos0);%normalization
    pos=pos0*(x1-x0)+x0;
    pos=round(interp1(t,pos,linspace(t(1),t(end),nframes)));
    pos(pos>size(pat2,3))=pos(pos>size(pat2,3))-size(pat2,3);
    disp('making pattern19_bar_x4_RW_gs ...');
    for j=1:nframes
        pat3(:,:,j)=pat2(:,:,pos(j));
    end
    for j=(nframes+1):(nframes+10)
        %adding 10 buffer frames
        pat3(:,:,j)=pat3(:,:,nframes);
    end
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat3;
    pattern.x_num = size(pat3,3);    % There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat3,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
    save(['pattern20_bar_x4_RW_gs' num2str(pattern.gs_val) '_n'  num2str(pattern.num_panels)], 'pattern');
    
    
    
    
    
    
    %%%%%%% pattern20_bar_x4_LW_gs %%%%%%%
    x0=289;
    x1=x0-ceil(xdis/(nGraylevel-1))*(nGraylevel-1);
    pos0=cumsum(vel);
    pos0=pos0./max(pos0);%normalization
    pos=pos0*(x1-x0)+x0;
    pos=interp1(t,pos,linspace(t(1),t(end),nframes));
    disp('making pattern20_bar_x4_LW_gs ...');
    for j=1:nframes
        pat3(:,:,j)=pat2(:,:,round(pos(j)));
    end
    for j=(nframes+1):(nframes+10)
        %adding 10 buffer frames
        pat3(:,:,j)=pat3(:,:,nframes);
    end
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat3;
    pattern.x_num = size(pat3,3);    % There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat3,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
    save(['pattern21_bar_x4_LW_gs' num2str(pattern.gs_val) '_n'  num2str(pattern.num_panels)], 'pattern');
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    %%%%%%%%%%%%%%%%%%% 1/f noise patttern %%%%%%%%%%%%%%%%%%%%%%%
    
    %simple test of the 1/f noise generation algorithm
    len=1000;
    f=2:.5:(len/2);%number of period in the fullwidth -- 80 is the nyquist rate of full width
    randvec=zeros(1,len);
    for i=1:length(f)
        phase=rand(1,1)*len;
        xi=sin(2*pi*f(i)*(phase+(1:len))/len);
        randvec=randvec+xi/(f(i)^1);%weighted by 1/f(i)^1
    end
    figure(23094);clf;subplot(211);plot(randvec);
    subplot(212);psd(randvec);set(gca,'XScale','log','XLim',[0.008 1]);
    
    
    %%%%%%%%%%%%%%% gray scale 1/f vertical stripes  -- version1 %%%%%%%%%%%
    nGraylevel=7;%this is very important to achieve 1000 deg/s speed without jumping pixels
    pattern.row_compression=1;
    height=arenaheight/8;%because the row compression
    maxvel=(1000/2.25)*(nGraylevel-1);%unit:xpos with nGrayLevel=5
    xdis=(maxvel*dt)*sum(vel);%displacement of xpos in 50 ms
    
    %compose a 1/f vector
    f=5:.1:80;%number of period in the fullwidth -- 80 is the nyquist rate of full width
    bRenew=true;
    randvec=zeros(1,fullwidth);
    for i=1:length(f)
        phase=rand(1,1)*fullwidth;
        xi=sin(2*pi*f(i)*(phase+(1:fullwidth))/fullwidth);
        randvec=randvec+xi/(f(i)^1);%weighted by 1/f(i)^1
    end
    
    %normalize random vector    
    tmp=sort(randvec);
    threshold=tmp(round(length(tmp)*.1));%20% of the cdf 
    randvec(randvec<threshold)=threshold;
    randvec=(randvec-min(randvec))/(max(randvec)-min(randvec));
    
    figure(230942);clf;plot(randvec);
    
    %compose the initial pattern (pat1)
    pat1=repmat(randvec*(nGraylevel-1),height,1);
    
    %compose the full pattern
    pat=zeros(height,fullwidth,fullwidth*(nGraylevel-1));
    for j=1:size(pat,3)
        pat(:,:,j)=ShiftMatrix2(pat1,(j-1)/(nGraylevel-1),'r','y');
    end
    
    %trim patterns for 12/20 panels
    pat2=round(pat);
    
    
    %%% pattern21_1overF_RW_gs %%%
    x0=200;
    x1=x0+ceil(xdis/(nGraylevel-1))*(nGraylevel-1);
    pos0=cumsum(vel);
    pos0=pos0./max(pos0);%normalization
    pos=pos0*(x1-x0)+x0;
    pos=interp1(t,pos,linspace(t(1),t(end),nframes));
    disp('making pattern10_1overF_RW_gs ...');
    for j=1:nframes
        pat3(:,:,j)=pat2(:,:,round(pos(j)));
    end
    for j=(nframes+1):(nframes+10)
        %adding 10 buffer frames
        pat3(:,:,j)=pat3(:,:,nframes);
    end
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat3;
    pattern.x_num = size(pat3,3);    % There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat3,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
%     save(['pattern22_1overF_RW_v1_gs' num2str(pattern.gs_val) '_n'  num2str(pattern.num_panels)], 'pattern');
    
    
    
    
    
    %%% pattern22_1overF_LW_gs %%%
    x0=pos(end);%start from the end point of the last plot..
    x1=x0-ceil(xdis/(nGraylevel-1))*(nGraylevel-1);
    pos0=cumsum(vel);
    pos0=pos0./max(pos0);%normalization
    pos=pos0*(x1-x0)+x0;
    pos=interp1(t,pos,linspace(t(1),t(end),nframes));
    disp('making pattern22_1overF_LW_gs ...');
    for j=1:nframes
        pat3(:,:,j)=pat2(:,:,round(pos(j)));
    end
    for j=(nframes+1):(nframes+10)
        %adding 10 buffer frames
        pat3(:,:,j)=pat3(:,:,nframes);
    end
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat3;
    pattern.x_num = size(pat3,3);    % There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat3,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
%      save(['pattern23_1overF_LW_v1_gs' num2str(pattern.gs_val) '_n'  num2str(pattern.num_panels)], 'pattern');
    
    
    
     
     
     
     
   

    %%%%%%%%%%%%%%% gray scale 1/f vertical stripes  -- version2 %%%%%%%%%%%
    nGraylevel=7;%this is very important to achieve 1000 deg/s speed without jumping pixels
    pattern.row_compression=1;
    height=arenaheight/8;%because the row compression
    maxvel=(1000/2.25)*(nGraylevel-1);%unit:xpos with nGrayLevel=5
    xdis=(maxvel*dt)*sum(vel);%displacement of xpos in 50 ms
    
    %compose a 1/f vector
    f=5:.1:80;%number of period in the fullwidth -- 80 is the nyquist rate of full width
    bRenew=true;
    randvec=zeros(1,fullwidth);
    for i=1:length(f)
        phase=rand(1,1)*fullwidth;
        xi=sin(2*pi*f(i)*(phase+(1:fullwidth))/fullwidth);
        randvec=randvec+xi/(f(i)^1);%weighted by 1/f(i)^1
    end
    
    %normalize random vector    
    tmp=sort(randvec);
    randvec=(randvec-min(randvec))/(max(randvec)-min(randvec));
    randvec(randvec<0.1)=0.1;
    
    figure(230942);clf;plot(randvec);
    %compose the initial pattern (pat1)
    pat1=repmat(randvec*(nGraylevel-1),height,1);
    
    %compose the full pattern
    pat=zeros(height,fullwidth,fullwidth*(nGraylevel-1));
    for j=1:size(pat,3)
        pat(:,:,j)=ShiftMatrix2(pat1,(j-1)/(nGraylevel-1),'r','y');
    end
    
    %trim patterns for 12/20 panels
%     x_subset = 1:96; %this gives one area with no spot = all 4, then shows one pixel
%     panel_subset = 1:(400+buffer_frames);
%     pat2=pat(:,:,panel_subset);
    pat2=round(pat);
    
    
    %%% pattern42_1overF_RW_gs %%%
    x0=200;
    x1=x0+ceil(xdis/(nGraylevel-1))*(nGraylevel-1);
    pos0=cumsum(vel);
    pos0=pos0./max(pos0);%normalization
    pos=pos0*(x1-x0)+x0;
    pos=interp1(t,pos,linspace(t(1),t(end),nframes));
    disp('making pattern23_1overF_RW_v2_gs ...');
    for j=1:nframes
        pat3(:,:,j)=pat2(:,:,round(pos(j)));
    end
    for j=(nframes+1):(nframes+10)
        %adding 10 buffer frames
        pat3(:,:,j)=pat3(:,:,nframes);
    end
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat3;
    pattern.x_num = size(pat3,3);    % There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat3,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
%     save(['pattern24_1overF_RW_v2_gs' num2str(pattern.gs_val) '_n'  num2str(pattern.num_panels)], 'pattern');
    
    
    
    %%% pattern43_1overF_LW_gs %%%
    x0=pos(end);%start from the end point of the last plot..
    x1=x0-ceil(xdis/(nGraylevel-1))*(nGraylevel-1);
    pos0=cumsum(vel);
    pos0=pos0./max(pos0);%normalization
    pos=pos0*(x1-x0)+x0;
    pos=interp1(t,pos,linspace(t(1),t(end),nframes));
    disp('making pattern24_1overF_LW_v2_gs ...');
    for j=1:nframes
        pat3(:,:,j)=pat2(:,:,round(pos(j)));
    end
    for j=(nframes+1):(nframes+10)
        %adding 10 buffer frames
        pat3(:,:,j)=pat3(:,:,nframes);
    end
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat3;
    pattern.x_num = size(pat3,3);    % There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat3,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
%     save(['pattern25_1overF_LW_v2_gs' num2str(pattern.gs_val) '_n'  num2str(pattern.num_panels)], 'pattern');
    
    
    
    
    
    

   

    %%%%%%%%%%%%%%% gray scale 1/f vertical stripes  -- version3 %%%%%%%%%%%
    nGraylevel=7;%this is very important to achieve 1000 deg/s speed without jumping pixels
    pattern.row_compression=1;
    height=arenaheight/8;%because the row compression
    maxvel=(1000/2.25)*(nGraylevel-1);%unit:xpos with nGrayLevel=5
    xdis=(maxvel*dt)*sum(vel);%displacement of xpos in 50 ms
    
    %compose a 1/f vector
    f=5:.1:80;%number of period in the fullwidth -- 80 is the nyquist rate of full width
    bRenew=true;
    randvec=zeros(1,fullwidth);
    for i=1:length(f)
        phase=rand(1,1)*fullwidth;
        xi=sin(2*pi*f(i)*(phase+(1:fullwidth))/fullwidth);
        randvec=randvec+xi/(f(i)^1);%weighted by 1/f(i)^1
    end
    
    %normalize random vector    
    tmp=sort(randvec);
    randvec=(randvec-min(randvec))/(max(randvec)-min(randvec));
    randvec(randvec<0.4)=0.4;
    
    
    figure(230942);clf;plot(randvec);
    
    %compose the initial pattern (pat1)
    pat1=repmat(randvec*(nGraylevel-1),height,1);
    
    %compose the full pattern
    pat=zeros(height,fullwidth,fullwidth*(nGraylevel-1));
    for j=1:size(pat,3)
        pat(:,:,j)=ShiftMatrix2(pat1,(j-1)/(nGraylevel-1),'r','y');
    end
    
    %trim patterns for 12/20 panels
%     x_subset = 1:96; %this gives one area with no spot = all 4, then shows one pixel
%     panel_subset = 1:(400+buffer_frames);
%     pat2=pat(:,:,panel_subset);
    pat2=round(pat);
    
    
    %%% pattern42_1overF_RW_gs %%%
    x0=200;
    x1=x0+ceil(xdis/(nGraylevel-1))*(nGraylevel-1);
    pos0=cumsum(vel);
    pos0=pos0./max(pos0);%normalization
    pos=pos0*(x1-x0)+x0;
    pos=interp1(t,pos,linspace(t(1),t(end),nframes));
    disp('making pattern25_1overF_RW_v3_gs ...');
    for j=1:nframes
        pat3(:,:,j)=pat2(:,:,round(pos(j)));
    end
    for j=(nframes+1):(nframes+10)
        %adding 10 buffer frames
        pat3(:,:,j)=pat3(:,:,nframes);
    end
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat3;
    pattern.x_num = size(pat3,3);    % There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat3,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
%      save(['pattern26_1overF_RW_v3_gs' num2str(pattern.gs_val) '_n'  num2str(pattern.num_panels)], 'pattern');
    
    
    
    %%% pattern43_1overF_LW_gs %%%
    x0=pos(end);%start from the end point of the last plot..
    x1=x0-ceil(xdis/(nGraylevel-1))*(nGraylevel-1);
    pos0=cumsum(vel);
    pos0=pos0./max(pos0);%normalization
    pos=pos0*(x1-x0)+x0;
    pos=interp1(t,pos,linspace(t(1),t(end),nframes));
    disp('making pattern26_1overF_LW_v3_gs ...');
    for j=1:nframes
        pat3(:,:,j)=pat2(:,:,round(pos(j)));
    end
    for j=(nframes+1):(nframes+10)
        %adding 10 buffer frames
        pat3(:,:,j)=pat3(:,:,nframes);
    end
    %convert the pattern array for each panel based on the pattern map
    pattern.Pats=pat3;
    pattern.x_num = size(pat3,3);    % There are 96 pixel around the display (12x8)
    pattern.y_num = size(pat3,4);
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = make_pattern_vector_ak(pattern);
    pattern.Pats=int8(pattern.Pats);
%     save(['pattern27_1overF_LW_v3_gs' num2str(pattern.gs_val) '_n'  num2str(pattern.num_panels)], 'pattern');
    
















    
end










%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%===================== Small Utility Functions ===================
%=================================================================
%=================================================================
%=================================================================
%=================================================================
%=================================================================



function [xperiod yperiod]=findperiods(pattern)
for i=1:size(pattern,2)
    diff0=pattern-circshift(pattern,[0 i]);
    if(sum(abs(diff0(:)))==0)
        break;
    end
end


for j=1:size(pattern,1)
    diff0=pattern-circshift(pattern,[j 0]);
    sum(abs(diff0(:)));
    if(sum(abs(diff0(:)))==0)
        break;
    end
end

xperiod=i;
yperiod=j;



function PatternOut = ShiftMatrix2(PatternIn, Nshift0, dir, wrap)
% PatternOut = ShiftMatrix2(PatternIn, Nshift, dir, wrap)
% Shift the data in a pattern matrix in direction given by dir: 'r', 'l',
% 'u', 'd'. Nshift specifies the shift size, 1 is just one row or column, etc.
% The pattern will be wrapped if wrap is 'y' or not if it is set to the value
% of wrap, e.g 0 or 1.

% Anmo Kim
% 7/14/2011
% based on ShiftMatrix()
% allows for the dithering - NShift can have below-zero decimal points


[numR, numC] = size(PatternIn);
PatternOut = PatternIn;   %to initialize, set the output M equal to the input M

Nshift=floor(Nshift0);
DitheringLevel=Nshift0-Nshift;%the level of dithering


switch dir
    %edited by Anmo to support dithering
    case 'r'
        PatternOut= PatternIn(:,[(end-Nshift+1):end 1:(end-Nshift)])*(1-DitheringLevel)+...
            PatternIn(:,[(end-Nshift):end 1:(end-Nshift-1)])*DitheringLevel;
        
        if wrap ~= 'y'
            PatternOut(:,1:Nshift) = repmat(0, numR ,Nshift);
        end
    case 'l'
        PatternOut= PatternIn(:,[(Nshift+1):end 1:Nshift])*(1-DitheringLevel)+...
            PatternIn(:,[(Nshift+2):end 1:(Nshift+1)])*DitheringLevel;
        if wrap ~= 'y'
            PatternOut(:,end-Nshift+1:end) = repmat(0, numR ,Nshift);
        end
    case 'u'
        PatternOut= PatternIn([(Nshift+1):end 1:Nshift],:)*(1-DitheringLevel)+...
            PatternIn([(Nshift+2):end 1:(Nshift+1)],:)*DitheringLevel;
        if wrap ~= 'y'
            PatternOut(end-Nshift+1:end,:) = repmat(0, Nshift, numC);
        end
    case 'd'
        PatternOut= PatternIn([(end-Nshift+1):end 1:(end-Nshift)],:)*(1-DitheringLevel)+...
            PatternIn([(end-Nshift):end 1:(end-Nshift-1)],:)*DitheringLevel;
        if wrap ~= 'y'
            PatternOut(1:Nshift,:) = repmat(0, Nshift, numC);
        end
    otherwise
        error('invalid shift direction, must be r, l, u, or d')
end






function [BitMapIndex] = process_panel_map(pattern)
% takes an argument like [1 2 3 4; 5 6 7 8] to define a tilling by 8 panels
% of a 2x4 grid of panels.
% if there is a zero term, as in [1 2 3 0; 5 6 7 8], then this signifies a
% dummy panel for which no data will be sent out & patterns won't be
% computed.
% Returns a structure BitMapIndex of length = number of defined panel_IDs
% has 3 fields: Panel_ID, row_range, and column_range.

Panel_map = pattern.Panel_map;
[ n_Panels_inRow, n_Panels_inColumn ] = size(Panel_map);
% bitmap pattern must be size [8*n_Panels_inRow, 8*n_Panels_inColumn];

% determine if row_compression is on
row_compression = 0;
if isfield(pattern, 'row_compression') % for backward compatibility
    if (pattern.row_compression)
        row_compression = 1;
    end
end

Sorted_indices = sort(Panel_map(:));
GT_zero = find(Sorted_indices);
min_pan_index = GT_zero(1);
Non_zero_indices = Sorted_indices(min_pan_index:end);
if (length(unique(Non_zero_indices)) ~= length(Non_zero_indices))   % this means there are repeated panel IDs
    error([' There are multiple panels defined with the same panel ID.' char(13) ...
        ' The logic this program uses to parse patterns to the panels is not appropriate for this case!']);
end

% only search over the list of sorted indices that are non_zero
for i = 1:length(Non_zero_indices)
    Pan_ID = Non_zero_indices(i);
    [I,J] = find(Panel_map == Pan_ID);
    if (isempty(I))
        error('something funny here, this index should be in the Panel_map');
    else
        BitMapIndex(i).Panel_ID = Pan_ID;
        if (row_compression)
            BitMapIndex(i).row_range = ((I-1)+1):I;
        else
            BitMapIndex(i).row_range = ((I-1)*8+1):I*8;
        end
        BitMapIndex(i).column_range = ((J-1)*8+1):J*8;
    end
end







function pat_vector = make_pattern_vector_ak(pattern)
% relevant fields of pattern are - Pats, BitMapIndex, gs_val
% converts a Pats file of size (L,M,N,O), where L is the number of rows, 8
% per panel, M is the number of columns, 8 per panel, N is the number of
% frames in the 'x' dimmension, and O is the number of frames in the 'y' dimmension
% to an array of size L/8, M/8, N*O stored as: Pannel, Frame, PatternData
% here we flatten the 2D pattern array to a 1 D array using the formula
% Pattern_number = (index_y - 1)*N + index_x;

%edited by Anmo Kim on 9/20/2011 to improve the speed

Pats = round(pattern.Pats);
BitMapIndex = pattern.BitMapIndex;
gs_val = pattern.gs_val;

if(~all(~isnan(Pats)))
    error('make_pattern_vector_ak: NaN value found in pattern matrix');
end

if (gs_val > 4)
    error('gs_val = 1-4 cases are supported!');
end

% first we do some error checking
if (gs_val<1 || gs_val>4)
    error('gs_val must be 1, 2, 3, or 4');
end

if ( (gs_val == 1) && ~all(Pats(:)>=0 & Pats(:)<=1) )
    error('For gs 1, Pats can contain only 0 or 1');
    
    
elseif ( (gs_val == 2) && ~all(Pats(:)>=0 & Pats(:)<=3) )
    error('For gs 2, Pats can contain only 0, 1, 2, or 3');
elseif ( (gs_val == 3) && ~all(Pats(:)>=0 & Pats(:)<=7) )
    error('For gs 3, Pats can contain only 0-7');
end

if ( (gs_val == 4) && ~all(Pats(:)>=0 & Pats(:)<=15) )
    error('For gs 4, Pats can contain only 0-15');
end

% determine if row_compression is on
row_compression = 0;
if isfield(pattern, 'row_compression') % for backward compatibility
    if (pattern.row_compression)
        row_compression = 1;
    end
end

[PatR, PatC, NumPatsX, NumPatsY] = size(Pats);

NumPats = NumPatsX*NumPatsY;   %total number of panels
numCol = PatC/8;

NumPanels = length(BitMapIndex);   % this count includes virtual panels too, ones with flag = 0
if (row_compression)
    pat_matrix = zeros(NumPanels*NumPats, 1*gs_val);
else
    pat_matrix = zeros(NumPanels*NumPats, 8*gs_val);
end

progress=0;lastprogress=0;
fprintf(1,'make_pattern_vector_ak:       ');
for index_x = 1:NumPatsX
    for index_y = 1:NumPatsY
        progress=(index_y+(index_x-1)*NumPatsY)/NumPatsY/NumPatsX*100;
        if(floor(lastprogress)<floor(progress))
            fprintf(1, '\b\b\b\b\b\b%04.1f%% ', round(progress));
        end
        lastprogress=progress;
        
        %compute the pattern_number:
        Pattern_number = (index_y - 1)*NumPatsX + index_x;
        twos = pow2(0:7);
        twosn= pow2(7:-1:0);
        for i = 1:NumPanels
            % capture the panel bitmap for frame Pattern_number and panel i
            PanMat = Pats(BitMapIndex(i).row_range, BitMapIndex(i).column_range, index_x, index_y);
            
            
            if (row_compression)
                if (gs_val == 1)
                    frame_pat(i) = twos*PanMat';
                    %                     frame_pat(i) = vec2dec_fast_ak(PanMat, gs_val);
                else % only support the gs_val <= 4 case
                    if (gs_val > 4)
                        error('gs_val = 1-4 cases are supported!');
                    end
                    %vec2dec_fast_ak
                    binvec=double(dec2bin(PanMat',gs_val)-'0');
                    frame_pat(i,1:gs_val)=twos*binvec;
                    
                end  % if/else gs_val
            else
                % code below is perfectly general - just treat gs = 1, separately to speed up.
                if (gs_val == 1)
                    %frame_pat(i,k) = (binvec2dec(PanMat(:,k)'));
                    frame_pat(i,:) = twos*PanMat;
                    
                    %                     for k = 1:8
                    %                         frame_pat(i,k) = vec2dec_fast_ak(PanMat(:,k)',gs_val);
                    %                     end
                    
                else
                    
                    %                     for k = 1:8
                    %                         binvec=double(dec2bin(PanMat(:,k)',3)-'0');
                    %                         frame_pat(i,k + (8*((1:gs_val)-1)))=twos*binvec;
                    %                     end
                    if(sum(PanMat(:))==0)
                        %if all off
                        frame_pat(i,:)=zeros(1,8*gs_val);
                    elseif(sum(PanMat(:))/(2^gs_val-1)==numel(PanMat))
                        %if all on
                        frame_pat(i,:)=255*ones(1,8*gs_val);
                    else
                        %if mixed
                        binvec=double(dec2bin(PanMat(:)',gs_val)-'0');
                        binvec2=reshape(binvec,8,numel(binvec)/8);
                        
                        frame_pat(i,:)=twos*binvec2;
                    end
                    %                     for k = 1:8
                    %                         frame_pat(i,k + (8*((1:gs_val)-1)))=twos*binvec((k-1)*8+(1:8),:);
                    %                     end
                    
                    
                    %                         for k = 1:8
                    %                             out = vec2dec_fast_ak(PanMat(:,k)', gs_val);
                    %                             for num_g = 1:gs_val
                    %                                 frame_pat(i,k + (8*(num_g-1))) = out(num_g);
                    %                             end % for
                    %                         end
                    
                end %if/else gs_val
                
            end % if/else row_compression
        end
        pat_start_index = (Pattern_number - 1)*NumPanels + 1;
        pat_matrix(pat_start_index:pat_start_index + NumPanels - 1, :) = frame_pat;
    end
end
fprintf(1,'\n');

% rearrange the data so we can read this as columnwise vector data -
temp_matrix = pat_matrix';
pat_vector = temp_matrix(:);



function out = vec2dec_fast_ak(vec, gs)
% BINvec2dec_fast_ak Convert binary vector to decimal number fast.
%
%    BINvec2dec_fast_ak(B, gs) interprets the vector B and returns the
%    equivalent decimal number.  The least significant bit is
%    represented by the first column.
%
%
%    Note: The vector cannot exceed 52 values.
%
%    Example:
%       vec2dec_fast_ak([1 1 1 0 1],1) returns 23
%
%jinyang liu
%touched by anmo on 9/20/2011

% Error if vec is not defined.
if isempty(vec)
    error('daq:binvec2dec:argcheck', 'B must be defined.  Type ''daqhelp binvec2dec'' for more information.');
end


% Error if vec is not a double.
% if (~isa(vec, 'double') | ( any(vec > (2^(gs)-1)) | any(vec < 0) ) )
%    error('B must be a gsvec, 0 - 2^(gs)-1');
% end

if gs~= 1
    %     for j = 1:length(vec)
    %         %binvec(j,:) = dec2bin(vec(j),gs);
    %         d = vec(j);
    %         [f,e]=log2(max(d));
    %         binvec(j,:) = rem(floor(d*pow2(1-max(gs,e):0)),2);
    %     end
    
    binvec=double(dec2bin(vec',3)-'0');
    twos = pow2(0:(2^gs-1));
    out=twos*binvec;
    
else
    % Convert the binvec [0 0 1 1] to a binary string '1100';
    h = fliplr(vec);
    
    % Convert the binary string to a decimal number.
    
    [m,n] = size(h);
    
    % Convert to numbers
    twos = pow2(n-1:-1:0);
    
    out = twos*h';
    
end






function pat_vector = make_pattern_vector(pattern)
% relevant fields of pattern are - Pats, BitMapIndex, gs_val
% converts a Pats file of size (L,M,N,O), where L is the number of rows, 8
% per panel, M is the number of columns, 8 per panel, N is the number of
% frames in the 'x' dimmension, and O is the number of frames in the 'y' dimmension
% to an array of size L/8, M/8, N*O stored as: Pannel, Frame, PatternData 
% here we flatten the 2D pattern array to a 1 D array using the formula 
% Pattern_number = (index_y - 1)*N + index_x;

Pats = pattern.Pats; 
BitMapIndex = pattern.BitMapIndex; 
gs_val = pattern.gs_val;

% first we do some error checking
if (~( (gs_val == 1) | (gs_val == 2) | (gs_val == 3) | (gs_val == 4) ))
    error('gs_val must be 1, 2, 3, or 4');
end

if ( (gs_val == 1) & (~all( (Pats(:) == 0) | (Pats(:) == 1) ) ) )
        error('For gs 1, Pats can contain only 0 or 1');
end

if ( (gs_val == 2)& (~all((Pats(:) == 0) | (Pats(:) == 1) | (Pats(:) == 2) | (Pats(:) == 3) ) ) )
        error('For gs 2, Pats can contain only 0, 1, 2, or 3');
end

if ( (gs_val == 3) & (~all((Pats(:) == 0) | (Pats(:) == 1) | (Pats(:) == 2) ...
        | (Pats(:) == 3) | (Pats(:) == 4) | (Pats(:) == 5) | (Pats(:) == 6) | (Pats(:) == 7) ) ) )
        error('For gs 3, Pats can contain only 0, 1, 2, 3, 4, 5, 6, or 7');
end

if ( (gs_val == 4) & (~all((Pats(:) == 0) | (Pats(:) == 1) | (Pats(:) == 2) ...
        | (Pats(:) == 3) | (Pats(:) == 4) | (Pats(:) == 5) | (Pats(:) == 6) | (Pats(:) == 7)...
        | (Pats(:) == 8) | (Pats(:) == 9) | (Pats(:) == 10) | (Pats(:) == 11) | (Pats(:) == 12)...
        | (Pats(:) == 13) | (Pats(:) == 14) | (Pats(:) == 15) ) ) )
        error('For gs 4, Pats can contain only 0-15');
end

% determine if row_compression is on  
row_compression = 0;
if isfield(pattern, 'row_compression') % for backward compatibility
    if (pattern.row_compression)
        row_compression = 1;
    end
end

[PatR, PatC, NumPatsX, NumPatsY] = size(Pats);

NumPats = NumPatsX*NumPatsY;   %total number of panels
numCol = PatC/8;

NumPanels = length(BitMapIndex);   % this count includes virtual panels too, ones with flag = 0
if (row_compression)
    pat_matrix = zeros(NumPanels*NumPats, 1*gs_val);
else    
    pat_matrix = zeros(NumPanels*NumPats, 8*gs_val);
end    

for index_x = 1:NumPatsX
        for index_y = 1:NumPatsY
%             [ index_x index_y ]
            %compute the pattern_number:
            Pattern_number = (index_y - 1)*NumPatsX + index_x;
            for i = 1:NumPanels
                % capture the panel bitmap for frame Pattern_number and panel i
                PanMat = Pats(BitMapIndex(i).row_range, BitMapIndex(i).column_range, index_x, index_y);
                if (row_compression)
                    if (gs_val == 1)
                        frame_pat(i) = vec2dec_fast(PanMat, gs_val);  
                    else % only support the gs_val <= 4 case
                        if (gs_val > 4)
                            error('gs_val = 1-4 cases are supported!');
                        end
                        out = vec2dec_fast(PanMat, gs_val);
                        for num_g = 1:gs_val
                            frame_pat(i,num_g) = out(num_g);
                        end % for                        
                    end  % if/else gs_val                    
                else    
                    for k = 1:8
                        % code below is perfectly general - just treat gs = 1, separately to speed up.
                        if (gs_val == 1)
                            %frame_pat(i,k) = (binvec2dec(PanMat(:,k)'));                        
                            frame_pat(i,k) = vec2dec_fast(PanMat(:,k)',gs_val);                        
                        else
                            if (gs_val > 4)
                                error('gs_val = 1-4 cases are supported!');
                            end    
                            out = vec2dec_fast(PanMat(:,k)', gs_val);
                            for num_g = 1:gs_val
                                frame_pat(i,k + (8*(num_g-1))) = out(num_g);
                            end % for
                        end %if/else gs_val
                    end % for
                end % if/else row_compression
            end                        
            pat_start_index = (Pattern_number - 1)*NumPanels + 1;
            pat_matrix(pat_start_index:pat_start_index + NumPanels - 1, :) = frame_pat;
        end    
end

% rearrange the data so we can read this as columnwise vector data - 
temp_matrix = pat_matrix';
pat_vector = temp_matrix(:);

function out = vec2dec_fast(vec, gs)
% VEC2DEC_FAST Convert binary vector to decimal number fast.
%
%    VEC2DEC(B) interprets the binary vector B and returns the
%    equivalent decimal number.  The least significant bit is 
%    represented by the first column.
%
%    Non-zero values will be mapped to 1, e.g. [1 2 3 0] maps
%    to [1 1 1 0].
% 
%    Note: The binary vector cannot exceed 52 values.
%
%    Example:
%       vec2dec_fast([1 1 1 0 1],1) returns 23
%



% Error if vec is not defined.
if isempty(vec)
   error('daq:vec2dec:argcheck', 'B must be defined.  Type ''daqhelp binvec2dec'' for more information.');
end

% Error if vec is not a double.
if (~isa(vec, 'double') | ( any(vec > (2^(gs)-1)) | any(vec < 0) ) )
   error('B must be a gsvec, 0 - 2^(gs)-1');
end

if gs~= 1
    for j = 1:length(vec)
        %binvec(j,:) = dec2bin(vec(j),gs);
        d = vec(j);
        n = round(double(gs));
        [~,e]=log2(max(d));
        binvec(j,:) = rem(floor(d*pow2(1-max(n,e):0)),2);
    end
    
    % Convert the binary string to a decimal number.
    
    n=length(vec);
    
    % Convert to numbers
    twos = pow2(n-1:-1:0);
    
    % then just turn each binvec into a dec value
    for j = 1:gs
        out(j) = twos*flipud(binvec(:,j));
    end
    
else
    % Convert the binvec [0 0 1 1] to a binary string '1100';
    h = fliplr(vec);
    
    % Convert the binary string to a decimal number.
    
    [m,n] = size(h);
    
    % Convert to numbers
    twos = pow2(n-1:-1:0);
    
    out = twos*h';

end