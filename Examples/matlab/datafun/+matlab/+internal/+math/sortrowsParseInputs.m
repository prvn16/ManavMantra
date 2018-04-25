function [col, nanFlag, compareFlag] = sortrowsParseInputs(A,varargin)
%sortrowsParseInputs Parse optional sortrows inputs
%
%   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
%   Its behavior may change, or it may be removed in a future release.
%

%   Copyright 2016 The MathWorks, Inc.

if ~ismatrix(A)
    error(message('MATLAB:sortrows:inputDimensionMismatch'));
end
%   SORTROWS(A) defaults:
n = size(A,2);
col = (1:n)';
nanFlag = 0;     % 0 for 'auto', 1 for NaNs first, 2 for NaNs last
compareFlag = 0; % 0 for 'auto', 1 for 'abs', 2 for 'real'

%   SORTROWS(A,COL)
%   SORTROWS(A,COL,DIR)
%   SORTROWS(A,COL,DIR,N1 ,V1 ,N2 ,V2 ,...)
%   SORTROWS(A,COL,N1 ,V1 ,N2 ,V2 ,...)
%   SORTROWS(A,DIR)
%   SORTROWS(A,DIR,N1 ,V1 ,N2 ,V2 ,...)
%   SORTROWS(A,N1 ,V1 ,N2 ,V2 ,...)
if nargin > 1
    % Look for a COL input
    in2 = varargin{1};
    [col,colProvided] = legacyParseCOL(col,n,in2);
    if 1+colProvided <= nargin-1
        % Look for a DIRECTION input
        [col,dirProvided,dirErr] = directions2columns(col,varargin{1+colProvided});
        nvStart = 1+colProvided+dirProvided;
        if rem(nargin-nvStart,2) == 0
            % Look for trailing Name-Value pairs
            [nanFlag,compareFlag] = parseNV(A,nanFlag,compareFlag,nvStart,varargin{:});
        else
            % Helpful error messages
            if dirErr == 1
                if ~colProvided
                    error(message('MATLAB:sortrows:SecondArgumentType'));
                else % dirPosition == 2
                    error(message('MATLAB:sortrows:ThirdArgumentType'));
                end
            elseif dirErr == 2
                if ~colProvided
                    error(message('MATLAB:sortrows:NumDirectionsSecond'));
                else % dirPosition == 2
                    error(message('MATLAB:sortrows:NumDirectionsThird'));
                end
            elseif dirErr == 3
                error(message('MATLAB:sortrows:DIRnotRecognized'));
            end
            error(message('MATLAB:sortrows:NameValuePairs'));
        end
    end
end

%--------------------------------------------------------------------------
function [col,dirProvided,dirErr] = directions2columns(col,directions)
dirProvided = false;
dirErr = 0;
if ~ischar(directions) && ~iscellstr(directions) && ~isstring(directions)
    dirErr = 1;
    return
end
n = numel(col);
directions = string(directions);
nd = numel(directions);
% DIRECTIONS must be a scalar or a vector of length equal to numel COL.
if (nd ~= n && nd ~= 1) || ~isvector(directions)
    dirErr = 2;
    return
end
dirsigns = ones(nd,1);
for ii = 1:nd
    dirsigns(ii) = isAscendOrDescend(directions{ii});
end
if all(dirsigns)  % zeros correspond to invalid directions
    col = abs(col(:)) .* dirsigns; % Change COL to new valid one
    dirProvided = true;
else
    dirErr = 3;
end

%--------------------------------------------------------------------------
function tf = isAscendOrDescend(charFlag)
% Column char vectors and '' are not valid
tf = 0;
if isrow(charFlag)
    if strncmpi(charFlag,'ascend',numel(charFlag))
        tf = 1;
    elseif strncmpi(charFlag,'descend',numel(charFlag))
        tf = -1;
    end
end

%--------------------------------------------------------------------------
function [col,colProvided] = legacyParseCOL(col,n,in2)
% Keep old COL behavior, which allows for COL = [] to be a no-op.
colProvided = false;
if isnumeric(in2)
    in2 = double(in2);
    if ( ~isreal(in2) || numel(in2) ~= length(in2) || ...
            any(floor(in2) ~= in2) || any(abs(in2) > n) || any(in2 == 0) )
        error(message('MATLAB:sortrows:COLmismatchX'));
    end
    col = in2(:);       % Change COL to new valid one
    colProvided = true; % Valid COL provided
end

%--------------------------------------------------------------------------
function [missingFlag, comparisonFlag] = parseNV(A,missingFlag,comparisonFlag,nvStart,varargin)
for ii = nvStart:2:numel(varargin)
    if matlab.internal.math.checkInputName(varargin{ii},{'ComparisonMethod'})
        if ~isnumeric(A) && ~islogical(A) && ~ischar(A)
            error(message('MATLAB:sortrows:InvalidAbsRealType',class(A)));
        end
        expValues = {'auto','abs','real'};
        ind = matlab.internal.math.checkInputName(varargin{ii+1},expValues);
        if sum(ind) ~= 1
            % Also catch ambiguities between 'auto' and 'abs'
            error(message('MATLAB:sortrows:InvalidComparison'));
        end
        comparisonFlag = find(ind) - 1; % 0 for 'auto' ...
    elseif matlab.internal.math.checkInputName(varargin{ii},{'MissingPlacement'})
        if ~isnumeric(A) && ~islogical(A) && ~isstring(A)
            error(message('MATLAB:sortrows:InvalidFirstLastType',class(A)));
        end
        expValues = {'auto','first','last'};
        ind = matlab.internal.math.checkInputName(varargin{ii+1},expValues);
        if sum(ind) ~= 1
            error(message('MATLAB:sortrows:InvalidMissingPlace'));
        end
        missingFlag = find(ind) - 1; % 0 for 'auto' ...
    else
        error(message('MATLAB:sortrows:NameValueNames'));
    end
end