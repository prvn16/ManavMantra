function ax = getAxesInParent(parent, create)
% This function is undocumented and may change in a future release.

% This function will return the handle to an axes/chart in or equal to the 
% specified parent container (such as Figure, Tab, or Panel). 
% If the parent is a figure (or no parent is provided), then this function 
% is equivalent to gca. If an axes or PolarAxes is provided, this function 
% will return that axes.

%   Copyright 2015-2017 The MathWorks, Inc.

% Make sure we have a valid parent figure. This will create a figure if one
% does not already exist.
if nargin == 0 || isempty(parent) || ~ishghandle(parent)
    parent = gcf;
end

if nargin < 2
    create = true;
end

ax = [];

% Get the figure that contains the requested parent container and the
% current axes of that figure.
fig = ancestor(parent,'figure');
currentaxes = fig.CurrentAxes;

if isempty(currentaxes)
    % There are no axes in the figure, so create a new axes in the
    % specified parent container.
    
    if(create) 
        ax = axes('Parent',parent);
    end
elseif currentaxes.Parent == parent
    % The current axes of the figure is in the specified parent container,
    % so we can use that axes.
    ax = currentaxes;
else
    % The current axes of the figure is not in the specified parent
    % container, so we need to look to see if there are any existing axes
    % in that container.
    % include Chart subclasses as possible colorbar peers
    children = findobj(parent,'-regexp','Type','.*axes$','-or', ...
        '-class','matlab.graphics.chart.Chart');

    if isempty(children)
        % There are no axes in the parent, so create a new axes in the
        % specified parent container.
        if(create)
            ax = axes('Parent',parent);
        end
    else
        % There are axes in this parent container, use the first one in
        % the child order, which will be the last axes created.
        ax = children(1);
    end
end

end
