function [tY, idx] = sortrows(tX, varargin) %#ok<STOUT>
%SORTROWS  Sort rows in ascending order.
%   Supported syntaxes for tall array X:
%   Y = SORTROWS(X)
%   Y = SORTROWS(X,COL)
%   Y = SORTROWS(X,DIRECTION)
%   Y = SORTROWS(X,COL,DIRECTION)
%   Y = SORTROWS(X,...,'ComparisonMethod',C)
%   Y = SORTROWS(X,...,'MissingPlacement',M)
%
%   Supported syntaxes for tall table/timetable T:
%   Y = SORTROWS(T,VARS)
%   Y = SORTROWS(T,VARS,DIRECTION)
%
%   Limitations:
%   1) Multiple output is not supported.
%   2) Sorting by row names is not supported.
%
%   See also SORTROWS, TABLE/SORTROWS, TALL.

%   Copyright 2016-2017 The MathWorks, Inc.

if nargout >= 2
    error(message('MATLAB:bigdata:array:UniqueSortSingleOutput', upper(mfilename)));
end

tall.checkIsTall(upper(mfilename), 1, tX);
tall.checkNotTall(upper(mfilename), 1, varargin{:});

validateSortrowsSyntax(@sortrows, ...
    'MATLAB:table:sortrows:EmptyRowNames', ...
    'MATLAB:bigdata:array:SortrowsUnsupportedRowNames', ...
    tX, varargin{:});

sortFunctionHandle = @(x) sortrows(x, varargin{:});
tY = sortCommon(sortFunctionHandle, tX);
