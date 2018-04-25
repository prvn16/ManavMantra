function createColorbars(hObj)
% Create the colorbars, set up their default configuration, and add them to
% the node tree.

% Copyright 2016 The MathWorks, Inc.

% Get a handle to the axes.
peerAx = hObj.Axes;

% Create a NullLayoutManager attached and attach it to the Axes.
matlab.graphics.chart.internal.NullLayoutManager(peerAx);

% Create the regular colorbar.
cbar = matlab.graphics.illustration.ColorBar;
cbar.Description = 'Heatmap Colorbar';

% Create the missing data colorbar.
mcbar = matlab.graphics.illustration.ColorBar;
mcbar.Description = 'Heatmap Missing Data Colorbar';
mcbar.Limits = [0 1];
mcbar.Ticks = 0.5;
mcbar.TickLabels = hObj.MissingDataLabel;
mcbar.Colormap = hObj.MissingDataColor;

% Mark both colorbars as internal.
cbar.Internal = true;
cbar.HitTest = 'off'; % Prevent plotedit mode from selecting colorbar.
mcbar.Internal = true;
mcbar.HitTest = 'off'; % Prevent plotedit mode from selecting colorbar.

% Set both colorbars to point units to simplify layout.
cbar.Units = 'points';
mcbar.Units = 'points';

% Set a default position in case the first update fails.
cbar.Position_I = [-1 -1 0 0];
mcbar.Position_I = [-1 -1 0 0];

% Set the ruler location. This sets the RulerLocationMode and stops
% colorbar's update from attempting to automatically determine the ruler
% location.
cbar.RulerLocation = 'right';
mcbar.RulerLocation = 'right';

% Set the interpreter for tick labels to none.
cbar.TickLabelInterpreter = 'none';
mcbar.TickLabelInterpreter = 'none';

% Insert the colorbars into the tree.
hObj.addNode(cbar);
hObj.addNode(mcbar);

% Set the colorbars' peers.
cbar.Axes = peerAx;
mcbar.Axes = peerAx;

% Store the handles to the colorbars.
hObj.Colorbar = cbar;
hObj.MissingDataColorbar = mcbar;

% dirty listeners not needed because we manage the colorbars in our update
mcbar.enableAxesDirtyListeners(false);
cbar.enableAxesDirtyListeners(false);

end
