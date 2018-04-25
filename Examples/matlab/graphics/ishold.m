function holdstate = ishold(ca)
%ISHOLD Return hold state.
%   ISHOLD returns 1 if hold is on, and 0 if it is off.
%   When HOLD is ON, the current plot and all axis properties
%   are held so that subsequent graphing commands add to the
%   existing graph.
%
%   ISHOLD(AX) returns the hold state of the axes specified by AX instead
%   of the current axes.
%
%   Hold on means the NextPlot property of both figure
%   and axes is set to "add".
%
%   See also HOLD, NEWPLOT, FIGURE, AXES.

%   Copyright 1984-2017 The MathWorks, Inc.

%ISHOLD(AXH) returns whether hold is on for the specified axis

if nargin<1
    cf = gcf;
    ca = get(cf,'currentaxes');
    if isempty(ca)
        holdstate = 0;
        return;
    end
else
    ca=ca(1);
    cf = ancestor(ca,'figure');
end

if isa(ca,'matlab.graphics.chart.Chart')
    error(message('MATLAB:hold:UnsupportedCurrentAxes',ca.Type));
end

holdstate = strcmp(get(ca,'nextplot'),'add') & ...
    strcmp(get(cf,'nextplot'),'add');
