function img = simple_cylinder_vr(x, y, theta, xc, yc, dia,...
                                  panels_x, panels_y, draw_dist)
%
%
%:param x:  x position of fly
%:param y:  y position of fly
%:param theta:  angle of fly measured from x axis (ie looking down the
%               axis) measured in radians
%:param xc:  x position of the cylinder
%:param yc:  y position of the cylinder
%:param panels_x:  number of panels in the x direction (width)
%:param panels_y:  number of panels in the y direction (height)
%:param draw_dist:  distance at which the cylinder is no longer drawn
%
%This code assumes a standard right handed cartesian coordinate system.
%All units are in mm (which doesn't really matter as they cancel).  If only
%three arguments are passed it is assumed that the post is located at 
%(0, 0), is considered infinitely tall. and is 100mm wide.

    if(nargin == 3)
        xc = 0;
        yc = 0;
        dia = 100;
        panels_x = 12;
        panels_y = 5;
        draw_dist = 5;
    end

    %parameters of the arena
    ledPerDim = 8;
    ledx = panels_x * ledPerDim;
    ledy = panels_y * ledPerDim;

    %simple calc of location
    d = sqrt((xc - x)^2 + (yc - y)^2);  % distance of fly to the cylinder

    %draw distance boundary (if to far away don't draw it)
    if(d > draw_dist)
        img = zeros(ledy, ledx);
    else
    %otherwise, continue the calculations
        %protect from divide by 0
        if(d == 0)
            w=ledx;  % max out
        else
            w = round(dia * (1/d));  % new width of the cylinder
            if(w>ledx)
                w=ledx;  % cap max size
            end
        end
        
        pix_ang_ratio = ledx/(2*pi);  % conversion of angle to led position

        alpha = atan2(y-yc, x-xc);  % angle made between global origin and coorrdinate origin

        %ang = (pi/2) - theta;  % angle offset since theta=0 is looking away down x-axis
        ang = alpha - theta;
        ang = round(pix_ang_ratio * ang);  % downsampling the angle to led position
        ang = -1 * ang;  % closed loop so if I turn right the image moves left

        % build the image
        prepost = round((ledx - w)/2);

        %safety for rounding so we don't get an image that is to big
        if(rem(((ledx-w)/2), 1) > 0)
            prepost= prepost-1;
        end

        img = cat(2, zeros(ledy, prepost), ones(ledy, w), zeros(ledy, prepost));

        %safety for rouding so we don't get an image that is to small (when w = 1)
        if(ledx - size(img,2) == 1)
            img = cat(2, img, zeros(ledy, 1));
        end

        img = circshift(img, round(pix_ang_ratio*pi), 2);  %check math as to why necessary
        img = circshift(img, ang, 2);
    end
end


