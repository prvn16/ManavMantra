function BW2 = bwareaopen(varargin) %#codegen

% Copyright 2015-2017 The MathWorks, Inc.

% Supported Syntax
% ----------------
%    BW2 = bwareaopen(BW,P)
%    BW2 = bwareaopen(BW,P,conn)
%
% Input/output specs for codegen
% ------------------------------
% BW:    2-D real full matrix (N-D not supported)
%        any numeric class
%        sparse not allowed
%        anything that's not logical is converted first using
%          bw = BW ~= 0
%        Empty ok
%        Inf's ok, treated as 1
%        NaN's ok, treated as 1
%
% P:     double scalar
%        nonnegative integer
%
% CONN:  connectivity as a compile-time constant
%        if scalar: value 1, 4 or 8
%        if nonscalar, must be 3-by-3, symmetric around its center, and the
%        value at the center must be 1 (center must be connected to itself)
%        default: scalar 8 / nonscalar ones(3)
%
% BW2:   logical, same size as BW
%        contains only 0s and 1s.

%#ok<*EMCA>

[BW,P,connScalar,connMatrix,isCustomConn] = parseInputs(varargin{:});

% Get the label matrix and the number of regions
% Check if empty: Coder doesn't like assigning [] to a persistent variable
if (isCustomConn && ~isempty(connMatrix))
    % Use this path if conn is a 3-by-3 matrix describing a custom
    % connectivity
    [L,numComponents] = computeLabelImage(BW,connMatrix);
else
    % Use bwlabel if conn is a scalar with value 4 or 8 (faster)
    [L,numComponents] = bwlabel(BW,connScalar);
end

% Compute the area of each connected component
regionLengths = images.internal.coder.computeConnectedComponentAreas(L,numComponents);

% Compute the list of pixels belonging to each connected component
pixelIdxList = images.internal.coder.computeConnectedComponentPixelIdxList(L,regionLengths);

% Initialize output binary image to zero
BW2 = false(size(BW));

% Counter to keep track of the beginning of each region in pixelIdxList
beginIdx = coder.internal.indexInt(0);

% Set foreground pixels to 1 if the region is larger than P
for i = 1:numComponents
    numPixelsInRegion = regionLengths(i);
    if (numPixelsInRegion >= P(1))
        for j = 1:numPixelsInRegion
            BW2(pixelIdxList(beginIdx + j)) = true;
        end
    end
    beginIdx = beginIdx + numPixelsInRegion;
end

function [BW,P,connScalar,connMatrix,isCustomConn] = parseInputs(varargin)
% parseInputs
coder.inline('always');
coder.internal.prefer_const(varargin);

narginchk(2,3)

% If conn is 4 or 8 (default), use bwlabel because it's faster. Otherwise,
% use a code path similar to what bwconncomp does, but for 2-D images only.
isCustomConn = true;

im = varargin{1};
validateattributes(im,{'numeric','logical'},{'real','2d','nonsparse'}, ...
    mfilename,'BW',1);

% NaN's and Inf's become 1
if ~islogical(im)
    BW = im ~= 0;
else
    BW = im;
end

P = varargin{2};
validateattributes(P,{'double'},{'scalar','integer','nonnegative'}, ...
    mfilename,'P',2);

if (nargin >= 3)
    conn_user = varargin{3};
    validateattributes(conn_user,{'double','logical'},{'real','nonsparse'}, ...
        mfilename,'CONN',3);
    
    % CONN must be a compile-time constant
    coder.internal.errorIf(~coder.internal.isConst(conn_user), ...
        'MATLAB:images:validate:codegenInputNotConst','CONN');
    
    if (numel(conn_user) == 1)
        % Scalar CONN must 1, 4 or 8
        coder.internal.errorIf(conn_user ~= 1 && conn_user ~= 4 && conn_user ~= 8, ...
            'images:bwareaopen:badScalarConnCodegen',mfilename,3,'CONN');
        
        if (conn_user == 1)
            % Transform to a 3-by-3 matrix
            connMatrix = logical([0,0,0;0,1,0;0,0,0]);
            connScalar = [];
        else
            % Take the fast lane
            isCustomConn = false;
            connScalar = conn_user;
            connMatrix = [];
        end
    else
        % Nonscalar CONN must be 3-by-3
        coder.internal.errorIf(any(size(conn_user) ~= 3), ...
            'images:bwareaopen:badConnSizeCodegen',mfilename,3,'CONN');
        % Nonscalar CONN must only contain zeros and ones
        coder.internal.errorIf(any((conn_user(:) ~= 1) & (conn_user(:) ~= 0)), ...
            'images:validate:badConnValue',mfilename,3,'CONN');
        % The center of a nonscalar CONN must be 1
        coder.internal.errorIf(conn_user((end+1)/2) == 0, ...
            'images:validate:badConnCenter',mfilename,3,'CONN');
        % Nonscalar CONN must be symmetric around its center
        coder.internal.errorIf(~isequal(conn_user(1:end), conn_user(end:-1:1)), ...
            'images:validate:nonsymmetricConn',mfilename,3,'CONN');
        
        % Take the fast lane if the user gave a matrix equivalent to 4 or 8
        if isequal(conn_user,true(3,3))
            % conn = 8
            connMatrix = [];
            connScalar = 8;
            isCustomConn = false;
        elseif isequal(conn_user,[0,1,0;1,1,1;0,1,0])
            % conn = 4
            connMatrix = [];
            connScalar = 4;
            isCustomConn = false;
        else
            % General case
            connMatrix = logical(conn_user);
            connScalar = [];
        end
    end 
else
    % Default connectivity is 8
    connScalar = 8;
    connMatrix = [];
    isCustomConn = false;
end

function [L,numComponents] = computeLabelImage(BW,conn)
% computeLabelImage

% Inspired by the all-purpose, N-D implementation of bwconncomp
% (pixelIdxListsn.cpp)

coder.inline('always');
coder.internal.prefer_const(BW,conn);

% Total number of pixels
[N,M] = size(BW);
numElems = N*M;

% Initialize L to zeros
L = zeros([N,M]);

% Initialize label counter to 1
label = 1;

% Initialize the stack with a max size of numElems
if (coder.internal.isConst(numElems))
    stack = images.internal.coder.FixedSizeStack(numElems,'indexInt');
else
    stack = images.internal.coder.VariableSizeStack('indexInt');
end

% Initialize the neighborhood walker with connectivity matrix and dims
neighborhoodProcessor = images.internal.coder.NeighborhoodProcessor([N,M],conn);
neighborhoodProcessor.updateInternalProperties();

for p = 1:numElems
    if BW(p)
        % Haven't traversed pixel p yet. Push it onto the queue so we
        % remember to visit p's neighbors
        stack.push(coder.internal.indexInt(p));
        
        % Don't visit p again after this scan
        BW(p) = false;
        
        while ~stack.is_empty()
            % Pop the next pixel connected to p
            r = stack.pop();
            
            % Label r because it is connected to p
            L(r) = label;
            
            % Add the neighbors of r to the queue
            neighbors = neighborhoodProcessor.getNeighborIndices(r);
            for idx = 1:numel(neighbors)
                q = neighbors(idx);
                if (BW(q))
                    stack.push(coder.internal.indexInt(q));
                    BW(q) = false;
                end
            end
        end
        % when the queue is empty, we have found all the pixels belonging
        % to one connected component. Increment the label counter.
        label = label + 1;
    end
end

numComponents = label;
