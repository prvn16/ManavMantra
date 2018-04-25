function tf = issorted(tX, varargin)
%ISSORTED Determine whether array is sorted.
%   TF = ISSORTED(X)
%   TF = ISSORTED(X,DIM)
%   TF = ISSORTED(X,DIRECTION)
%   TF = ISSORTED(X,DIM,DIRECTION)
%   TF = ISSORTED(...,'ComparisonMethod',C)
%   TF = ISSORTED(...,'MissingPlacement',M)
%
%   Limitations:
%   Tall cell arrays of character vectors are not supported.
%
%   See also ISSORTED

%   Copyright 2016-2017 The MathWorks, Inc.

tall.checkIsTall(upper(mfilename), 1, tX);
tall.checkNotTall(upper(mfilename), 1, varargin{:});
% Tall/issorted does not support cellstr as issorted on cellstr does not
% support DIM.
if strcmp(tall.getClass(tX), 'cell')
    error(message('MATLAB:bigdata:array:SortCellUnsupported', upper(mfilename)));
end
tX = lazyValidate(tX, {@(x)~iscell(x), 'MATLAB:bigdata:array:SortCellUnsupported'});
tX = tall.validateType(tX, upper(mfilename), {...
    'numeric', 'logical', ...
    'string', 'char', ...
    'categorical', 'datetime', 'duration'}, 1);
[isRows, dim] = iParseInputs(tX, varargin{:});

if isRows
    tf = issortedInTallDim(@(x) issorted(x, 'rows'), tX);
    return;
end

if isnan(dim)
    caseTallDim = issortedInTallDim(@(x) issorted(x, 1, varargin{:}), tX);
    caseNonTallDim = aggregatefun(@(x) issorted(x, varargin{:}), @all, tX);
    tf = ternaryfun(size(tX,1) == 1, caseNonTallDim, caseTallDim);
elseif dim == 1
    tf = issortedInTallDim(@(x) issorted(x, varargin{:}), tX);
else
    tf = aggregatefun(@(x) issorted(x, varargin{:}), @all, tX);
end
tf.Adaptor = matlab.bigdata.internal.adaptors.getScalarLogicalAdaptor();

function tf = issortedInTallDim(issortedFunctionHandle, tX)
[~, tf] = aggregatefun(@(data) iCheckIfSorted(issortedFunctionHandle, data), ...
    @(data, isSorted) iCheckIfSorted(issortedFunctionHandle, data, isSorted), tX);
tf = all(tf);
tf.Adaptor = matlab.bigdata.internal.adaptors.getScalarLogicalAdaptor();

function [firstAndLastSlice, isSorted] = iCheckIfSorted(issortedFunctionHandle, data, isSorted)
% Check for each chunk whether that chunk is sorted. Also return the first
% and last slice so that further calls in the reducefun can check order
% between chunks.
if nargin < 3
    isSorted = true;
end

isSorted = all(isSorted) && feval(issortedFunctionHandle, data);

if size(data, 1) > 2
    firstAndLastSlice = matlab.bigdata.internal.util.indexSlices(data, [1; size(data, 1)]);
else
    firstAndLastSlice = data;
end
isSorted = repelem(isSorted, size(firstAndLastSlice, 1), 1);

function [isRows, dim] = iParseInputs(tX, varargin)
% Check inputs for syntax issues
try
    issorted([], varargin{:});
    
    dim = NaN;
    isRows = false;
    
    if ~isempty(varargin) && isequal(varargin{1}, 'rows')
        isRows = true;
        adaptor = tX.Adaptor;
        if ~isnan(adaptor.NDims) && adaptor.NDims >= 3
            error(message('MATLAB:issorted:MustBeMatrix'));
        end
    end
    
    if ~isempty(varargin) && isnumeric(varargin{1})
        dim = varargin{1};
    end
catch err
    throwAsCaller(err);
end
