function make_pattern013()

    pattern.gs_val = 1;
    pattern.row_compression = 1;
    nGrayLevel = 2^(pattern.gs_val);
    pattern.x_num = 12*8;
    pattern.y_num = 1;
    pattern.num_panels = 48; 	% This is the number of unique Panel IDs required.

    Pats = zeros(4, 12*8, pattern.x_num, pattern.y_num);

    SmallPat = zeros(4,8);
    SmallPat(4,:) = [0,0,0,0,(2^pattern.gs_val-1),(2^pattern.gs_val-1),(2^pattern.gs_val-1),(2^pattern.gs_val-1)];
        
    InitPat = ShiftMatrix(repmat(SmallPat,1,12), 1, 'r', 'y');
    Pats(:,:,1,1) = InitPat;

    for j = 2:pattern.x_num
       Pats(:,:,j,1)=ShiftMatrix2(InitPat,(j-1)/(nGrayLevel),'r','y');
    end

    Pats = round(Pats);
    pattern.Pats = Pats;

    pattern.Panel_map = [12 8 4 11 7 3 10 6 2  9 5 1;...
    24 20 16 23 19 15 22 18 14 21 17 13;...
    36 32 28 35 31 27 34 30 26 33 29 25;...
    48 44 40 47 43 39 46 42 38 45 41 37];
    
    pattern.Pats = Pats; 		% put data in structure 
    pattern.BitMapIndex = process_panel_map(pattern);
    pattern.data = Make_pattern_vector(pattern);
    directory_name = 'C:\Users\maimonlab\Desktop\Code for VR\patterns'
    str = [directory_name '\Pattern_013'] 	% name must begin with ‘Pattern_’
    save(str, 'pattern');


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



end