function plotdoneevent(parent,h)
% This internal helper function may change in a future release.

%PLOTDONEEVENT Send a plot event that a plot is finished
%    PLOTDONEEVENT(AX,H) sends plot event that objects H have been
%    added to axes AX.

%   Copyright 1984-2014 The MathWorks, Inc.

plotmgr = graph2dhelper('getplotmanager','-peek');
if isa(plotmgr, 'matlab.graphics.internal.PlotManager')
  evdata = matlab.graphics.internal.PlotEvent;
  evdata.ObjectsCreated = h;
  if ~isempty(parent)
    evData.Figure = ancestor(parent(1),'figure');
  end
  notify(plotmgr,'PlotFunctionDone',evdata);
end
