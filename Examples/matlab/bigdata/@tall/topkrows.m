function out = topkrows(tx, k, col, sortDirn)
%TOPKROWS  Top k sorted rows of a matrix, table, or timetable.
%    Supported syntaxes for tall array X:
%    Y = topkrows(X,K)
%    Y = topkrows(X,K,COL)
%    Y = topkrows(X,K,COL,DIRECTION)
% 
%    Supported syntaxes for tall table/timetable T:
%    Y = topkrows(T,K)
%    Y = topkrows(T,K,VARS)
%    Y = topkrows(T,K,VARS,DIRECTION)
% 
%    Limitations:
%    1) Multiple outputs are not supported.
%    2) The 'ComparisonMethod' name-value pair is not supported.
%    3) The 'RowNames' option for tables is not supported. 
%
%   See also: SORTROWS, TALL.

% Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,4);

% Check that k is a non-negative integer-valued scalar
validateattributes(k, ...
    {'numeric'}, {'real','scalar','nonnegative','integer'}, ...
    'topkrows', 'k')

isTallTable = istall(tx) && any(strcmp(tall.getClass(tx), {'table', 'timetable'}));

% Col list must be an integer-valued vector
colflag = false;
if nargin < 3
    if isTallTable
        col = getDefaultTableCols(tx);
    else
        col = [];
        colflag = true; % setting flag for all columns to true 
    end
else
    if isTallTable
        if isstring(col) || (ischar(col) && isrow(col)) || iscellstr(col)
            col = cellstr(col); % Ensure string supported for variable names
        elseif ~islogical(col) && ~isempty(col)
            iValidateCols(col, true); % Only support positive integer
        end
    else
        [tx, col] = iResolveMatrixCols(tx, col);
    end
end

if nargin < 4 || isempty(sortDirn) % allow empty strings to work as default
    % Default to descending order
    sortDirn = {'descend'};
end

% Validate direction has valid options
iValidateSortDirection(sortDirn, isTallTable);

validateSortrowsSyntax(@(x, varargin) topkrows(x, k, varargin{:}) , ...
    'MATLAB:table:topkrows:EmptyRowNames', ...
    'MATLAB:bigdata:array:SortrowsUnsupportedRowNames', ...
    tx, col, sortDirn);

% Call reducefun with correct function based on type
out = reducefun(@(x) iSelectTopKRows(x, k, col, sortDirn, colflag), tx);

% Output adaptor is always same type and small size as input. Try and
% deduce tall size (probably k).
TALL_DIM = 1;
out.Adaptor = topkReductionAdaptor(tx, k, TALL_DIM);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function col = getDefaultTableCols(tx)
if strcmp(tall.getClass(tx), 'table')
    col = subsref(tx, substruct('.', 'Properties', '.', 'VariableNames'));
else
    % For tall timetable, default is sort-by-time
    actualDimNames = subsref(tx, substruct('.', 'Properties', '.', 'DimensionNames'));
    col = actualDimNames(1);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function iValidateCols(col, istabular)
% Check that col is either [] or a valid index vector
if ~isequal(col,[]) && ...
        (~isnumeric(col) || ~isvector(col) || ~isreal(col) ...
        || any(floor(col)~=col) || any(col<1))
    if istabular
        error(message('MATLAB:table:topkrows:BadNumericVarIndices'));
    else
        error(message('MATLAB:topkrows:ColNotIndexVec'));
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tx, col] = iResolveMatrixCols(tx, col)
iValidateCols(col, false);
% Also, lazily check that none is out of range (need size of TX)
tx = lazyValidate(tx, {@(x) all(abs(col)<=size(x,2)), 'MATLAB:topkrows:ColNotIndexVec'});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sortDirn = iValidateSortDirection(sortDirn, istabular)
sortDirnStrs = {'descend','ascend'};
if istabular
    errID = 'MATLAB:table:topkrows:UnrecognizedMode';
else
    errID = 'MATLAB:topkrows:NumDirectionsFourth';
end

if ~isempty(sortDirn)
    if ischar(sortDirn)
        sortDirn = cellstr(sortDirn);
    elseif ~iscellstr(sortDirn)
        error(message(errID));
    end
    tf = ismember(lower(sortDirn(:)),sortDirnStrs);
    if ~all(tf)
        error(message(errID));
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = iSelectTopKRows(x, k, col, sortDirn, colflag)
% Function to run on each chunk, keeping at most k rows

if colflag
    col = 1:size(x,2);
end

out = topkrows(x,k,col,sortDirn);
end
