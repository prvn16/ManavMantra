function result = adddatadlg (ax, fig)
% This undocumented function may be removed in a future release.

% ADDDATADLG Show a dialog that asks the user to add a data trace to an axes.

% Copyright 2003-2015 The MathWorks, Inc.

narginchk(2,2)
if ischar(fig) && strcmp(fig,'isSupported')
    result = ~isa(ax,'matlab.graphics.axis.PolarAxes') && ...
        ~isprop(ax,'DatetimeDurationPlotAxesListenersManager');
else
    figpeer = javaGetFigureFrame(fig);
    jax = figpeer.getAxisComponent;    % a Java method
    javaMethodEDT('showInstance','com.mathworks.page.plottool.AddDataPanel',java(handle(ax)),jax);
end
