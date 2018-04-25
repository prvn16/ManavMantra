function [tY,idx] = sort(tX,varargin) %#ok<STOUT>
%SORT Sort in ascending or descending order.
%   Y = SORT(X,DIM)
%   Y = SORT(X,DIM,MODE)
%   Y = SORT(X,DIM,...,'ComparisonMethod',C)
%   Y = SORT(X,DIM,...,'MissingPlacement',M)
%
%   Limitations:
%   1) Multiple output is not supported.
%   2) SORT(X) is not supported.
%   3) SORT(X,1) is only supported for column vector X.
%
%   See also SORT

%   Copyright 2016-2017 The MathWorks, Inc.

if nargout >= 2
     error(message('MATLAB:bigdata:array:UniqueSortSingleOutput', upper(mfilename)));
end

tall.checkIsTall(upper(mfilename), 1, tX);
tall.checkNotTall(upper(mfilename), 1, varargin{:});

% Tall/sort does not support cellstr as sort on cellstr does not support DIM.
if strcmp(tall.getClass(tX), 'cell')
    error(message('MATLAB:bigdata:array:SortCellUnsupported', upper(mfilename)));
end
tX = lazyValidate(tX, {@(x)~iscell(x), 'MATLAB:bigdata:array:SortCellUnsupported'});

% Sort on every non-strong type apart from cell acts like double. As
% we disallow cell, we can validate parameters against the non-tall version
% of sort.
tall.validateSyntax(@sort, [{tX}, varargin], 'DefaultType', 'double');

if nargin == 1 || nargin >= 2 && ~isnumeric(varargin{1})
    error(message('MATLAB:bigdata:array:SortDimRequired'));
else
    dim = varargin{1};
end

sortFunctionHandle = @(x) sort(x, varargin{:});
if dim == 1
    tX = tall.validateColumn(tX, 'MATLAB:bigdata:array:SortMustBeColumn');
    tY = sortCommon(sortFunctionHandle, tX);
else
    tY = slicefun(sortFunctionHandle, tX);
    tY.Adaptor = tX.Adaptor;
end
