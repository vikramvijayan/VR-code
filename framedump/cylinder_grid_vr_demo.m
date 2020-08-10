function cylinder_grid_vr_demo

    fig = figure;

    % initial values
    x = 0;
    y = -20;
    theta = pi/2;

    subplot(3,1,1)
    
    ax_view = imshow(cylinder_grid_framedump(x, y, theta));
    title('View');

    subplot(3,1,2)
    ax_coord = plot(x,y, 'o', 0, 0, 'o');
    xlim([-20, 20]);
    ylim([-20, 20]);
    title('Position')

    subplot(3,1,3);
    ax_ang = compass(cos(theta), sin(theta));
    %set interactive bit
    set(fig, 'KeyPressFcn', @keyDownListener)

    function keyDownListener(src, event)
        increment_y = 0.1;
        increment_theta = pi/180;

        switch event.Key
            case 'w'
                y = y + increment_y;
            case 's'
                y = y - increment_y;
            case 'a'
                x = x - increment_y;
            case 'd'
                x = x + increment_y;
            case 'q'
                theta = theta + increment_theta;
            case 'e'
                theta = theta - increment_theta;
        end

        set(ax_view, 'CData', cylinder_grid_framedump(x, y, theta));
        set(ax_coord, 'XData', [x, 0]);
        set(ax_coord, 'YData', [y, 0]);
        ax_ang = compass(cos(theta), sin(theta));
    end
end