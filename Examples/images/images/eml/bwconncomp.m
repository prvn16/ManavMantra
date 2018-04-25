function CC = bwconncomp(varargin) %#codegen
%BWCONNCOMP Find connected components in binary image.

%   Copyright 2015-2017 The MathWorks, Inc.

[BW, conn] = parseInputs(varargin{:});

% Get initial labels for each run
[startRow,endRow,startCol,labelForEachRun,numRuns] = ...
    images.internal.coder.intermediateLabelRuns(BW,conn);

% Early return when the image contains no connected components.
if numRuns == 0
    % No objects
    CC.Connectivity = conn;
    CC.ImageSize = size(BW);
    CC.NumObjects = 0;
    CC.RegionIndices = zeros(0,1);
    CC.RegionLengths = coder.internal.indexInt(0);
    
    return;
end

% Buffer to store renumbered labels for each run.
labelsRenumbered = coder.nullcopy(labelForEachRun);

% Initialize counter to keep track of number of connected components.
numComponents = 0;

for k = 1:numRuns
    % Renumber labels to get consecutive label numbers.
    if (labelForEachRun(k) == k)
        numComponents = numComponents + 1;
        labelsRenumbered(k) = numComponents;
    end
    
    % Lookup renumbered label of the run.
    labelsRenumbered(k) = labelsRenumbered(labelForEachRun(k));
end

regionLengths = zeros(numComponents,1,coder.internal.indexIntClass());

for k = 1:numRuns
    % Floor label value by casting.
    idx = coder.internal.indexInt(labelsRenumbered(k));
    % Zero and negative label values represent the background.
    if idx > coder.internal.indexInt(0)
        regionLengths(idx,1) = regionLengths(idx,1) + endRow(k) - startRow(k) + 1;
    end
end

[M,~] = size(BW);
numObjs = numComponents;

pixelIdxList = coder.nullcopy(zeros(sum(regionLengths,1),1));
idxCount = coder.internal.indexInt([0;cumsum(regionLengths)]);
for k = 1:numRuns
    
    column_offset = coder.internal.indexTimes(coder.internal.indexMinus(startCol(k),1),M);

    % Floor label value by casting.
    idx = coder.internal.indexInt(labelsRenumbered(k));
    % Zero and negative label values represent the background.
    if idx > coder.internal.indexInt(0)
        for rowidx = startRow(k):endRow(k)
            idxCount(idx) = coder.internal.indexPlus(idxCount(idx),1);
            pixelIdxList(idxCount(idx),1) = rowidx + column_offset;
        end
    end
end

CC.Connectivity = conn;
CC.ImageSize = size(BW);
CC.NumObjects = numObjs;
CC.RegionIndices = pixelIdxList;
CC.RegionLengths = regionLengths;


%--------------------------------------------------------------------------
function [BW,conn] = parseInputs(varargin)

coder.internal.prefer_const(varargin);
narginchk(1,2);

validateattributes(varargin{1}, {'logical' 'numeric'}, {'2d', 'real', 'nonsparse'}, ...
    mfilename, 'BW', 1);
if ~islogical(varargin{1})
    BW = varargin{1} ~= 0;
else
    BW = varargin{1};
end

if nargin < 2
    %BWCONNCOMP(BW)
    conn = 8;
    
else
    %BWCONNCOMP(BW,CONN)
    connIn = varargin{2};
    
    coder.internal.errorIf(~eml_is_const(connIn), ...
        'MATLAB:images:validate:codegenInputNotConst','CONN');
    
    iptcheckconn(connIn,mfilename,'CONN',2); 
    
    % special case so that we go through the 2D code path for 4 or 8
    % connectivity
    if isequal(connIn, [0 1 0;1 1 1;0 1 0])
        conn = 4;        
    elseif isequal(connIn, ones(3))
        conn = 8;
    else
        conn = double(connIn);        
    end
    
    coder.internal.errorIf(~((conn(1) == 4) || (conn(1) == 8)), ...
        'images:validate:codegenUnsupportedConn');      
       
end
