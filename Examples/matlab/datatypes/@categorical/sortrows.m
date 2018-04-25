function [b,varargout] = sortrows(a,varargin)
%SORTROWS Sort rows of a categorical array.
%   B = SORTROWS(A) sorts the rows of the 2-dimensional categorical matrix A in
%   ascending order as a group.  B is a categorical array with the same
%   categories as A.
%
%   B = SORTROWS(A,COL) sorts the matrix according to the columns specified
%   by the vector COL.  If an element of COL is positive, the corresponding
%   column in A is sorted in ascending order; if an element of COL is
%   negative, the corresponding column in A is sorted in descending order.
%   For example, SORTROWS(A,[2 -3]) first sorts the rows in ascending order
%   according to column 2; then, rows with equal entries in column 2 get
%   sorted in descending order according to column 3.
%
%   B = SORTROWS(A,DIRECTION) and B = SORTROWS(A,COL,DIRECTION) also
%   specify the sort direction(s). DIRECTION must be:
%       'ascend'  - (default) Sorts in ascending order.
%       'descend' - Sorts in descending order.
%   You can also use a different direction for each column by specifying
%   DIRECTION as a collection of 'ascend' and 'descend' directions. For
%   example, SORTROWS(X,[2 3],{'ascend' 'descend'}) first sorts rows in
%   ascending order according to column 2; then, rows with equal entries in
%   column 2 get sorted in descending order according to column 3.
%
%   B = SORTROWS(A,...,'MissingPlacement',M) also specifies where to place
%   the missing elements (<undefined>) of A. M must be:
%       'auto'  - (default) Places missing elements last for ascending sort
%                 and first for descending sort.
%       'first' - Places missing elements (<undefined>) first.
%       'last'  - Places missing elements (<undefined>) last.
%
%   [B,I] = SORTROWS(A,...) also returns an index vector I which describes
%   the order of the sorted rows, namely, B = A(I,:).
%
%   See also ISSORTEDROWS, SORT, UNIQUE.

%   Copyright 2006-2015 The MathWorks, Inc. 

import matlab.internal.categoricalUtils.categoricalsortrows;

acodes = a.codes;
nCategories = numel(a.categoryNames);

for ii = 1:(nargin-2) % ComparisonMethod not supported.
    if matlab.internal.math.checkInputName(varargin{ii},{'ComparisonMethod'})
        error(message('MATLAB:sortrows:InvalidAbsRealType',class(a)));
    end
end

try
    % SORTROWS(A), SORTROWS(A,COL):
    noNVPairs = (nargin <= 1) || (nargin <= 2 && isnumeric(varargin{1}));
    % CATEGORICALSORTROWS uses counting sort, which is fast only for uint8
    % and uint16 but slower than builtin SORTROWS for larger types
    if noNVPairs
        if isa(acodes, 'uint8') || isa(acodes, 'uint16')
            if nargin == 1
                [bcodes,varargout{1:nargout-1}] = categoricalsortrows(acodes,nCategories);
            else
                [bcodes,varargout{1:nargout-1}] = categoricalsortrows(acodes,nCategories,varargin{:});
            end
        else % acodes is 'uint32' or 'uint64'
            % Make sure <undefined> sorts to the end when calling builtin SORTROWS
            acodes(acodes == categorical.undefCode) = invalidCode(acodes);
            if nargin == 1
                [bcodes,varargout{1:nargout-1}] = sortrows(acodes);
            else
                [bcodes,varargout{1:nargout-1}] = sortrows(acodes,varargin{:});
            end
            bcodes(bcodes == invalidCode(bcodes)) = a.undefCode; % set invalidCode back to <undefined> code
        end
    else
        [col, nanflag] = matlab.internal.math.sortrowsParseInputs(acodes,varargin{:});
        if nanflag == 0 % 'auto'
            % Same as above: Make sure <undefined> sorts to the end when calling builtin SORT
            acodes(acodes == categorical.undefCode) = invalidCode(acodes);
            [bcodes,varargout{1:nargout-1}] = sortrows(acodes,varargin{:});
            bcodes(bcodes == invalidCode(bcodes)) = a.undefCode;
        else
            % 'first' treats <undefined> as 0 for 'ascend' and intmax for 'descend'
            % 'last' treats <undefined> as intmax for 'ascend' and 0 for 'descend'
            [~,colind] = unique(abs(col),'stable'); % legacy repetead COL behavior
            col = col(colind);
            undefmask = acodes == categorical.undefCode;
            if nanflag == 1 % 'first'
                undefmask(:,abs(col(col > 0))) = 0;
            else % 'last'
                undefmask(:,abs(col(col < 0))) = 0;
            end
            bcodes = acodes;
            acodes(undefmask) = invalidCode(acodes);
            [~,ndx] = sortrows(acodes,varargin{:});
            bcodes = bcodes(ndx,:);
            if nargout > 1
                varargout{1} = ndx;
            end
        end
    end
catch ME
    throw(ME);
end

b = a; % preserve subclass
b.codes = bcodes;
