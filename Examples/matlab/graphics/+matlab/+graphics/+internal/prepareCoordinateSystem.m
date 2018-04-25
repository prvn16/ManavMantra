function ax = prepareCoordinateSystem(kind, parent, constructor)
% This is an undocumented function and may be removed in a future release.

%   Copyright 2015-2017 The MathWorks, Inc.

% Agruments:
%  kind: classname of chart/axes to be created 
%     ('polar' accepted as shorthand for PolarAxes)
%
%  parent: parent container for axes/chart
%
%  constructor (optional for polar axes): function handle for 
%     chart/axes constructor function, prepending varargin to 
%      any user-supplied arguments

narginchk(1,3);
if nargin == 1
    parent = [];
end
if nargin == 3
    cls = kind;
else 
    if strcmp(kind, 'polar')
        constructor = @polaraxes;
        cls = 'matlab.graphics.axis.PolarAxes';
    end
end

if isempty(parent) || ~isgraphics(parent)
    fig = figureNextPlot(gcf);
    ca = fig.CurrentAxes;
    if ~isempty(ca)
        parent = ca.Parent;
    else
        parent = fig;
    end
end
%by this point, parent is a valid container

isChart = any(ismember(superclasses(kind),'matlab.graphics.chart.Chart'));
isInnerPositionable = ~isChart || any(ismember(superclasses(kind),'matlab.graphics.chart.internal.SubplotPositionableChart'));

%find
cax = matlab.graphics.chart.internal.getAxesInParent(parent, false);


% no current axes or no existing axes in parent container
if isempty(cax) 
    ax = constructor('Parent',parent);
    
%outgoing axes is same Axes type as new axes(no replacement needed)
elseif isa(cax, cls) && ~isa(cax,'matlab.graphics.chart.Chart')
    ax = cax;
    
%outgoing axes is Cartesian or Polar with hold on
elseif isa(cax, 'matlab.graphics.axis.AbstractAxes') && ishold(cax) 
    if strcmp(kind,'polar')
        error(message('MATLAB:newplot:HoldOnMixingPolar'));
    else
        cname = strsplit(kind,'.');
        error(message('MATLAB:newplot:HoldOnMixingAxesGeneric',cname{end}, cax.Type));
    end
else
    %outgoing "axes" is an abstractaxes with hold off, or is a chart
     ax = matlab.graphics.internal.swapaxes(cax, constructor, isInnerPositionable);
end


function fig = figureNextPlot(fig)
% based on figureNextPlot from newplot
switch fig.NextPlot
    case 'new'
        fig = figure;
    case 'replace'
        clf(fig, 'reset');
    case 'replacechildren'
        clf(fig);
    case 'add'
        % nothing
end
if ~any(isgraphics(fig))
    fig = figure;
end
