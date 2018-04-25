function [B,I] = sortrows(A,varargin)
%SORTROWS Sort rows of a matrix.
%   B = SORTROWS(A) sorts the rows of matrix A in ascending order as a
%   group. B has the same size and type as A. A must be a 2-D matrix.
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
%   the missing elements (NaN/NaT/<undefined>/<missing>) of A. M must be:
%       'auto'  - (default) Places missing elements last for ascending sort
%                 and first for descending sort.
%       'first' - Places missing elements first.
%       'last'  - Places missing elements last.
%
%   B = SORTROWS(A,...,'ComparisonMethod',C) specifies how to sort complex
%   numbers. The comparison method C must be:
%       'auto' - (default) Sorts real numbers according to 'real', and
%                complex numbers according to 'abs'.
%       'real' - Sorts according to REAL(A). Elements with equal real parts
%                are then sorted by IMAG(A).
%       'abs'  - Sorts according to ABS(A). Elements with equal magnitudes
%                are then sorted by ANGLE(A).
%
%   [B,I] = SORTROWS(A,...) also returns an index vector I which describes
%   the order of the sorted rows, namely, B = A(I,:).
%
%   Examples:
%     % Sort rows as a group in ascending and descending order
%       A = [1 2 3; 0 7 8; 1 1 1; 5 2 0; 1 2 2]
%       B = sortrows(A)
%       C = sortrows(A,'descend')
%     % Sort rows in ascending order according to column 2
%       A = [8 3; 7 1; 6 2]
%       B = sortrows(A,2)
%
%   See also ISSORTEDROWS, SORT, UNIQUE.

%   Copyright 1984-2016 The MathWorks, Inc. 

if (nargin == 1) && canCallBuiltinHelper(A,size(A,2))
    % One numeric input (no need to parse optional inputs):
    I = matlab.internal.math.sortrowsHelper(A);
else
    [col, nanflag, compareflag] = matlab.internal.math.sortrowsParseInputs(A,varargin{:});
    if ~iscell(A)
        if canCallBuiltinHelper(A,numel(col))
            I = matlab.internal.math.sortrowsHelper(A, col, nanflag, compareflag);
        else
            I = sortBackToFront(A, col, nanflag, compareflag);
        end
    else
        I = sortBackToFrontCell(A, col);
    end
end

B = A(I,:); % Permute rows into sorted order

if isempty(A) && (size(A,1) == size(A,2))
    B = reshape(B,[0 0]);
    I = reshape(I,[0 0]);
end

%--------------------------------------------------------------------------
function tf = canCallBuiltinHelper(A,numCol)
% Call builtin helper for real numeric with more than 3 columns,
% and for all complex numeric.
tf = (isnumeric(A) || ischar(A) || islogical(A)) && ...
    ~isobject(A) && ~issparse(A) && (numCol > 3 || ~isreal(A));
%--------------------------------------------------------------------------
function I = sortBackToFront(A, col, nanflag, compareflag)
% Sorts each column starting with the last one
n = numel(col);
I = (1:size(A,1))';
if isnumeric(A) && ~isreal(A) && compareflag == 0
    % Insist on using 'abs' instead of 'auto' for complex because
    % A(:, abs(col)) turns complex with 0 imaginary parts into real.
    compareflag = 1;
end
if nanflag == 0 && compareflag == 0
    opts = {};
else
    compareOptions = {'auto','abs','real'};
    missingOptions = {'auto','first','last'};
    opts = {'ComparisonMethod', compareOptions{compareflag+1},...
            'MissingPlacement', missingOptions{nanflag+1}};
    if ischar(A)
        % char sortrows with missing placement errors before we get here
        opts = opts(1:2);
    end
    if isstring(A)
        opts = opts(3:4);
    end
end
directions = {'ascend' 'descend'};
for k = n:-1:1
    ck = col(k);
    [~,ind] = sort(A(I,abs(ck)),directions{(ck < 0) + 1},opts{:});
    I = I(ind);
end
%--------------------------------------------------------------------------
function I = sortBackToFrontCell(A, col)
n = numel(col);
I = (1:size(A,1))';
if ~isempty(A)
    directions = {'ascend' 'descend'};
    for k = n:-1:1
        ck = col(k);
        ack = abs(ck);
        if isnumeric(A{1,ack})
            if ~all(cellfun(@isscalar,A(I,ack)))
                error(message('MATLAB:sortrows:nonScalarCell'));
            end
            [~,ind] = sort(cell2mat(A(I,ack)),directions{(ck < 0) + 1});
        else
            tmp = matlab.internal.math.cellstrpad(A(I,ack));
            ind = matlab.internal.math.sortrowsHelper(tmp, sign(ck)*(1:size(tmp,2)), 0, 0);
        end
        I = I(ind);
    end
end