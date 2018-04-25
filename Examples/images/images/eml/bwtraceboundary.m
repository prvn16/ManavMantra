function B = bwtraceboundary(varargin) %#codegen
%BWTRACEBOUNDARY Trace object in binary image.

%   Copyright 2014-2017 The MathWorks, Inc.

%#ok<*EMCA>

[BW, P, FSTEP, CONN, N, DIR] = parseInputs(varargin{:});

B = traceBoundary(BW, P, FSTEP, CONN, DIR, N);

function B = traceBoundary(bw, P, firstStep, conn, dir, maxNumPoints)


numRows = size(bw,1);
numCols = size(bw,2);

if (maxNumPoints < 0)
    % Set a maximum number of points to trace which is 2k+2
    maxNumPoints = 2 * numRows * numCols + 2;
end

startRow = P(1);
startCol = P(2);

coder.internal.errorIf((startRow > numRows || startCol > numCols),...
    'images:bwtraceboundary:codegenStartingOutsideBW');

bwPadImage = uint8(padarray(bw,[1 1],0,'both'));

numPadRows = numRows + 2;
numPadCols = numCols + 2; %#ok<NASGU>

idx = startCol*numPadRows + startRow + 1;

fStartMarker = START_UINT8;
fBoundaryMarker = BOUNDARY_UINT8;

% Compute the linear indexing offsets to take us from a pixel to its
% neighbors.
M = numPadRows;

fOffsets = coder.nullcopy(zeros(8,1));
fVOffsets = coder.nullcopy(zeros(8,1));
if(conn == 8)
    % Order is: [N, NE, E, SE, S, SW, W, NW];
    fOffsets(1)=-1;fOffsets(2)= M-1;fOffsets(3)=  M;fOffsets(4)= M+1;
    fOffsets(5)= 1;fOffsets(6)=-M+1;fOffsets(7)= -M;fOffsets(8)=-M-1;
    
    % Offsets used for testing if the pixel belongs to a boundary;
    % see isBoundaryPixel()
    fVOffsets(1)=-1;fVOffsets(2)=M;fVOffsets(3)=1;fVOffsets(4)=-M;
else
    % Order is [N, E, S, W]
    fOffsets(1)=-1;fOffsets(2)=M;fOffsets(3)=1;fOffsets(4)=-M;
    
    % Offsets used for testing if the pixel belongs to a boundary
    fVOffsets(1)=-1;fVOffsets(2)= M-1;fVOffsets(3)=  M;fVOffsets(4)= M+1;
    fVOffsets(5)= 1;fVOffsets(6)=-M+1;fVOffsets(7)= -M;fVOffsets(8)=-M-1;
end

ndl8c = [2,3,4,5,6,7,8,1];
nsdl8c = [8,8,2,2,4,4,6,6];

ndl4c = [2,3,4,1];
nsdl4c = [4,1,2,3];

ndl8cc = [8,1,2,3,4,5,6,7];
nsdl8cc = [2,4,4,6,6,8,8,2];

ndl4cc = [4,1,2,3];
nsdl4cc = [2,3,4,1];

% fNextDirectionLut is a lookup table.  Given that we just looked at
% neighbor in a given direction, which neighbor do we look at next?

% fNextSearchDirectionLut is another lookup table.
% Given the direction from pixel k to pixel k+1, what is the direction
% to start with when examining the neighborhood of pixel k+1?

if(dir == CLOCKWISE)
    if (conn == 8)
        fNextDirectionLut =  ndl8c;
    else
        fNextDirectionLut = ndl4c;
    end
    if (conn == 8)
        fNextSearchDirectionLut = nsdl8c;
    else
        fNextSearchDirectionLut = nsdl4c;
    end
else % counterclockwise
    if (conn == 8)
        fNextDirectionLut = ndl8cc;
    else
        fNextDirectionLut = ndl4cc;
    end
    if (conn == 8)
        fNextSearchDirectionLut = nsdl8cc;
    else
        fNextSearchDirectionLut = nsdl4cc;
    end
end

tf = isBoundaryPixel(bwPadImage, idx, conn, fVOffsets);

if(tf)
    % Find the next pixel in the chain thus establishing
    % a valid first step;  the step specified by the user
    % could have led into the object
    [fNextSearchDir] = setNextSearchDirection(bwPadImage, idx, firstStep, dir, conn, fOffsets, fVOffsets);
    B = traceBoundaryImage(bwPadImage, numPadRows, idx, conn, maxNumPoints, fOffsets, fStartMarker, fBoundaryMarker, fNextSearchDir, fNextDirectionLut, fNextSearchDirectionLut);
    
else
    B = [];
end

% Detect if the trace did not terminate properly.
coder.internal.errorIf((size(B,1) > 2*numRows*numCols + 1),...
    'images:bwtraceboundary:failedTrace');


function tf = isBoundaryPixel(bwPadImage, idx, conn, fVOffsets)

tf = false;

% First, make sure that it's not a background pixel, otherwise it's
% an automatic failure
if(bwPadImage(idx))
    % Make sure that the pixel is not in the interior of the object
    if (conn == 4)
        numVOffsets = 8;
    else
        numVOffsets = 4;
    end
    
    for i= 1:numVOffsets
        if(~bwPadImage(idx+fVOffsets(i)))
            % If there was at least one background pixel abuting
            % pixel under test, then we do have a boundary pixel.
            tf = true;
            break;
        end
    end
end


% //////////////////////////////////////////////////////////////////////////////
% // Given an initial boundary pixel and an initial 'best guess' search
% // direction, this method verifies that the best guess is valid and if it
% // is not, then it finds the proper direction.
% //
% // NOTE: setNextSearchDirection method assumes that idx points to a valid
% //       boundary pixel. It's the user's responsibility to make sure that
% //       this is the case
% //
% //////////////////////////////////////////////////////////////////////////////
function fNextSearchDir = setNextSearchDirection(bwPadImage, idx, firstStep, dir, conn, fOffsets, fVOffsets)

% Make sure that the user specified valid starting direction
validSearchDirFound = false;
fNextSearchDir = 0;
for clockIdx = firstStep : 1 : firstStep+conn-1
    % Convert clockwise idx to counterclockwise index so that
    % we don't have to write two "for" loops
    tmp = 2*firstStep - clockIdx; % linear index which might be <0
    if (tmp > 0)
        counterIdx =  tmp;
    else
        counterIdx = conn+tmp; % convert to positive
    end
    
    % Set current index depending on the tracing direction
    if (dir == CLOCKWISE)
        currentCircIdx =  clockIdx;
    else
        currentCircIdx = counterIdx;
    end
    currentCircIdx = mod(currentCircIdx,conn); % convert linear index to circular index
    
    % Search for a background neighbor according to the proposed search
    % direction.
    if (dir == CLOCKWISE)
        delta = -1;
    else
        delta = 1;
    end
    if (conn == 8)
        checkDir = currentCircIdx + delta;
        if (checkDir < 0)
            checkDir = checkDir + 8;
        end
        checkDir = mod(checkDir,8);
        
        % For 8-connected traces, fOffsets has all 8 neighbors.
        % checkDir1 is zero-based so add 1 before using it as an index
        offset = idx + fOffsets(checkDir+1);
        if (bwPadImage(offset) == 0)
            validSearchDirFound = true;
            % currentCircIdx is zero-based so add 1 before using it as an index
            fNextSearchDir = currentCircIdx+1;
            break;
        end
    else
        checkDir1 = 2*currentCircIdx + 2*delta;
        if (checkDir1 < 0)
            checkDir1 = checkDir1 + 8;
        end
        checkDir1 = mod(checkDir1,8);
        
        checkDir2 = checkDir1 - delta;
        if (checkDir2 < 0)
            checkDir2 = checkDir2 + 8;
        end
        checkDir2 = mod(checkDir2,8);
        
        % For 4-connected traces, fVOffsets has all 8 neighbors.
        % checkDir1 and checkDir2 are zero-based so add 1 before using
        % them as indices
        offset1 = idx + fVOffsets(checkDir1+1);
        offset2 = idx + fVOffsets(checkDir2+1);
        if ( ~(bwPadImage(offset1) && bwPadImage(offset2)) )
            validSearchDirFound = true;
            % currentCircIdx is zero-based so add 1 before using it as an index
            fNextSearchDir = currentCircIdx+1;
            break;
        end
    end
end

assert(validSearchDirFound, 'Unable to determine valid search direction');


% //////////////////////////////////////////////////////////////////////////
%     //This method traces a single contour of a region surrounded by zeros.  It
%     //takes a label matrix, linear index to the initial border pixel belonging
%     //to the object that's going to be traced, and it needs to be
%     //pre-configured by invoking initializeTracer routine. It returns mxArray
%     //containing X-Y coordinates of border pixels.
%     //////////////////////////////////////////////////////////////////////////
function boundary = traceBoundaryImage(bwPadImage, numRows, idx, conn, maxNumPixels, fOffsets, fStartMarker, fBoundaryMarker, fNextSearchDir, fNextDirectionLut, fNextSearchDirectionLut)

coder.varsize('fScratch',[],[1 0]);
fScratch  = zeros(0,1);

% Initialize loop variables
numPixels     = 1;
fScratch      = [fScratch;idx];
bwPadImage(idx)  = fStartMarker;
done             = false;
currentPixel  = idx;
nextSearchDir    = fNextSearchDir;
initDepartureDir = -1;

while(~done)
    % Find the next boundary pixel.
    direction      = nextSearchDir;
    foundNextPixel = false;
    
    for k = 1:conn
        % Try to locate the next pixel in the chain
        neighbor = currentPixel + fOffsets(direction);
        
        if(bwPadImage(neighbor))
            % Found the next boundary pixel.
            if((bwPadImage(currentPixel) == fStartMarker) && ...
                    (initDepartureDir == -1))
                % We are making the initial departure from the
                % starting pixel.
                initDepartureDir = direction;
            elseif((bwPadImage(currentPixel) == fStartMarker) && ...
                    (initDepartureDir == direction))
                % We are about to retrace our path.
                % That means we're done.
                done = true;
                foundNextPixel = true;
                break;
            end
            
            % Take the next step along the boundary.
            nextSearchDir = fNextSearchDirectionLut(direction);
            foundNextPixel = true;
            
            % First increment it and then use numPixels as an index into
            % scratch array,
            numPixels = numPixels + 1;
            fScratch = [fScratch; neighbor]; %#ok<AGROW>
            
            if(numPixels == maxNumPixels)
                done = true;
                break;
            end
            
            if(bwPadImage(neighbor) ~= fStartMarker)
                bwPadImage(neighbor) = fBoundaryMarker;
            end
            
            currentPixel = neighbor;
            break;
            
        end
        direction = fNextDirectionLut(direction);
    end
    
    if (~foundNextPixel)
        % If there is no next neighbor, the region must
        % just have a single pixel.
        numPixels = 2;
        fScratch = [fScratch;fScratch]; %#ok<AGROW>
        done = true;
    end
end

% Create boundary array and stuff it with proper data
boundary = coder.nullcopy(zeros(numPixels,2));
for idx = 1:numPixels
    boundary(idx) = mod(fScratch(idx)-1,numRows);
    boundary(numPixels+idx) = floor((fScratch(idx)-1)/numRows);
end

%-----------------------------------------------------------------------------

%-----------------------------------------------------------------------------
% Values used for marking the starting and boundary pixels.
%-----------------------------------------------------------------------------

function out = START_UINT8()

out = uint8(2);

function out = BOUNDARY_UINT8()

out = uint8(3);

function out = CLOCKWISE()

out = 1;

%-----------------------------------------------------------------------------

function [BW, P, FSTEP, CONN, N, DIR] = parseInputs(varargin)

narginchk(3,6);

% BW
BW1 = varargin{1};
validateattributes(BW1, {'numeric', 'logical'}, ...
    {'real', '2d', 'nonsparse','nonempty'}, ...
    mfilename, 'BW', 1);

if ~islogical(BW1)
    BW = BW1 ~= 0;
else
    BW = BW1;
end

% P
P = varargin{2};
validateattributes(P, {'double'}, {'real', 'vector', 'nonsparse','integer',...
    'positive'}, mfilename, 'P', 2);
coder.internal.errorIf((any(size(P) ~= [1,2])),...
    'images:bwtraceboundary:invalidStartingPoint');

% CONN
if nargin > 3
    eml_invariant(eml_is_const(varargin{4}),...
        eml_message('MATLAB:images:validate:codegenInputNotConst','CONN'),...
        'IfNotConst','Fail');
    CONN = varargin{4};
    validateattributes(CONN, {'double'}, {}, mfilename, 'CONN', 4);
    coder.internal.errorIf((CONN~=4 && CONN~=8),...
        'images:bwtraceboundary:badScalarConn');
else
    CONN = coder.const(8);
end

% FSTEP
eml_invariant(eml_is_const(varargin{3}),...
    eml_message('MATLAB:images:validate:codegenInputNotConst','FSTEP'),...
    'IfNotConst','Fail');

if CONN == 8
    string = validatestring(varargin{3}, {'n','ne','e','se','s','sw','w','nw'}, mfilename, 'FSTEP', 3);
    
    switch lower(string)
        case 'n'
            i = 1;
        case 'ne'
            i = 2;
        case 'e'
            i = 3;
        case 'se'
            i = 4;
        case 's'
            i = 5;
        case 'sw'
            i = 6;
        case 'w'
            i = 7;
        case 'nw'
            i = 8;
        otherwise
            i = 0;
            assert(false,'Unexpected direction string.');
    end
else
    string = validatestring(varargin{3}, {'n','e','s','w'}, mfilename, 'FSTEP', 3);
    switch lower(string)
        case 'n'
            i = 1;
        case 'e'
            i = 2;
        case 's'
            i = 3;
        case 'w'
            i = 4;
        otherwise
            i = 0;
            assert(false,'Unexpected direction string.');
    end
end

% Make FSTEP (first step) a zero-based index
FSTEP = i-1;

% Should never error here
% FSTEP variable must be between 0 and 7
coder.internal.errorIf((FSTEP < 0 || FSTEP > CONN-1),...
    'images:bwtraceboundary:codegenInvalidInitialStep',CONN-1);
coder.internal.errorIf(~isa(FSTEP,'double') || any(size(FSTEP) ~=1) || any(floor(FSTEP) ~= FSTEP) ...
    || any(~isfinite(FSTEP)),...
    'images:bwtraceboundary:internalError', 'FSTEP');

DIR = true;
N = -1; % Trace the entire boundary by default

% N
if nargin > 4
    N = varargin{5};
    validateattributes(N, {'double'}, {'real','nonnan','nonnegative','nonzero'}, ...
        mfilename, 'N', 5);
    if ~isinf(N)
        validateattributes(N, {'double'}, {'integer','scalar'}, ...
            mfilename, 'N', 5);
        coder.internal.errorIf(N<2,...
            'images:bwtraceboundary:invalidMaxNumPixels');
    else
        N = -1;
    end
    
    % DIR
    if nargin > 5
        eml_invariant(eml_is_const(varargin{6}),...
            eml_message('MATLAB:images:validate:codegenInputNotConst','DIR'),...
            'IfNotConst','Fail');
        validStrings = {'clockwise', 'counterclockwise'};
        string = validatestring(varargin{6}, validStrings, mfilename, 'DIR', 6);
        switch string
            case 'clockwise'
                DIR = true;
            case 'counterclockwise'
                DIR = false;
            otherwise
                coder.internal.assert(false,'images:bwtraceboundary:unexpectedError');
        end
        
        coder.internal.errorIf(~islogical(DIR) || any(size(DIR) ~=1),...
            'images:bwtraceboundary:internalError', 'DIR');
    end
end
