function lines = houghlines(varargin) %#codegen

% Copyright 2015 The MathWorks, Inc.

%#ok<*EMCA>

% Supported syntax in code generation
% -----------------------------------
%     lines = houghlines(BW,theta,rho,peaks)
%     lines = houghlines(BW,theta,rho,peaks,ParameterName,ParameterValue)
%
% Input/output specs in code generation
% -------------------------------------
% BW:    2-D
%        real
%        non-sparse
%        non-empty
%        logical or numeric: uint8, uint16, uint32, uint64,
%                            int8, int16, int32, int64, single, double
%
% theta:    
%        real
%        vector
%        finite
%        non-empty
%        non-sparse
%        class double only
%
% rho:
%        real
%        vector
%        finite
%        non-empty
%        non-sparse
%        class double only
%
% peaks:
%        real
%        2-D
%        size(peaks,2) must be 2
%        nonsparse
%        positive
%        integer
%        class double only
%
% ParameterName can be 'FillGap' and 'MinLength'
%
% ParameterValue for 'FillGap' must be:
%        scalar
%        real
%        finite
%        positive
%        class double only
%        default: 20.0
%
% ParameterValue for 'MinLength' must be:
%        scalar
%        real
%        finite
%        positive
%        class double only
%        default: 40.0
%
% lines:
%        structure array
%        length equals the number of merged line segments found
%        has these fields:
%             point1: 1x2 double vector; end point of the line segment
%             point2: 1x2 double vector; other end point of the line segment
%             theta:  double scalar; angle of the Hough transform bin (degree)
%             rho:    double scalar; rho-axis position of the bin
%

[BW,theta,rho,peaks,fillGap,minLength] = parseInputs(varargin{:});

nonZeroPixels = findNonZero(BW);

minLength2 = minLength^2;
numLines = coder.internal.indexInt(0);

% These variable size arrays store the output temporarily, because you
% can't grow a struct array in codegen.
coder.varsize('point1Array',[Inf,2],[1,0]);
point1Array = coder.internal.indexInt(zeros(0,2));

coder.varsize('point2Array',[Inf,2],[1,0]);
point2Array = coder.internal.indexInt(zeros(0,2));

coder.varsize('thetaArray',[Inf,1],[1,0]);
thetaArray = single(zeros(0,1));

coder.varsize('rhoArray',[Inf,1],[1,0]);
rhoArray = single(zeros(0,1));

firstRho = double(rho(1));
numRho = numel(rho);
lastRho = double(rho(numRho));
slope = double((numRho - 1)) / double(lastRho - firstRho);

% For all peaks
numPeaks = size(peaks,1);
for peakIdx = 1:numPeaks    
    % Coordinates of the current peak
    peak1 = coder.internal.indexInt(peaks(peakIdx,1));
    peak2 = coder.internal.indexInt(peaks(peakIdx,2));
    
    % Get all pixels associated with the Hough transform cell (peak1,peak2)
    [numHoughPix,houghPix] = getHoughPixels(nonZeroPixels,theta,firstRho,slope,peak1,peak2);
    
    if (numHoughPix < 1)
        continue
    end
    
    % Find the gaps between points that are larger than the threshold
    indices = findGapsLargerThanThresh(houghPix, fillGap);
    
    % For each line, return it if it is longer than minLength
    for k = 1:numel(indices)-1
        % xy coordinates of the two ends of a line
        point1 = houghPix(indices(k)+1,:); % +1 is for 1-based indexing
        point2 = houghPix(indices(k+1),:); % don't offset by 1 this time
        
        lineLength2 = computeLineLength(point1,point2);
        if (lineLength2 >= minLength2)
            % Count the number of lines found
            numLines = numLines+1;
            % Add to the output
            point1Array = [point1Array; point1(2) point1(1)]; %#ok<*AGROW>
            point2Array = [point2Array; point2(2) point2(1)];
            thetaArray  = [thetaArray; single(theta(peak2))];
            rhoArray    = [rhoArray; single(rho(peak1))];
        end
    end
end

% Populate the output struct array
lines = convertToStructArray(numLines,point1Array,point2Array,thetaArray,rhoArray);

%--------------------------------------------------------------------------
function nonZeroPixels = findNonZero(BW)
% Non-zero pixels in the input image are candidates for points belonging to
% Hough lines.

coder.inline('always');
coder.internal.prefer_const(BW);

[numRow,numCol] = size(BW);

% Count the number of non-zero pixels in BW
numNonZero = coder.internal.indexInt(0);
for j = 1:numCol
    for i = 1:numRow
        numNonZero = numNonZero + coder.internal.indexInt(BW(i,j)>0);
    end
end

% Get coordinates of non-zero pixels (0-based)
nonZeroPixels = coder.nullcopy(coder.internal.indexInt(zeros(numNonZero,2)));
k = 0;
for j = 1:numCol
    for i = 1:numRow
        if (BW(i,j) > 0)
            k = k+1;
            nonZeroPixels(k,1) = j-1; % x, 0-based
            nonZeroPixels(k,2) = i-1; % y, 0-based
        end
    end
end

%--------------------------------------------------------------------------
function y = roundAndCastInt(x)

coder.inline('always');
coder.internal.prefer_const(x);

% Only works for x >= 0, which is always the case here
y = coder.internal.indexInt(x+0.5);

%--------------------------------------------------------------------------
function [numHoughPix,houghPix] = getHoughPixels(nonZero,theta,firstRho,slope,peak1,peak2)
% Do an exhaustive search over the non-zero pixels of the input image to
% find the points (Hough pixels) associated with the bin (theta,rho)
% corresponding to the current peak.

coder.inline('always');
coder.internal.prefer_const(nonZero,theta,firstRho,slope,peak1,peak2);

% Store the rho values of all non-zero pixels given a fixed angle theta.
numNonZero = size(nonZero,1);
rhoBinIdx = coder.nullcopy(coder.internal.indexInt(zeros(numNonZero,1)));

numHoughPix = coder.internal.indexInt(0);
thetaVal = double(theta(peak2)) * double(pi) / double(180);
cosTheta = cos(thetaVal);
sinTheta = sin(thetaVal);

% For each non-zero pixel:
% compute the bin index on the rho axis based on the bin index on the theta
% axis; count the number of hough pixels found
for k = 1:numNonZero
    % rho = x*cos(theta) + y*sin(theta)
    rhoVal = double(nonZero(k,1))*cosTheta + double(nonZero(k,2))*sinTheta;
    rhoBinIdx(k) = roundAndCastInt(slope*(rhoVal - firstRho) + 1);
    % k is a point on the line associated with the current peak if it
    % satisfies the equation rho = x*cos(theta) + y*sin(theta)
    if (rhoBinIdx(k) == peak1)
        numHoughPix = numHoughPix+1;
    end
end

if (numHoughPix < 1)
    houghPix = coder.internal.indexInt([]);
    return
end

% Do a second pass to get the hough pixels
houghPix = coder.nullcopy(coder.internal.indexInt(zeros(numHoughPix,2)));
n = 0;
for k = 1:numNonZero
    if (rhoBinIdx(k) == peak1)
        n = n+1;
        houghPix(n,1) = nonZero(k,2)+1; % r (1-based) = y (0-based)
        houghPix(n,2) = nonZero(k,1)+1; % c (1-based) = x (0-based)
    end
end

% Sorting: make sure that r an c are in order along the line segment

% Compute the min and max indices for each axis
rowMax = 0;
rowMin = Inf;
colMax = 0;
colMin = Inf;
for k = 1:numHoughPix
    r = double(houghPix(k,1));
    if (r > rowMax)
        rowMax = r;
    end
    if (rowMin > r)
        rowMin = r;
    end
    c = double(houghPix(k,2));
    if (c > colMax)
        colMax = c;
    end
    if (colMin > c)
        colMin = c;
    end
end

% The max range determines along which direction to sort the indices
rowRange = rowMax - rowMin;
colRange = colMax - colMin;
if (rowRange > colRange)
    % Sort on r first, then on c
    sortingOrder = [1,2];
else
    % Sort on c first, then on r
    sortingOrder = [2,1];
end

% Sort the row-column pairs in ascending order
houghPix = sortrows(houghPix, sortingOrder);

%--------------------------------------------------------------------------
function indices = findGapsLargerThanThresh(houghPix, fillGap)
% Points that are less than fillGap away from each other are considered to
% belong to the same line. They are "merged" into a single line.
% indices contains the indices (in houghPix) of the end points of these 
% lines.

coder.inline('always');
coder.internal.prefer_const(houghPix,fillGap);

numHoughPix = size(houghPix,1);
fillGap2 = fillGap^2;

% Compute the squared distances between the point pairs
distances2 = coder.nullcopy(zeros(numHoughPix-1,1));
numPairs = 0;
for k = 1:numHoughPix-1
    % d^2 = (y_k+1 - y_k)^2 + (x_k+1 - x_k)^2
    distances2(k) = (houghPix(k+1,1) - houghPix(k,1))^2 + ...
                    (houghPix(k+1,2) - houghPix(k,2))^2;
    % Count the number of pairs that satisfy the gap threshold
    if (distances2(k) > fillGap2)
        numPairs = numPairs+1;
    end
end

% Get the indices of the pairs that satisfy the gap threshold
indices      = coder.nullcopy(zeros(numPairs+2,1));
indices(1)   = 0;
indices(end) = numHoughPix;
n = 1;
for k = 1:numHoughPix-1
    if (distances2(k) > fillGap2)
        n = n+1;
        indices(n) = k;
    end
end

%--------------------------------------------------------------------------
function lineLength2 = computeLineLength(point1,point2)

coder.inline('always');
coder.internal.prefer_const(point1,point2);

% d^2 = (x2-x1)^2 + (y2-y1)^2
lineLength2 = (point2(1)-point1(1))^2 + (point2(2)-point1(2))^2;

%--------------------------------------------------------------------------
function lines = convertToStructArray(numLines,point1Array,point2Array,thetaArray,rhoArray)

coder.inline('always');
coder.internal.prefer_const(numLines,point1Array,point2Array,thetaArray,rhoArray);

% Initialize the output based on the number of lines found
lines = initializeStructArray(numLines);

% Populate the output struct array
for k = 1:numLines
    lines(k).point1 = double(point1Array(k,:));
    lines(k).point2 = double(point2Array(k,:));
    lines(k).theta  = double(thetaArray(k));
    lines(k).rho    = double(rhoArray(k));
end

%--------------------------------------------------------------------------
function lines = initializeStructArray(numLines)

coder.inline('always');
coder.internal.prefer_const(numLines);

tmp.point1 = [0,0];
tmp.point2 = [0,0];
tmp.theta  = 0;
tmp.rho    = 0;

lines = repmat(tmp,1,numLines);

%--------------------------------------------------------------------------
function [BW,theta,rho,peaks,fillGap,minLength] = parseInputs(varargin)

coder.inline('always');
coder.internal.prefer_const(varargin);

narginchk(4,8);

% Validate BW
BW = varargin{1};
validateattributes(BW, {'numeric','logical'}, ...
    {'real','2d','nonsparse','nonempty'}, ...
    mfilename,'BW',1);

% Validate theta
theta = varargin{2};
validateattributes(theta, {'double'}, ...
    {'real','vector','finite','nonsparse','nonempty'}, ...
    mfilename,'THETA',2);

% Validate rho
rho = varargin{3};
validateattributes(rho, {'double'}, ...
    {'real','vector','finite','nonsparse','nonempty'}, ...
    mfilename,'RHO',3);

% Validate peaks
peaks = varargin{4};
validateattributes(peaks, {'double'}, ...
    {'real','2d','nonsparse','positive', 'integer'}, ...
    mfilename,'PEAKS',4);

coder.internal.errorIf(size(peaks,2) ~= 2, ...
    'images:houghlines:invalidPEAKS');

% Set the defaults
fillGapDefault   = 20; 
minLengthDefault = 40; 

% Parse optional parameters
[fillGap_,minLength_] = parseNameValuePairs(fillGapDefault, ...
                                          minLengthDefault, ...
                                          varargin{5:end});
% Validate FillGap
validateattributes(fillGap_, {'double'}, ...
    {'finite','real','scalar','positive'}, ...
    mfilename,'FillGap');

% Validate MinLength
validateattributes(minLength_, {'double'}, ...
    {'finite','real','scalar','positive'}, ...
    mfilename,'MinLength');

fillGap = fillGap_(1);
minLength = minLength_(1);

%--------------------------------------------------------------------------
function [fillGap,minLength] = parseNameValuePairs(fillGapDefault, ...
                                                   minLengthDefault, ...
                                                   varargin)
                                               
coder.inline('always');
coder.internal.prefer_const(fillGapDefault,minLengthDefault,varargin);

params = struct( ...
    'FillGap', uint32(0), ...
    'MinLength', uint32(0));

options = struct( ...
    'CaseSensitivity',false, ...
    'StructExpand',   true, ...
    'PartialMatching',true);

optarg = eml_parse_parameter_inputs(params,options,varargin{:});

fillGap = eml_get_parameter_value( ...
    optarg.FillGap, ...
    fillGapDefault, ...
    varargin{:});

minLength = eml_get_parameter_value( ...
    optarg.MinLength, ...
    minLengthDefault, ...
    varargin{:});
