function [b,varargout] = sort(a,varargin)
%SORT Sort a categorical array.
%   B = SORT(A) sorts categorical array A in ascending order.
%   The sorted categorical array B has the same categories and size as A:
%   - For vectors, SORT(A) sorts the elements of A in ascending order.
%   - For matrices, SORT(A) sorts each column of A in ascending order.
%   - For N-D arrays, SORT(A) sorts along the first non-singleton dimension.
%
%   B = SORT(A,DIM) also specifies a dimension DIM to sort along.
%
%   B = SORT(A,DIRECTION) and B = SORT(A,DIM,DIRECTION) also specify the
%   sort direction. DIRECTION must be:
%       'ascend'  - (default) Sorts in ascending order.
%       'descend' - Sorts in descending order.
%
%   B = SORT(A,...,'MissingPlacement',M) also specifies where to place the
%   missing elements (<undefined>) of A. M must be:
%       'auto'  - (default) Places missing elements last for ascending sort
%                 and first for descending sort.
%       'first' - Places missing elements (<undefined>) first.
%       'last'  - Places missing elements (<undefined>) last.
%
%   [B,I] = SORT(A,...) also returns a sort index I which specifies how the
%   elements of A were rearranged to obtain the sorted output B:
%   - If A is a vector, then B = A(I).  
%   - If A is an m-by-n matrix and DIM = 1, then
%       for j = 1:n, B(:,j) = A(I(:,j),j); end
%   The sort odering is stable. Namely, when more than one element has the
%   same value, the order of the equal elements is preserved in the sorted
%   output B and the indices I relating to equal elements are ascending.
%
%   See also ISSORTED, SORTROWS, UNIQUE.

%   Copyright 2006-2016 The MathWorks, Inc. 

import matlab.internal.categoricalUtils.categoricalsort;

acodes = a.codes;
nCategories = numel(a.categoryNames);

for ii = 1:(nargin-2) % ComparisonMethod not supported.
    if matlab.internal.math.checkInputName(varargin{ii},{'ComparisonMethod'})
        error(message('MATLAB:sort:InvalidAbsRealType',class(a)));
    end
end

try
    % SORT(A), SORT(A,DIM), SORT(A,DIRECTION), SORT(A,DIM,DIRECTION):
    noNVPairs = (nargin <= 2) || (nargin <= 3 && isnumeric(varargin{1}));

    if nCategories <= 5e5 && noNVPairs
        % Do faster CATEGORICALSORT for fewer than 500,000 categories:
        if nargin == 1
            [bcodes,varargout{1:nargout-1}] = categoricalsort(acodes,nCategories);
        else
            [bcodes,varargout{1:nargout-1}] = categoricalsort(acodes,nCategories,varargin{:});
        end
    else % Otherwise, dispatch to builtin SORT:
        defaultMissingPlace = true;
        if ~noNVPairs
            defaultMissingPlace = checkMissingPlacement(varargin{:});
        end
        if defaultMissingPlace
            % Make sure <undefined> sorts to the end when calling builtin SORT
            acodes(acodes == categorical.undefCode) = invalidCode(acodes);
            if nargin == 1
                [bcodes,varargout{1:nargout-1}] = sort(acodes);
            else
                [bcodes,varargout{1:nargout-1}] = sort(acodes,varargin{:});
            end
            bcodes(bcodes == invalidCode(bcodes)) = a.undefCode; % set invalidCode back to <undefined> code
        else
            % Treat <undefined> as 0 for 'descend'-'last' and 'ascend'-'first'
            % because the codes are unsigned integers.
            [bcodes,varargout{1:nargout-1}] = sort(acodes,varargin{:});
        end
    end
catch ME
    throw(ME);
end

b = a; % preserve subclass
b.codes = bcodes;

%--------------------------------------------------------------------------
function defaultMissingPlace = checkMissingPlacement(varargin)
%CHECKMISSINGPLACEMENT Check for non-default case of 'descend' and
% 'MissingPlacement' 'last', or 'ascend' and 'MissingPlacement' 'first'.

% SORT(A,VARARGIN) calls checkMissingPlacement(varargin{:}) and supports:
%   SORT(A,DIM,'MissingPlacement',V)
%   SORT(A,DIRECTION,'MissingPlacement',V)
%   SORT(A,DIM,DIRECTION,'MissingPlacement',V)
%   SORT(A,'MissingPlacement',V)

% varargin always has at least 1 element when we call this function
dimOffset = isnumeric(varargin{1});
doDescend = (1+dimOffset <= nargin) && ...
    matlab.internal.math.checkInputName(varargin{1+dimOffset},{'descend'});
dirOffset = doDescend || ((1+dimOffset <= nargin) && ...
    matlab.internal.math.checkInputName(varargin{1+dimOffset},{'ascend'}));
doFirst = false;
doLast = false;
for ii = (1+dimOffset+dirOffset):2:(nargin-1)
    if matlab.internal.math.checkInputName(varargin{ii},{'MissingPlacement'})
        doFirst = matlab.internal.math.checkInputName(varargin{ii+1},{'first'});
        doLast = matlab.internal.math.checkInputName(varargin{ii+1},{'last'});
    end
end
defaultMissingPlace = ~( (doDescend && doLast) || (~doDescend && doFirst) );