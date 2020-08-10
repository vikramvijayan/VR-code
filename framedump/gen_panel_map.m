function map = gen_panel_map(nbus, width, height)
%GEN_PANEL_MAP generates a matrix which contains panel addresses
%
%WARNING:  CURRENTLY ONLY SUPPORTS EQUAL BUS DISTRIBUTIONS (SCALER ENTRY)
%
%NBUS:  can be a scaler to indicate the number of buses or a vector
%indicating the number of panels on each bus (starting with bus0).  If a
%scalar is sent, panels are assumed to be equally distributed among the
%buses.  This means that passing [3,3,3] as nbus has the same effect as 3.
%
%WIDTH:  how many panels wide
%HEIGHT:  how many panels tall
    
    % pre-allocate the matrix
    map = zeros(height, width);

%     % parsing/handling of the bus size
%     if length(nbus) == 1
%         %scaler so use that to set increment size
%         businc = ones(1, nbus) * nbus;
%     else
%         %vector indicating number of panels per bus
%         %use that to set loop size
%         businc = nbus;
%     end
    
    % WARNING:  the following assumes buses of equal size
    inc = 1;
    for i = 1:height
        for k = 0:(width/nbus)-1
            ind = width-k:-1*(width/nbus):1;
            for j = 1:length(ind)
                map(i, ind(j)) = inc;
                inc = inc + 1;
            end
        end
    end
    
end