function h = heatmap(varargin)
% HEATMAP Create heatmap chart
%   h = HEATMAP(tbl,xvar,yvar) creates a heatmap from the table tbl and
%   returns the HeatmapChart object. The xvar input indicates the table
%   variable to display along the x-axis. The yvar input indicates the
%   table variable to display along the y-axis. The default colors are
%   based on a count aggregation, which totals the number of times each
%   pair of x and y values appears together in the table. Use h to modify
%   the heatmap after it is created.
%
%   h = HEATMAP(tbl,xvar,yvar,'ColorVariable',cvar) uses the table variable
%   specified by cvar to calculate the color data. The default calculation
%   method is a mean aggregation.
%
%   h = HEATMAP(cdata) creates a heatmap from matrix cdata. The heatmap has
%   one cell for each value in cdata.
%
%   h = HEATMAP(xvalues,yvalues,cdata) specifies the labels for the values
%   that appear along the x-axis and y-axis.
%
%   h = HEATMAP(___,Name,Value) specifies additional options for the
%   heatmap using one or more name-value pair arguments. Specify the
%   options after all other input arguments.
%
%   h = HEATMAP(parent,___) creates the heatmap in the figure, panel, or
%   tab specified by parent.

%   Copyright 2016-2018 The MathWorks, Inc.

% Capture the input arguments and initialize the extra name/value pairs to
% pass to the HeatmapChart constructor.
args = varargin;
parent = gobjects(0);

% Check if the first input argument is a graphics object to use as parent.
if ~isempty(args) && isa(args{1},'matlab.graphics.Graphics')
    % heatmap(parent,___)
    parent = args{1};
    args = args(2:end);
end

% Check for the table vs. matrix syntax.
if isempty(args)
    error(message('MATLAB:narginchk:notEnoughInputs'));
elseif isa(args{1}, 'tabular')
    % Table syntax
    %   heatmap(tbl,xvar,yvar,Name,Value)
    [extraArgs, args] = parseTableInputs(args);
elseif isnumeric(args{1}) || (numel(args)>=3 && isnumeric(args{3}))
    % Matrix syntax
    %   heatmap(cdata,Name,Value)
    %   heatmap(xdata,ydata,cdata,Name,Value)
    [extraArgs, args] = parseMatrixInputs(args);
else
    error(message('MATLAB:graphics:heatmap:InvalidArguments'));
end

% Look for a Parent name-value pairs.
inds = find(strcmpi('Parent',args(1:2:end)));
if ~isempty(inds) && (inds(end)*2)<=numel(args)
    inds = inds*2-1;
    parent = args{inds(end)+1};
    args([inds inds+1]) = [];
end

% Look for a OuterPosition name-value pairs.
posArgsPresent = ~isempty(find(strcmpi('OuterPosition',args(1:2:end)),1));

% Build the full list of name-value pairs.
args = [extraArgs args];

% If position not specified, use replaceplot behavior
if ~posArgsPresent
    if ~isempty(parent)
        validateParent(parent);
    end
    % Construct the HeatmapChart.
    constructor = @(varargin) matlab.graphics.chart.HeatmapChart(varargin{:},args{:});
    try
        h = matlab.graphics.internal.prepareCoordinateSystem('matlab.graphics.chart.HeatmapChart',parent, constructor);
    catch e
        throw(e)
    end
else % Caller specified a position
    % Check parent argument if specified
    if isempty(parent)
        % If position specified, but not parent, assume current figure
        parent = gcf;
    else
        validateParent(parent);
    end
    
    % Construct heatmap without replacing gca
    try
        h = matlab.graphics.chart.HeatmapChart('Parent', parent, args{:});
    catch e
        throw(e)
    end
end

% Make the new heatmap the CurrentAxes
fig = ancestor(h,'figure');
if isscalar(fig)
    fig.CurrentAxes = h;
end

end

function [extraArgs, args] = parseTableInputs(args)
% Parse the table syntx:
%   heatmap(tbl,xvar,yvar,Name,Value)

import matlab.graphics.chart.internal.validateTableSubscript

% Three input arguments are required for the table syntax.
if numel(args)<3
    throwAsCaller(MException(message('MATLAB:graphics:heatmap:InvalidTableArguments')));
end

% Collect the first three input arguments.
tbl = args{1};
xvar = args{2};
yvar = args{3};
args = args(4:end);

% Validate the xvar table subscript.
[varname, xvar, err] = validateTableSubscript(tbl, xvar, 'XVariable');
if ~isempty(err)
    throwAsCaller(err);
elseif isempty(varname)
    throwAsCaller(MException(message('MATLAB:Chart:NonScalarTableSubscript', 'XVariable')));
end

% Validate the yvar table subscript.
[varname, yvar, err] = validateTableSubscript(tbl, yvar, 'YVariable');
if ~isempty(err)
    throwAsCaller(err);
elseif isempty(varname)
    throwAsCaller(MException(message('MATLAB:Chart:NonScalarTableSubscript', 'YVariable')));
end

% Build the name-value pairs for the table syntax.
extraArgs = {'SourceTable', tbl, 'XVariable', xvar, 'YVariable', yvar};

% Look for ColorVariable in the remaining name-value pairs.
inds = find(strcmpi('ColorVariable',args(1:2:end-1)));
p = properties('matlab.graphics.chart.HeatmapChart');
if ~isempty(inds)
    % Found a ColorVariable.
    inds = inds*2-1;
    cvar = args{inds(end)+1};
    
    % Validate the ColorVariable, but do not remove it from the list of
    % name-value pairs.
    [~, ~, err] = validateTableSubscript(tbl, cvar, 'ColorVariable');
    if ~isempty(err)
        throwAsCaller(err);
    end
elseif ~isempty(args) && ...
        ((~ischar(args{1}) && ~(isstring(args{1}) && isscalar(args{1})))...
        || ~ismember(args{1},p))
    % The fourth input argument is not a recognized property name. This
    % suggests it may be a table subscript meant to be the ColorVariable.
    % Check if the argument specified happens to refer to a single variable
    % in the table.
    [~, ~, err] = validateTableSubscript(tbl, args{1},'');
    if isempty(err)
        % The fourth input argument matches a single variable in the table,
        % generate error indicating the correct syntax.
        throwAsCaller(MException(message('MATLAB:graphics:heatmap:ColorVariableNameValuePair')));
    end
end

end

function [extraArgs, args] = parseMatrixInputs(args)
% Parse the matrix syntax:
%   heatmap(cdata,Name,Value)
%   heatmap(xdata,ydata,cdata,Name,Value)

import matlab.graphics.chart.HeatmapChart

% The first or third input is numeric, which leaves the following possible
% valid syntaxes:
% 1) heatmap(cdata)
% 2) heatmap(xdata,ydata,cdata,...)
% 3) heatmap(cdata,Name,Value,...)

% To avoid ambiguity between name-value pairs and xdata/ydata (2 and 3
% above), do not allow ydata to be a scalar string (or character vector)
% when both xdata and ydata are numeric scalars. Use name-value pairs to
% specify xdata and ydata if cdata is scalar.
% e.g. heatmap(1,'FontSize',12) could be interpretted such that 1 is cdata
% and 'FontSize' is the parameter in a name-value pair, or that 1 is xdata
% and 'FontSize' is the ydata. If the second argument looks like it could
% be a property name, always assume it is a name-value pair.
if isnumeric(args{1}) && (numel(args) == 1 || ...
        (numel(args)>=2 && ...
        (ischar(args{2}) || (isstring(args{2}) && isscalar(args{2})))))
    % The first input argument was numeric and either:
    % 1) Just one argument was supplied
    %    heatmap(cdata)
    % 2) 2+ arguments were supplied and the first and third were both
    % scalar while the second was a scalar string or character vector.
    %
    %   heatmap(cdata,Name,Value,...)
    if ~ismatrix(args{1})
        throwAsCaller(MException(message('MATLAB:graphics:heatmap:InvalidColorData')));
    end
    extraArgs = {'ColorData', args{1}};
    args = args(2:end);
elseif numel(args)>=3 && isnumeric(args{3})
    % The third input argument is numeric, so the first and second input
    % arguments must be xdata and ydata.
    %   heatmap(xdata,ydata,cdata,...)
    
    % Collect the first three input arguments.
    xdata = args{1};
    ydata = args{2};
    cdata = args{3};
    
    % Validate the cdata.
    if ~ismatrix(args{3})
        throwAsCaller(MException(message('MATLAB:graphics:heatmap:InvalidColorData')));
    end
    
    % Validate the xdata.
    [xdata, err] = HeatmapChart.validateXYData(xdata, 'x');
    if ~isempty(err)
        throwAsCaller(err);
    end
    
    % Validate the ydata.
    [ydata, err] = HeatmapChart.validateXYData(ydata, 'y');
    if ~isempty(err)
        throwAsCaller(err);
    end
    
    % Validate the size of xdata/ydata with respect to the cdata.
    [ny,nx] = size(cdata);
    if numel(xdata) ~= nx
        throwAsCaller(MException(message('MATLAB:graphics:heatmap:XDataMismatch')));
    end
    if numel(ydata) ~= ny
        throwAsCaller(MException(message('MATLAB:graphics:heatmap:YDataMismatch')));
    end
    
    % Build the name-value pairs for the matrix syntax.
    extraArgs = {'XData', xdata(:), 'YData', ydata(:), 'ColorData', cdata};
    args = args(4:end);
else
    throwAsCaller(MException(message('MATLAB:graphics:heatmap:InvalidArguments')));
end

end

function validateParent(parent)

if ~isa(parent, 'matlab.graphics.Graphics') || ~isscalar(parent)
    % Parent must be a valid scalar graphics object.
    throwAsCaller(MException(message('MATLAB:graphics:heatmap:InvalidParent')));
elseif ~isvalid(parent)
    % Parent cannot be a deleted graphics object.
    throwAsCaller(MException(message('MATLAB:graphics:heatmap:DeletedParent')));
elseif isa(parent,'matlab.graphics.axis.AbstractAxes')
    % HeatmapChart cannot be a child of Axes.
    throwAsCaller(MException(message('MATLAB:hg:InvalidParent',...
        'HeatmapChart', fliplr(strtok(fliplr(class(parent)), '.')))));
end

end
