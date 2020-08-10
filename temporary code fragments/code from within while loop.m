%while s.IsRunning

%    counter = counter+1;

%   if(counter == 60*plot_speed)
%      trial_id = 1;
%space_map = get_world(40, world_size);
%        space_map = get_world(8, world_size);
%       draw_map.CData = space_map;

%delete(draw_map);
%set(FigA,'CurrentAxes',plot_axes_hnd);
%draw_map = imagesc([.5, length(space_map)-.5], [.5, length(space_map)-.5], transpose(space_map));
%alpha .5
%   end

%     % for open loop control
%     if(visual_display == 0)
%         [current_pattern_id, current_openloop_mode] = open_loop_control(cnt, plot_speed, open_loop_display_gain, current_openloop_mode);
%         cnt = cnt+1;
%         visdisplay_string = pad_zeros_for_pattern(current_pattern_id);
%         filep = load(['C:\Users\maimonlab\Desktop\Vikram\current code for VR\patterns_24panel\' visdisplay_string],'pattern');
%         set(FigA,'CurrentAxes',display_axes_hnd);
%         hold on;
%         [rows, cols, ~] = size(filep.pattern.Pats);
%         gs_val = filep.pattern.gs_val;
%         [sx,sy,sz] = cylinder(rows,cols);
%         tmp_pat = [];
%         tmp_pat(:,:,1) = zeros(rows,cols);
%         if(pattern_xnum == -1)
%             tmp_pat(:,:,2) = flipud(filep.pattern.Pats(:,:,1));
%         end
%         if(pattern_xnum > -1)
%             tmp_pat(:,:,2) = flipud(filep.pattern.Pats(:,:,mod(round(pattern_xnum/10*filep.pattern.x_num),filep.pattern.x_num)+1));
%         end
%         tmp_pat(:,:,3) = zeros(rows,cols);
%         warp(sx,sy,sz, tmp_pat./((2^gs_val)-1),visual_display_cmap);
%         view([-179.4, 87]);
%
%         % the commented code is if you don't want the pattern to move in
%         % open loop mode
%         %         tmp_pat(:,:,1) = zeros(rows,cols);
%         %         tmp_pat(:,:,2) = flipud(filep.pattern.Pats(:,:,1));
%         %         tmp_pat(:,:,3) = zeros(rows,cols);
%         %         warp(sx,sy,sz, tmp_pat./((2^gs_val)-1),visual_display_cmap);
%         %         view([-179.4, 87]);
%     end
%
%
%     pause(1/plot_speed)
% end
