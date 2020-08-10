function data = bmp2array(img, map)
%BMP2ARRAY(IMG) converts a bitmap image into an array for frame dumping
%
%IMG should be a bit map gray scale image w/ a max bitdepth of 4 lvls and a
%pixel size exactly equal to the number of individual LED's on your panel
%display.  Recall, each panel is an 8 by 8 array of LED's
%
%MAP should be a matrix of each pannel's address
%
%Example:  You have an arena that is 5 panels tall and 12 panels wide, 
%
%  Height = 40 <- (8*5)
%  Width = 96 <- (8*12)
%
%Images can be easily created in a free drawing program like GIMP

    %----------------------------------------------------
    %sanitation checks
    %check to make sure the image is the correct size
    
    %check the dimensions of the image matrix, if not depth 1, extract
%     if(length(size(img)) > 2)
%         img = img(:,:,1);
%     end
    %-----------------------------------------------------
    nPanels = numel(map);
    lookup = kron(map, ones(8));
    glvls = unique(img);
    
    % if we have more than than all on, drop all off level (it
    % is assumed)
    if(length(glvls) == 1 && glvls(1) == 255)
    else
        glvls = glvls(2:end);  % drop the black lvl
    end
    
    lvl = zeros([size(img), length(glvls)]);
    
    for i= 1:length(glvls)
        lvl(:,:,i) = img == glvls(i);
    end
    
    ind = 1;
    data = zeros(1, nPanels * 8);
    
    % grab the block of pixels that correspond to a panel
    for j = 1:nPanels
        % for each glvl
        for i = 1:length(glvls)
            single_lvl = lvl(:,:,i);
            panel = reshape(single_lvl(lookup == j), 8, 8);
            % for column in that block
            for k = 1:8  % NOTE:  CAN PASS ARRAY TO BI2DE
                col = panel(:, k);
                % convert from binary to decimal and add it to our data
                % stream
                %data(ind) = bi2de(col', 'right-msb');
                
                data(ind) =  b2d(col');
                
                ind = ind+1;
            end
        end
    end
    
%     % for each glvl
%     for i = 1:length(glvls)
%         single_lvl = lvl(:,:,i);
%         % grab the block of pixels that correspond to a panel
%         for j = 1:nPanels
%             panel = reshape(single_lvl(lookup == j), 8, 8);
%             % for column in that block
%             for k = 1:8  % NOTE:  CAN PASS ARRAY TO BI2DE
%                 col = panel(:, k);
%                 % convert from binary to decimal and add it to our data
%                 % stream
%                 data(ind) = bi2de(col', 'right-msb');
%                 ind = ind+1;
%             end
%         end
%     end
end