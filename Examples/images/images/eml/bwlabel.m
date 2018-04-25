function [L, numComponents] = bwlabel(varargin)%#codegen
%BWLABEL Label connected components in 2-D binary image.

%   Copyright 2014-2017 The MathWorks, Inc.

narginchk(1,2);

BW = varargin{1};
validateattributes(BW, {'logical' 'numeric'}, {'real', '2d', 'nonsparse'}, ...
    mfilename, 'BW', 1);

if (nargin < 2)
    mode = 8;
else
    mode = varargin{2};
    validateattributes(mode, {'double'}, {'real', 'scalar'}, mfilename, 'N', 2);
    
    coder.internal.errorIf(~eml_is_const(mode), ...
        'MATLAB:images:validate:codegenInputNotConst','N');
    coder.internal.errorIf(~((mode == 4) || (mode == 8)), ...
        'images:bwlabel:badConn');
end

if ~islogical(BW)
    im = BW ~= 0;
else
    im = BW;
end

% Get initial labels for each run
[startRow,endRow,startCol,labelForEachRun,numRuns] = ...
    images.internal.coder.intermediateLabelRuns(im,mode);

% Early return when the image contains no connected components.
if numRuns == 0
    [M,N] = size(im);
    L = zeros([M,N]);
    
    numComponents = 0;
    return;
end

% Buffer to store renumbered labels for each run.
labelsRenumbered = coder.nullcopy(labelForEachRun);

% Initialize counter to keep track of number of connected components.
numComponents = 0;
[M,N] = size(im);
L = (zeros([M,N]));

for k = 1:numRuns
    % Renumber labels to get consecutive label numbers.
    if (labelForEachRun(k) == k)
        % k is a root node
        numComponents = numComponents + 1;
        labelsRenumbered(k) = numComponents;
    end
    
    % Lookup renumbered label of the run.
    labelsRenumbered(k) = labelsRenumbered(labelForEachRun(k));

    % Assign labels to pixels in each run.
    % L(idx+(c(k)-1)*M) 
    for idx = coder.internal.indexInt(startRow(k)):coder.internal.indexInt(endRow(k))
        % L(start_row+column_offset:end_row+column_offset)
        L(idx,startCol(k)) = labelsRenumbered(k);
    end
end
