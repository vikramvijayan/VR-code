function make_pattern030()

pattern.gs_val = 1;
pattern.row_compression = 1;
nGrayLevel = 2^(pattern.gs_val);
pattern.x_num = 24*8*nGrayLevel;
pattern.y_num = 1;
pattern.num_panels = 120; 	% This is the number of unique Panel IDs required.
arenawidth=18*8;
fullwidth=24*8;
arenaheight=5*8;
buffer_frames = 24;

pattern.Panel_map = [24 20 16 12  8  4 23 19 15 11  7  3 22 18 14 10  6  2 21 17 13  9  5  1; ....
    48 44 40 36 32 28 47 43 39 35 31 27 46 42 38 34 30 26 45 41 37 33 29 25; ...
    72 68 64 60 56 52 71 67 63 59 55 51 70 66 62 58 54 50 69 65 61 57 53 49; ...
    96 92 88 84 80 76 95 91 87 83 79 75 94 90 86 82 78 74 93 89 85 81 77 73; ...
    120 116 112 108 104 100 119 115 111 107 103 99 118 114 110 106 102 98 117 113 109 105 101 97];

%%%%%%%%%%%%%%% gray scale 1/f vertical stripes  -- version1 %%%%%%%%%%%
nGraylevel=8;%this is very important to achieve 1000 deg/s speed without jumping pixels
height=arenaheight/8;%because the row compression

max_vel=(nGraylevel-1)*125;% number of pixels per second (250 pixel jumps in a second)

%compose a 1/f vector
f=5:.1:80;%number of period in the fullwidth -- 80 is the nyquist rate of full width
randvec=zeros(1,fullwidth);
for i=1:length(f)
    phase=rand(1,1)*fullwidth;
    xi=sin(2*pi*f(i)*(phase+(1:fullwidth))/fullwidth);
    randvec=randvec+xi/(f(i)^1);%weighted by 1/f(i)^1
end

%normalize random vector
tmp=sort(randvec);
threshold=tmp(round(length(tmp)*.025));%2.5% of the cdf
randvec(randvec<threshold)=threshold;
randvec=(randvec-min(randvec))/(max(randvec)-min(randvec));

%figure(230942);clf;plot(randvec);

%compose the initial pattern (pat1)
z = load('pattern28_randvec_template');
randvec = z.randvec;

pat1=repmat(randvec,height,1);
pat1(3:5,:) = 0;
pat1(1,:) = 0;

%compose the full pattern
Pats=zeros(height,fullwidth,fullwidth*(nGraylevel));
for j=1:size(Pats,3)
    Pats(:,:,j)=ShiftMatrix2(pat1,(j-1)/(nGraylevel),'r','y');
end


Pats = round(Pats);
pattern.Pats = Pats;


pattern.Pats = Pats; 		% put data in structure
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);
directory_name = 'C:\Users\maimonlab\Desktop\Vikram\beta code for VR2\patterns_24panel'
str = [directory_name '\Pattern_030'] 	% name must begin with ‘Pattern_’
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