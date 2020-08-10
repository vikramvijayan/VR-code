function simple_bar()
% this is the total number of panels supported by the arena
pattern.num_panels = 48;

% ‘1’ indicates all pixel values in pattern.Pats are binary (0 or 1)
% ‘2’ indicates all pixel values in pattern.Pats are either 0, 1, 2, or 3.
% ‘3’ indicates all pixel values in pattern.Pats fall in the range of 0-7.
% ‘4’ indicates all pixel values in pattern.Pats fall in the range of 0-15
pattern.gs_val = 3;

pattern.row_compression = 1;

% total number of patterns
nGrayLevel = 2^(pattern.gs_val);
pattern.x_num = 12*8*nGrayLevel;
% pattern.x_num = 12*8;
pattern.y_num = 1;

Pats = zeros(4, 12*8, pattern.x_num, pattern.y_num);

% InitPat = ShiftMatrix([zeros(4,41) 1.*ones(4,1) 2.*ones(4,1) 3.*ones(4,1) 4.*ones(4,1) 5.*ones(4,1) 6.*ones(4,1) 7.*ones(4,2) 6.*ones(4,1) 5.*ones(4,1) 4.*ones(4,1) 3.*ones(4,1) 2.*ones(4,1) 1.*ones(4,1) zeros(4,41)], 1, 'r', 'y');
InitPat = [zeros(4,46) ones(4,4).*7 zeros(4,46)];
Pats(:,:,1,1) = InitPat;

for j = 2:pattern.x_num
%     Pats(:,:,j,1) = ShiftMatrix(Pats(:,:,j-1,1),1, 'r', 'y');
j
     Pats(:,:,j,1)=ShiftMatrix2(InitPat,(j-1)/(nGrayLevel),'r','y');
end

  
Pats = round(Pats);
pattern.Pats = Pats;

pattern.Panel_map = [12 8 4 11 7 3 10 6 2  9 5 1;...
    24 20 16 23 19 15 22 18 14 21 17 13;...
    36 32 28 35 31 27 34 30 26 33 29 25;...
    48 44 40 47 43 39 46 42 38 45 41 37];

pattern.Pats=int8(pattern.Pats);
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = make_pattern_vector_ak(pattern);
%pattern.data = Make_pattern_vector(pattern);

%directory_name = 'C:\matlabroot\Patterns';
%str = [directory_name '\Pattern_2_stripe_48P_RC'];
%save(str, 'pattern');
save('pattern_vikram1');

% Anmo's functions June 2015

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
        
    end

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
        
    end

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
    end
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
    end
end

