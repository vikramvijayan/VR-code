function img = vr_cylinder_grid(x, y, theta, cwidth, ncx, ncy, ...
                                scx, scy, npx, npy, draw_dist)
%VR_CYLINDER_GRID returns an img of a collonade from the fly's perspective
%
%:param x:  x position of fly
%:param y:  y position of fly
%:param theta:  angle of fly measured from positive X-axis
%:param cwidth:  width of columns in mm
%:param ncx:  number of columns in the x-dimension
%:param ncy:  number of columns in the y-dimension
%:param scx:  spacing between column centers in x direction
%:param scy:  spacing between column centers in y direction
%:param npx:  number of panels in the x direction
%:param npy:  number of panels in the y direction
%:param draw_dist:  max distance at which we still draw the cylinders
%
%The colonade is centerd on the world coordinate origin (0, 0).

    %constants
    ledPerDim = 8;

    ledx = npx * ledPerDim;
    ledy = npy * ledPerDim;
    pix_ang_ratio = ledx/(2*pi);  % conversion of angle to led position


    lcx = (ncx-1)*scx;  % length of the colonade in the x direction
    lcy = (ncy-1)*scy;  % length of the colonade in teh y direction
    xccoords = [0:scx:lcx];  % x coordinates for the columns
    yccoords = [0:scy:lcy];  % y coordinates for the columns

    xccoords = xccoords - (lcx/2);  % offset to center x coords
    yccoords = yccoords - (lcy/2);

    ncolumns = ncx*ncy;
    images = zeros(ledy, ledx, ncolumns);  %pre-allocate matrix to hold all images

    k = 1;
    for i=1:length(xccoords)
        for j=1:length(yccoords)
            images(:,:,k) = simple_cylinder_vr(x, y, theta,...
                                               xccoords(i), yccoords(j),...
                                               cwidth, ...
                                               npx, npy,...
                                               draw_dist);
            
            k = k+1;
        end
    end
    
    img = sum(images, 3);
    
    % any values above 1 should be forced down to 1 (saturation point)
    saturated = img > 1;
    img(saturated) = 1;
end