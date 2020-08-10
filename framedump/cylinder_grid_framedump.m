function img = cylinder_grid_framedump(x, y, theta)
%CYLINDER_GRID_FRAMEDUMP generates frames for a VR setup
%
%:param x:  x position of fly
%:param y:  y position of fly
%:param theta:  angle of fly measured from positive X-axis
%
%This function generates and sends a led pattern for a Rieser Panel arena
%that simulates a grid-like pattern of infinitely tall columns.  It takes
%as inputs the x and y positions of the fly and the heading (theta)
%measured from the positive x-axis of a right handed coordinate system.
%The grid of columns is centered about the (global) origin.
%
%To simulate a tunnel with stripes on the sides, simply generate a 2 by N
%grid.  Parameters such as number of columns in each direction, column
%width, and column spacing are all defined below.  Units cancel in the
%calculations as long as you used the same scale throughout your planning
%of the virtual environment (eg.  plan everything with mm and it will work
%out fine).

% Parameters of the virtual space
cwidth=15;  % width of each column
ncx=2;  % number of columns in the x direction
ncy=10;  % number of columns in the y direction
scx=5;  % spacing between columns in the x direction
scy=2;  % spacing of columns in the y direction
draw_dist=5;  % max distance where we still draw the column
border_x1=-10;  % top left x point of border box
border_y1=20;  % top left y point of border box
border_x2=10;  % bottom right x point of border box
border_y2=-20;  % bottom right y point of border box

% Parameters of the arena itself
% NOTE: Currently we wrap around any open spaces in the arena
npx=12;  % number of panels in the x direction
npy=4;  % number of panels in the y direction
nbus=4;
nLEDsPerDim=8;

% Generate (or load) a panel address map into your workspace
map = gen_panel_map(nbus, npx, npy);

% Generate the updated img
% If outside border, flood white
if((border_x1 < x) && (x < border_x2) && (border_y2 < y) && (y < border_y1))
    img = vr_cylinder_grid(x, y, theta, cwidth, ncx, ncy, scx, scy, npx, npy, draw_dist);
else
    img = 255*ones(npy*nLEDsPerDim, npx*nLEDsPerDim);
end

% Send the img to the arena
framedump(img, map, npx, npy);