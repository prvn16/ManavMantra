function setup(this,hVisParent)
% SETUP Setup the visual.

%   Copyright 2009-2017 The MathWorks, Inc.
    
% setupAxes(this,hVisParent);
% 
% set(this.Axes, 'Visible', 'off');

% Change the rendering mode on the figure to zbuffer so that zoom works
% correctly on patches within a uipanel.
set(this.Application.Parent,'Renderer','zbuffer');

% Create NTX
initNTX(this, hVisParent);

set(getVisibleHandles(this.NTExplorerObj), 'Visible', 'On');

% -------------------------------------------------------------------------
% [EOF]

