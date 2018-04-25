function tf = issortedrows(A,varargin)
%ISSORTEDROWS   Check if matrix rows are sorted
%   TF = ISSORTEDROWS(A) returns TRUE if the rows of matrix A are sorted in
%   ascending order as a group, namely, returns TRUE if A and SORTROWS(A)
%   are identical. A must be a 2-D matrix of strings.
%
%   TF = ISSORTEDROWS(A,COL) checks if the rows are sorted according to the
%   columns specified by the vector COL.  If an element of COL is positive,
%   SORTROWS checks if the corresponding column in A is sorted in ascending
%   order; if an element of COL is negative, it checks if the corresponding
%   column in A is sorted in descending order. For example,
%   ISSORTEDROWS(A,[2 -3]) first checks if the rows are sorted in ascending
%   order according to column 2; then, checks if rows with equal entries in
%   column 2 are sorted in descending order according to column 3.
%
%   TF = ISSORTEDROWS(A,DIRECTION) and TF = ISSORTEDROWS(A,COL,DIRECTION)
%   check if the rows are sorted according to the specified direction:
%       'ascend'          - (default) Checks if data is in ascending order.
%       'descend'         - Checks if data is in descending order.
%       'monotonic'       - Checks if data is in either ascending or
%                           descending order.
%       'strictascend'    - Checks if data is in ascending order and does
%                           not contain duplicates.
%       'strictdescend'   - Checks if data is in descending order and does
%                           not contain duplicates.
%       'strictmonotonic' - Checks if data is either ascending or
%                           descending, and does not contain duplicates.
%   You can also use a different direction for each column specified by
%   COL, for example, ISSORTEDROWS(A,[2 3],{'ascend' 'descend'}).
%
%   TF = ISSORTEDROWS(A,...,'MissingPlacement',M) also specifies where
%   missing elements (<missing>) should be placed:
%       'auto'  - (default) Missing elements placed last for ascending sort
%                 and first for descending sort.
%       'first' - Missing elements placed first.
%       'last'  - Missing elements placed last.
%
%   See also SORTROWS, ISSORTED, SORT, UNIQUE.

%   Copyright 2016-2017 The MathWorks, Inc.

dirStrs = {'ascend','descend','monotonic','strictascend','strictdescend','strictmonotonic'};
[A, dirCodes, missingFlag] = parseInputs(A,varargin{:});

% Perform issortedrows check starting with the first specified column and
% moving on to the next one if ties are present:
tf = matlab.internal.math.issortedrowsFrontToBack(A,dirCodes,dirStrs,'MissingPlacement',missingFlag);

%--------------------------------------------------------------------------
function [A, dirCodes, missingFlag] = parseInputs(A,varargin)
if ~ismatrix(A)
    error(message('MATLAB:issortedrows:MustBeMatrix'));
end
%   ISSORTEDROWS(A) defaults:
n = size(A,2);
dirCodes = ones(n,1); % all 'ascend'
missingFlag = 'auto';

%   ISSORTEDROWS(A,COL)
%   ISSORTEDROWS(A,COL,DIR)
%   ISSORTEDROWS(A,COL,DIR,N1 ,V1 ,N2 ,V2 ,...)
%   ISSORTEDROWS(A,COL,N1 ,V1 ,N2 ,V2 ,...)
%   ISSORTEDROWS(A,DIR)
%   ISSORTEDROWS(A,DIR,N1 ,V1 ,N2 ,V2 ,...)
%   ISSORTEDROWS(A,N1 ,V1 ,N2 ,V2 ,...)
if nargin > 1
    % Look for a COL input
    in2 = varargin{1};
    [col,colProvided,dirCodes] = legacyParseCOL(dirCodes,n,in2);
    if 1+colProvided <= nargin-1
        % Look for a DIRECTION input
        [dirCodes,dirProvided,dirErr] = directions2columns(dirCodes,varargin{1+colProvided});
        nvStart = 1+colProvided+dirProvided;
        if rem(nargin-nvStart,2) == 0
            % Look for trailing Name-Value pairs
            missingFlag = parseNV(A,missingFlag,nvStart,varargin{:});
        else
            % Helpful error messages
            if dirErr == 1
                if ~colProvided
                    error(message('MATLAB:issortedrows:SecondArgumentType'));
                else % dirPosition == 2
                    error(message('MATLAB:issortedrows:ThirdArgumentType'));
                end
            elseif dirErr == 2
                if ~colProvided
                    error(message('MATLAB:issortedrows:NumDirectionsSecond'));
                else % dirPosition == 2
                    error(message('MATLAB:issortedrows:NumDirectionsThird'));
                end
            elseif dirErr == 3
                error(message('MATLAB:issortedrows:isSortedRowsMode'));
            end
            error(message('MATLAB:issortedrows:NameValuePairs'));
        end
    end
    if colProvided
        A = A(:,abs(col));
    end
end

%--------------------------------------------------------------------------
function [dirCodes,dirProvided,dirErr] = directions2columns(dirCodes,directions)
dirProvided = false;
dirErr = 0;
if ~ischar(directions) && ~iscellstr(directions) && ~isstring(directions)
    dirErr = 1;
    return
end
n = numel(dirCodes);
directions = string(directions);
nd = numel(directions);
% DIRECTIONS must be a scalar or a vector of length equal to numel COL.
if (nd ~= n && nd ~= 1) || ~isvector(directions)
    dirErr = 2;
    return
end
dirCodesTmp = zeros(nd,1);
for ii = 1:nd
    dirCodesTmp(ii) = isAscendOrDescend(directions{ii});
end
if all(dirCodesTmp)  % zeros correspond to invalid directions
    dirCodes = ones(n,1) .* dirCodesTmp;
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
        tf = 2;
    elseif strncmpi(charFlag,'monotonic',numel(charFlag))
        tf = 3;
    elseif strncmpi(charFlag,'strictascend',max(7,numel(charFlag)))
        tf = 4;
    elseif strncmpi(charFlag,'strictdescend',max(7,numel(charFlag)))
        tf = 5;
    elseif strncmpi(charFlag,'strictmonotonic',max(7,numel(charFlag)))
        tf = 6;
    end
end

%--------------------------------------------------------------------------
function [col,colProvided,dirCodes] = legacyParseCOL(dirCodes,n,in2)
% Keep old COL behavior, which allows for COL = [] to be a no-op.
if isnumeric(in2)
    in2 = double(in2);
    if ( ~isreal(in2) || numel(in2) ~= length(in2) || ...
            any(floor(in2) ~= in2) || any(abs(in2) > n) || any(in2 == 0) )
        error(message('MATLAB:issortedrows:ColMismatchX'));
    end
    col = in2(:);
    colProvided = true; % Valid COL provided
    dirCodes = ones(size(col)); % ascend
    dirCodes(col < 0) = 2; % descend
else
    col = (1:n)';
    colProvided = false;
end

%--------------------------------------------------------------------------
function [missingFlag] = parseNV(A,missingFlag,nvStart,varargin)
for ii = nvStart:2:numel(varargin)
    if matlab.internal.math.checkInputName(varargin{ii},{'ComparisonMethod'})
        % Complex comparison not supported
        error(message('MATLAB:issortedrows:InvalidAbsRealType',class(A)));
    elseif matlab.internal.math.checkInputName(varargin{ii},{'MissingPlacement'})
        expValues = {'auto','first','last'};
        ind = matlab.internal.math.checkInputName(varargin{ii+1},expValues);
        if sum(ind) ~= 1
            error(message('MATLAB:issortedrows:InvalidMissingPlace'));
        end
        missingFlag = expValues{ind};
    else
        error(message('MATLAB:issortedrows:NameValueNames'));
    end
end
