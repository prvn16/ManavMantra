function B = bwlookup(bwin, lut) %#codegen
%BWLOOKUP Neighborhood operations using lookup tables. Codegen version.

%   Copyright 2012-2017 The MathWorks, Inc.

%#ok<*EMCA>

validateattributes(bwin,...
    {'logical','numeric'},...
    {'2d','nonsparse','real'},...
    'bwlookup');
validateattributes(lut,...
    {'logical','numeric'},...
    {'vector','nonsparse','real'},...
    'bwlookup');

% Cast input to logical if required
if(islogical(bwin))
    bw = bwin;
else
    %> Use logical inputs to remove this loop.
    bw = bwin~=0;
end

% const fold the LUT if possible
coder.internal.prefer_const(lut);

lutLength = numel(lut);

% compile time check for fixed sized lut
% or runtime assert for variable sized lut
eml_invariant((lutLength == 16 || lutLength == 512), ...
    eml_message('images:bwlookup:invalidLUTLength'));

% Initialize output
if(islogical(lut))
    B = coder.nullcopy(false(size(bw)));
else
    B = coder.nullcopy(zeros(size(bw),'like', lut));
end

% Handle special case of empty input
if(isempty(bw))
    return;
end

% Number of threads (obtained at compile time)
singleThread = images.internal.coder.useSingleThread();

%% Shared library
coder.extrinsic('images.internal.coder.useSharedLibrary');
if (images.internal.coder.isCodegenForHost() && ...
        coder.const(images.internal.coder.useSharedLibrary()) && ...
        ~(coder.isRowMajor && ~coder.internal.isConst(lutLength)))
    
    % Reindex the LUT for row-major.
    % The index is obtained by treating the neighborhood of a pixel as a
    % binary integer with the bit position assignment (1 denotes
    % the position of the least significant bit):
    if coder.isRowMajor()
        if lutLength == 16
            % Original bit position order - 2-by-2
            %
            %  1*  3
            %  2   4
            
            % Row-major bit position order - 2-by-2
            %
            %  1*  2
            %  3   4
            
            lutRowMajor = coder.nullcopy(lut);
            for k = 1:16
                idx = dec2bin(k-1,4);
                % Swap the 2nd and 3rd bits in the 4 bit representation.
                tempIdx = idx(2);
                idx(2) = idx(3);
                idx(3) = tempIdx;
                idx = bin2dec(idx);
                % Use the updated index to get the row-major LUT
                lutRowMajor(k) = lut(idx+1);
            end
            
        else % lutLength == 512

            % Orignal bit position order - 3-by-3
            %
            % 1  4  7
            % 2  5* 8
            % 3  6  9
            
            % Row-major bit position order - 3-by-3
            %
            % 1  2  3
            % 4  5* 6
            % 7  8  9
            
            lutRowMajor = coder.nullcopy(lut);
            for k = 1:512
                idx = dec2bin(k-1,9);
                
                % Swap the corresponding bits in the 3x3 bit matrix to get the correct
                % index into the original LUT
                
                % Swap 2nd and 4th bits in the 9 bit representation.
                tempIdx = idx(2);
                idx(2) = idx(4);
                idx(4) = tempIdx;
                
                % Swap 3rd and 7th bits in the 9 bit representation.
                tempIdx = idx(3);
                idx(3) = idx(7);
                idx(7) = tempIdx;
                
                % Swap 6th and 8th bits in the 9 bit representation.
                tempIdx = idx(6);
                idx(6) = idx(8);
                idx(8) = tempIdx;
                
                idx = bin2dec(idx);
                % Use the updated index to get the row-major LUT
                lutRowMajor(k) = lut(idx+1);
            end
        end
        lut = lutRowMajor;
    end
    
    if(singleThread)
        % Single threaded approach
        fcnName = ['bwlookup_', images.internal.coder.getCtype(lut)];
        B = images.internal.coder.buildable.BwlookupBuildable.bwlookup(...
            fcnName, bw, lut, B);
    else
        fcnName = ['bwlookup_tbb_', images.internal.coder.getCtype(lut)];
        B = images.internal.coder.buildable.Bwlookup_tbb_Buildable.bwlookup(...
            fcnName, bw, lut, B);
    end
    return;
end


%% C code generation
inDims    = size(bw);
if(lutLength==16)
    %> Process a 2x2 lower-right neighborhood.
    
    weights2 = [ 1 4
        2 8];
    
    %> interiors first
    parfor colInd = 1:inDims(2) -1
        for rowInd = 1:inDims(1) -1 %#ok<PFBNS>
            lookUpInd = 1+ ...
                bw(rowInd,   colInd)  *weights2(1) + ...
                bw(rowInd+1, colInd)  *weights2(2) + ...
                bw(rowInd,   colInd+1)*weights2(3) + ...
                bw(rowInd+1, colInd+1)*weights2(4); %#ok<PFBNS>
            B(rowInd,colInd) = lut(lookUpInd); %#ok<PFOUS,PFBNS>
        end
    end
    for colInd = 1:inDims(2) -1
        %> process the element in the last row.
        rowInd = inDims(1);
        lookUpInd = 1+...
            bw(rowInd,   colInd)   * weights2(1) + ...
            bw(rowInd,   colInd+1) * weights2(3);
        B(rowInd,colInd) = lut(lookUpInd);
    end
    
    %> process the full last column.
    colInd = inDims(2);
    for rowInd = 1:inDims(1) -1
        lookUpInd = 1+...
            bw(rowInd,   colInd)  * weights2(1) + ...
            bw(rowInd+1, colInd)  * weights2(2);
        B(rowInd,inDims(2)) = lut(lookUpInd);
        
    end
    
    %> process the last row, last col element
    rowInd = inDims(1);
    colInd = inDims(2);
    lookUpInd         = 1+ bw(rowInd, colInd)*weights2(1);
    B(rowInd, colInd) = lut(lookUpInd);
    
    
elseif(  (inDims(1)>=2) && (inDims(2)>=2) )
    % 512 length lut (3x3 neighbor hood), with input size greater than 2x2
    
    %> Process a 3x3 neighborhood centered around the pixel being processed.
    
    weights3 = [1  8   64
        2  16 128
        4  32 256];
    
    %> process the first column first row element
    rowInd = 1;
    colInd = 1;
    lookUpInd = 1+...
        bw(rowInd,   colInd)   * weights3(5) + ...
        bw(rowInd+1, colInd)   * weights3(6) + ...
        bw(rowInd,   colInd+1) * weights3(8) + ...
        bw(rowInd+1, colInd+1) * weights3(9);
    B(rowInd, colInd) = lut(lookUpInd);
    
    %> process the first column interior elements
    for rowInd = 2: inDims(1)-1
        lookUpInd = 1+...
            bw(rowInd-1, colInd)   * weights3(4) + ...
            bw(rowInd,   colInd)   * weights3(5) + ...
            bw(rowInd+1, colInd)   * weights3(6) + ...
            bw(rowInd-1, colInd+1) * weights3(7) + ...
            bw(rowInd,   colInd+1) * weights3(8) + ...
            bw(rowInd+1, colInd+1) * weights3(9);
        B(rowInd, colInd) = lut(lookUpInd);
    end
    
    %> process the first column last row element
    rowInd = inDims(1);
    lookUpInd = 1+...
        bw(rowInd-1, colInd)   * weights3(4) + ...
        bw(rowInd,   colInd)   * weights3(5) + ...
        bw(rowInd-1, colInd+1) * weights3(7) + ...
        bw(rowInd,   colInd+1) * weights3(8);
    B(rowInd, colInd) = lut(lookUpInd);
    
    
    %> process second column to last but one column-------------------------
    parfor colInd = 2: inDims(2)-1
        %> process second to last but one row for this column
        for rowInd = 2: inDims(1)-1 %#ok<PFBNS>
            lookUpInd = 1+...
                bw(rowInd-1, colInd-1) * weights3(1) + ...
                bw(rowInd,   colInd-1) * weights3(2) + ...
                bw(rowInd+1, colInd-1) * weights3(3) + ...
                bw(rowInd-1, colInd)   * weights3(4) + ...
                bw(rowInd,   colInd)   * weights3(5) + ...
                bw(rowInd+1, colInd)   * weights3(6) + ...
                bw(rowInd-1, colInd+1) * weights3(7) + ...
                bw(rowInd,   colInd+1) * weights3(8) + ...
                bw(rowInd+1, colInd+1) * weights3(9); %#okB<PFBNS>
            B(rowInd,colInd) = lut(lookUpInd); %#ok<PFOUS,PFBNS>
        end
    end
    for colInd = 2: inDims(2)-1
        %> process first row element
        rowInd = 1;
        lookUpInd = 1+...
            bw(rowInd,   colInd-1) * weights3(2) + ...
            bw(rowInd+1, colInd-1) * weights3(3) + ...
            bw(rowInd,   colInd)   * weights3(5) + ...
            bw(rowInd+1, colInd)   * weights3(6) + ...
            bw(rowInd,   colInd+1) * weights3(8) + ...
            bw(rowInd+1, colInd+1) * weights3(9);
        B(rowInd, colInd) = lut(lookUpInd);
        
        %> process the last row element
        rowInd = inDims(1);
        lookUpInd = 1+...
            bw(rowInd-1, colInd-1) * weights3(1) + ...
            bw(rowInd,   colInd-1) * weights3(2) + ...
            bw(rowInd-1, colInd)   * weights3(4) + ...
            bw(rowInd,   colInd)   * weights3(5) + ...
            bw(rowInd-1, colInd+1) * weights3(7) + ...
            bw(rowInd,   colInd+1) * weights3(8);
        B(rowInd,colInd) = lut(lookUpInd);
    end
    %> end process second column to last but one column---------------------
    
    %> process last column first row element
    colInd = inDims(2);
    
    rowInd = 1;
    lookUpInd = 1+...
        bw(rowInd,   colInd-1) * weights3(2) + ...
        bw(rowInd+1, colInd-1) * weights3(3) + ...
        bw(rowInd,   colInd)   * weights3(5) + ...
        bw(rowInd+1, colInd)   * weights3(6);
    B(rowInd,colInd) = lut(lookUpInd);
    
    %> process last column second to last but one element
    for rowInd = 2: inDims(1)-1
        lookUpInd = 1+...
            bw(rowInd-1, colInd-1) * weights3(1) + ...
            bw(rowInd,   colInd-1) * weights3(2) + ...
            bw(rowInd+1, colInd-1) * weights3(3) + ...
            bw(rowInd-1, colInd)   * weights3(4) + ...
            bw(rowInd,   colInd)   * weights3(5) + ...
            bw(rowInd+1, colInd)   * weights3(6);
        B(rowInd,colInd) = lut(lookUpInd);
    end
    
    %> process the last column last row element
    rowInd = inDims(1);
    lookUpInd = 1+...
        bw(rowInd-1, colInd-1) * weights3(1) + ...
        bw(rowInd,   colInd-1) * weights3(2) + ...
        bw(rowInd-1, colInd)   * weights3(4) + ...
        bw(rowInd,   colInd)   * weights3(5);
    B(rowInd,colInd) = lut(lookUpInd);
    
else
    % 512 length lut with input size <2x2
    
    %> input is either 1x1, 1xN or Nx1
    weights3 =...
        [1  8   64
        2  16 128
        4  32 256];
    
    if(inDims(1)==inDims(2))
        %> input size is 1x1
        rowInd = 1;
        colInd = 1;
        lookUpInd         = 1 + bw(rowInd,colInd)* weights3(5);
        B(rowInd, colInd) = lut(lookUpInd);
    end
    
    if(inDims(1)>1)
        %> input size is Nx1
        % first element
        rowInd = 1;
        colInd = 1;
        lookUpInd         = 1 + ...
            bw(rowInd,   colInd)   * weights3(5) + ...
            bw(rowInd+1, colInd)   * weights3(6);
        B(rowInd, colInd) = lut(lookUpInd);
        % middle elements
        for rowInd = 2:inDims(1)-1
            lookUpInd     = 1 + ...
                bw(rowInd-1,colInd) * weights3(4) + ...
                bw(rowInd,colInd)   * weights3(5) + ...
                bw(rowInd+1,colInd) * weights3(6);
            B(rowInd, colInd) = lut(lookUpInd);
        end
        % last element
        rowInd = inDims(1);
        lookUpInd         = 1 + ...
            bw(rowInd-1, colInd)   * weights3(4) + ...
            bw(rowInd,   colInd)   * weights3(5);
        B(rowInd, colInd) = lut(lookUpInd);
    end
    if(inDims(2)>1)
        %> input size is 1xN
        % first element
        rowInd = 1;
        colInd = 1;
        lookUpInd         = 1 + ...
            bw(rowInd,   colInd)   * weights3(5) + ...
            bw(rowInd, colInd+1)   * weights3(8);
        B(rowInd, colInd) = lut(lookUpInd);
        % middle elements
        for colInd = 2:inDims(2)-1
            lookUpInd     = 1 + ...
                bw(rowInd,colInd-1) * weights3(2) + ...
                bw(rowInd,colInd)   * weights3(5) + ...
                bw(rowInd,colInd+1) * weights3(8);
            B(rowInd, colInd) = lut(lookUpInd);
        end
        % last element
        colInd = inDims(2);
        lookUpInd         = 1 + ...
            bw(rowInd, colInd-1)   * weights3(2) + ...
            bw(rowInd,   colInd)   * weights3(5);
        B(rowInd, colInd) = lut(lookUpInd);
    end
    
end
