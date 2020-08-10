function framedump(img, map, npx, npy, x_out, y_out)
%FRAMEDUMP sends an appriopriately sized image to the Reiser Panel arena
%
%:param img:  the image you wish to send, pixel dim must match led dim
%:param map:  matrix containing address of panels
%:param npx:  number of panels in x direction (width)
%:param npy:  number of panels in the y direction (height)

nLEDsPerDim=8;

x_AO = 0;  % analog out for x channel (0 <= x_AO < 2048)
y_AO = 0;  % analog out for y channel (0 <= y_AO < 2048)
nPanels = npx * npy;  % total number of panels
glvl = 1;  % gray scale level (2^n)-1
row_cmpr = 0;  % row compression (0 or 1)
data_len = nPanels * nLEDsPerDim;  % number of number's we're sending

data = bmp2array(img, map);

% Panel_com('dump_frame', [data_len, x_AO, y_AO, nPanels, glvl,...
%           row_cmpr, data]);

 Panel_com('dump_frame', [data_len, x_out, y_out, nPanels, glvl,...
           row_cmpr, data]);