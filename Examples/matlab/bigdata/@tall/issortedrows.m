function tf = issortedrows(tX, varargin)
%ISSORTED Determine whether array is sorted by rows.
%   Supported syntaxes for tall array X:
%   TF = ISSORTEDROWS(X)
%   TF = ISSORTEDROWS(X,COL)
%   TF = ISSORTEDROWS(X,DIRECTION)
%   TF = ISSORTEDROWS(X,...,'ComparisonMethod',C)
%   TF = ISSORTEDROWS(X,...,'MissingPlacement',M)
%
%   Supported syntaxes for tall table/timetable T:
%   TF = ISSORTEDROWS(T,VARS)
%   TF = ISSORTEDROWS(T,VARS,MODE)
%
%   See also ISSORTEDROWS

%   Copyright 2016-2017 The MathWorks, Inc.

tall.checkIsTall(upper(mfilename), 1, tX);
tall.checkNotTall(upper(mfilename), 1, varargin{:});
tX = tall.validateType(tX, upper(mfilename), {...
    'table', 'timetable', ...
    'numeric', 'logical', ...
    'string', 'char', ...
    'categorical', 'datetime', 'duration'}, 1);

if isa(tX.Adaptor, 'matlab.bigdata.internal.adaptors.TabularAdaptor')
    iCheckTabularInput(tX, varargin{:});
else
    iCheckGenericInput(tX, varargin{:});
end

issortedFunctionHandle = @(x) issortedrows(x, varargin{:});
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

function iCheckTabularInput(tT, varargin)
% Check the inputs against adaptor information for table types
try
    actualVarNames = subsref(tT, substruct('.', 'Properties', '.', 'VariableNames'));
    actualDimNames = subsref(tT, substruct('.', 'Properties', '.', 'DimensionNames'));
    samples = repmat({zeros(0, 1)}, size(actualVarNames));
    if strcmp(tall.getClass(tT), 'timetable')
        sample = timetable(datetime.empty(0, 1), samples{:}, 'VariableNames', actualVarNames);
    else
        sample = table(samples{:}, 'VariableNames', actualVarNames);
    end
    sample.Properties.DimensionNames = actualDimNames;
    
    issortedrows(sample, varargin{:});
catch err
    throwAsCaller(err);
end
function iCheckGenericInput(tX, varargin)
% Check the inputs against adaptor information for non-table types
try
    adaptor = tX.Adaptor;
    if ~isnan(adaptor.NDims) && adaptor.NDims > 2
        error(message('MATLAB:issortedrows:MustBeMatrix'));
    end
    
    numColsForSample = adaptor.getSizeInDim(2);
    if isnan(numColsForSample)
        if nargin>1 && (isnumeric(varargin{1}) || iscell(varargin{1}))
            % Assume that the second input is a variable list
            numColsForSample = numel(varargin{1});
        else
            numColsForSample = 1;
        end
    end
    
    issortedrows(1:numColsForSample, varargin{:});
catch err
    throwAsCaller(err);
end
