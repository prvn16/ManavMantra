function hold(varargin)
%HOLD   Hold current graph
%   HOLD ON holds the current plot and all axis properties, including 
%   the current color and linestyle, so that subsequent graphing commands
%   add to the existing graph without resetting the color and linestyle.
%   HOLD OFF returns to the default mode whereby PLOT commands erase 
%   the previous plots and reset all axis properties before drawing 
%   new plots.
%   HOLD, by itself, toggles the hold state.
%   HOLD does not affect axis autoranging properties.
%
%   HOLD ALL is the same as HOLD ON. This syntax will be removed in 
%   a future release. Use HOLD ON instead.
%
%   HOLD(AX,...) applies the command to the Axes object AX.
%
%   Algorithm note:
%   HOLD ON sets the NextPlot property of the current figure and
%   axes to "add".
%   HOLD OFF sets the NextPlot property of the current axes to
%   "replace".
%
%   See also ISHOLD, NEWPLOT, FIGURE, AXES.

%   Copyright 1984-2015 The MathWorks, Inc.

% Parse possible Axes input
narginchk(0,2);

% look for leading axes (must not be a vector of handles)
[ax,args,nargs] = axescheck(varargin{:});

if isempty(ax)
    if nargs>0 && isa(args{1},'matlab.graphics.chart.Chart')         
        ax = args{1};
    else
        ax = gca;
    end    
end

if isa(ax,'matlab.graphics.chart.Chart')            
    error(message('MATLAB:hold:UnsupportedCurrentAxes',ax.Type));
end


matlab.graphics.internal.markFigure(ax);
fig = get(ax,'Parent');
if ~strcmp(get(fig,'Type'),'figure')
  fig = ancestor(fig,'figure');
end

if ~isempty(args)
    opt_hold_state = args{1};
end

nexta = get(ax,'NextPlot');
nextf = get(fig,'NextPlot');
hold_state = strcmp(nexta,'add') && strcmp(nextf,'add');

replace_state = 'replace';
if isa(ax,'matlab.ui.control.UIAxes')
    replace_state = 'replacechildren';
end

if(nargs == 0)
    if(hold_state)
        set(ax,'NextPlot',replace_state);
        disp(getString(message('MATLAB:hold:CurrentPlotReleased')));
    else
        set(fig,'NextPlot','add');
        set(ax,'NextPlot', 'add');
        disp(getString(message('MATLAB:hold:CurrentPlotHeld')));
    end
elseif(strcmp(opt_hold_state, 'on'))
    set(fig,'NextPlot','add');
    set(ax,'NextPlot','add');
elseif(strcmp(opt_hold_state, 'off'))
    set(ax,'NextPlot', replace_state);
elseif(strcmp(opt_hold_state, 'all'))
    set(fig,'NextPlot','add');
    set(ax,'NextPlot','add');
else
    error(message('MATLAB:hold:UnknownOption'));
end
