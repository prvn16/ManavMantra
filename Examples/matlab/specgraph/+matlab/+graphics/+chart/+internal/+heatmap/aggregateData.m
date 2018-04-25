function [xData, yData, colorData, counts] = aggregateData(...
    tbl, xVariable, yVariable, colorVariable, colorMethod)
% This is an undocumented function and may be removed in a future release.

% Aggregate the data from the table using the variables specified in xvar,
% yvar, and colorvar, and the method specified in method. xvar, yvar, and
% colorvar are assumed to either be empty or to have already been validated
% and be a character vector that refers to a single column in the table.

%   Copyright 2016-2017 The MathWorks, Inc.

% Generate a categorical vector from the xVariable.
xGroups = getCategoricalFromTable(tbl, xVariable);

% Generate a categorical vector from the yVariable.
yGroups = getCategoricalFromTable(tbl, yVariable);

% Read the colorVariable from the table.
if ~isempty(colorVariable)
    v = tbl.(colorVariable);
    assert((isnumeric(v) || islogical(v)) && isreal(v), ...
        message('MATLAB:graphics:heatmap:InvalidColorVariable'));
else
    % No colorVariable specified, create an empty numeric vector.
    v = zeros(0,1);
end

% Convert the xGroups and yGroups into indices that can be passed into
% accumarray.
x = uint64(xGroups);
y = uint64(yGroups);

% Read the categories from the xGroups and yGroups.
xData = string(categories(xGroups));
yData = string(categories(yGroups));

% Determine how big the output colorData should be.
n = numel(xData);
m = numel(yData);

% Make sure empty xData and yData are column vectors.
if n == 0
    xData = string.empty(0,1);
end
if m == 0
    yData = string.empty(0,1);
end

% If either x or y is empty, create an empty colorData matrix with the
% correct dimensions (e.g. [0 x 3] or [4 x 0]).
if isempty(x) || isempty(y)
    counts = zeros(m,n);
    colorData = counts;
    return
end

% Remove missing data.
missing = (x == 0 | y == 0);
if ~isempty(v)
    missing = (missing | isnan(v));
end
x = x(~missing);
y = y(~missing);
if ~isempty(v)
    v = v(~missing);
end

% Count how many times each pair of xGroup and yGroup occurs in the data.
counts = accumarray([y,x],1,[m,n]);

% Perform the actual aggregation using accumarray.
switch colorMethod
    case 'none'
        % Make sure that no pair of groups is represented more than once.
        assert(all(counts(:)<=1), message('MATLAB:graphics:heatmap:DuplicateDataWithNone'));
        assert(~isempty(colorVariable), message('MATLAB:graphics:heatmap:NoColorVariable', 'none'));
        colorData = accumarray([y,x],v,[m,n],@sum,NaN);
    case 'count'
        colorData = counts;
    case 'mean'
        assert(~isempty(colorVariable), message('MATLAB:graphics:heatmap:NoColorVariable', 'mean'));
        colorData = accumarray([y,x],v,[m,n],@mean,NaN);
    case 'median'
        assert(~isempty(colorVariable), message('MATLAB:graphics:heatmap:NoColorVariable', 'median'));
        colorData = accumarray([y,x],v,[m,n],@median,NaN);
        colorData = double(colorData);
    case 'min'
        assert(~isempty(colorVariable), message('MATLAB:graphics:heatmap:NoColorVariable', 'min'));
        colorData = accumarray([y,x],v,[m,n],@min,NaN);
        colorData = double(colorData);
    case 'max'
        assert(~isempty(colorVariable), message('MATLAB:graphics:heatmap:NoColorVariable', 'max'));
        colorData = accumarray([y,x],v,[m,n],@max,NaN);
        colorData = double(colorData);
    case 'sum'
        assert(~isempty(colorVariable), message('MATLAB:graphics:heatmap:NoColorVariable', 'sum'));
        colorData = accumarray([y,x],v,[m,n],@sum);
end

end

function data = getCategoricalFromTable(tbl, varName)
% Retrieve the specified variable from the table and convert to categorical
% if necessary.

if isempty(varName)
    % No variable specified, create an empty categorical vector.
    data = categorical.empty(0,1);
else
    % Get the data from the table variable.
    data = tbl.(varName);
    
    % Convert a character matrix into a string vector.
    if ischar(data)
        data = string(data);
    end
    
    % Convert the data into a categorical vector.
    if ~iscategorical(data)
        try
            data = categorical(data);
        catch catErr
            msgID = 'MATLAB:graphics:heatmap:InvalidCategoricalData';
            
            switch catErr.identifier
                case 'MATLAB:categorical:UndefinedLabelCategoryName'
                    msgID = 'MATLAB:graphics:heatmap:MissingValueIndicatorInData';
                case 'MATLAB:categorical:CantCreateCategoryNames'
                    if isnumeric(data)
                        msgID = 'MATLAB:graphics:heatmap:NonDiscretizedData';
                    end
            end
            err = MException(message(msgID, varName));
            throwAsCaller(addCause(err, catErr));
        end
    end
end

end
