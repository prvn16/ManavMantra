function axReturn = newplot(hsave)
%NEWPLOT Prepares figure, axes for graphics according to NextPlot.
%   H = NEWPLOT returns the handle of the prepared axes.
%   H = NEWPLOT(HSAVE) prepares and returns an axes, but does not
%   delete any objects whose handles appear in HSAVE. If HSAVE is
%   specified, the figure and axes containing HSAVE are prepared
%   instead of the current axes of the current figure. If HSAVE is
%   empty, NEWPLOT behaves as if it were called without any inputs.
%
%   NEWPLOT is a standard preamble command that is put at
%   the beginning of graphics functions that draw graphs
%   using only low-level object creation commands. NEWPLOT
%   "does the right thing" in terms of determining which axes and/or
%   figure to draw the plot in, based upon the setting of the
%   NextPlot property of axes and figure objects, and returns a
%   handle to the appropriate axes.
%
%   The "right thing" is:
%
%   First, prepare a figure for graphics:
%   Clear and reset the current figure using CLF RESET if its NextPlot
%   is 'replace', or clear the current figure using CLF if its
%   NextPlot is 'replacechildren', or reuse the current figure as-is
%   if its NextPlot is 'add', or if no figures exist, create a figure.
%   When the figure is prepared, set its NextPlot to 'add', and then
%   prepare an axes in that figure:
%   Clear and reset the current axes using CLA RESET if its NextPlot
%   is 'replace', or clear the current axes using CLA if its NextPlot
%   is 'replacechildren', or reuse the current axes as-is if its
%   NextPlot is 'add', or if no axes exist, create an axes.
%
%   See also HOLD, ISHOLD, FIGURE, AXES, CLA, CLF.

%   Copyright 1984-2017 The MathWorks, Inc.
%   Built-in function.

if nargin == 0 || isempty(hsave)
    hsave = [];
elseif ~isscalar(hsave) || ~ishghandle(hsave)
    error(message('MATLAB:newplot:InvalidHandle'))
else
    % Make sure we have an object handle.
    hsave = handle(hsave);
end


fig = gobjects(0);
ax = gobjects(0);

if ~isempty(hsave)
    obj = hsave;
    while ~isempty(obj)
        if isgraphics(obj, 'figure')
            fig = obj;
        elseif isgraphics(obj, 'axes') || isgraphics(obj,'polaraxes')
            ax = obj;
        end
        obj = obj.Parent;
    end
end

if isempty(fig)
    fig = gcf;
end

fig = ObserveFigureNextPlot(fig, hsave);

% Set figure's NextPlot property to 'add' after obeying the previous setting.
fig.NextPlot = 'add';

checkNextPlot = true;
if isempty(ax)
    ax = gca(fig);
    if ~isa(ax,'matlab.graphics.axis.Axes')
        if isprop(ax,'NextPlot') && ishold(ax)
            error(message('MATLAB:newplot:HoldOnMixing'))
        else
            ax = matlab.graphics.internal.swapaxes(ax,@axes);
            
            % We just creaetd a new axes, no need to check NextPlot
            checkNextPlot = false;
        end
    end
elseif ~any(ishghandle(ax))
    error(message('MATLAB:newplot:NoAxesParent'))
end

if checkNextPlot
    ax = ObserveAxesNextPlot(ax, hsave);
end

if nargout
    axReturn = ax;
end



function fig = ObserveFigureNextPlot(fig, hsave)
%
% Helper fcn for preparing figure for nextplot, optionally
% preserving specific existing descendants.
% GUARANTEED to return a figure, even if some crazy combination
% of create / delete fcns deletes it.

switch fig.NextPlot
    case 'new'
        % if someone calls plot(x,y,'parent',h) and h is an axes
        % in a figure with NextPlot 'new', ignore the 'new' and
        % treat it as 'add' - just add the axes to that figure.
        if isempty(hsave)
            fig = figure;
        end
    case 'replace'
        clf(fig, 'reset', hsave);
    case 'replacechildren'
        clf(fig, hsave);
    case 'add'
        % nothing
end
if ~any(ishghandle(fig)) && isempty(hsave)
    fig = figure;
end

function ax = ObserveAxesNextPlot(ax, hsave)
%
% Helper fcn for preparing axes for nextplot, optionally
% preserving specific existing descendants
% GUARANTEED to return an axes in the same figure as the passed-in
% axes, even if that axes gets deleted by an overzealous create or
% delete fcn anywhere in the figure.

% for performance only call ancestor when needed
fig = ax.Parent;
if ~strcmp(fig.Type,'figure')
    fig = ancestor(fig,'figure');
end

switch ax.NextPlot
    case 'replaceall'
        cla(ax, 'reset', hsave);
    case 'replace'
        % If there are multiple data spaces, ax.prepareForPlot() will do a
        % reset of the properties for the active data space (while
        % preserving other data spaces) and return false to indicate that a
        % full reset is not necessary. Otherwise, ax.prepareForPlot() will
        % return true.
        if (ax.prepareForPlot())
            cla(ax, 'reset', hsave);
        else
            cla(ax, hsave);
        end
    case 'replacechildren'
        cla(ax, hsave);
    case 'add'
        % nothing
end

if ~any(ishghandle(ax)) && isempty(hsave)
    if ~any(ishghandle(fig))
        ax = axes;
    else
        ax = axes('Parent',fig);
    end
end
