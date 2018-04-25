function legendpostdeserialize(ax,~)
%LEGENDPOSTDESERIALIZE Post-deserialization hook for legend
%   Internal helper function for legend.

%   Deletes the supplied legend and creates a new one in the same
%   place so that all the state and listeners are properly created.

%   Copyright 1984-2017 The MathWorks, Inc.

hax = handle(ax);
leginfo = methods(hax,'postdeserialize');

set(ax, 'Axes', leginfo.ax);
%set(ax, 'PlotChildren', leginfo.plotchildren);
set(ax, 'Location', leginfo.loc);
if strcmpi(leginfo.loc,'none')
  set(ax, 'Units', 'points', 'Position', leginfo.position, 'Units', leginfo.units);
end

%Remove the invalid plotchildren
if ~isempty(leginfo.ax)
  plotchildren = [];
  strings = {};
  for i=1:min(length(hax.String),length(leginfo.plotchildren))
    if (ishandle(leginfo.plotchildren(i)))
      plotchildren(end+1) = leginfo.plotchildren(i);
      strings{end+1} = hax.String{i};
    end
  end
  set(ax, 'PlotChildren', plotchildren);
  set(ax, 'String', strings);
  
  %Delete the children of this legend and recreate them from the PlotChildren
  delete(hax.children);
  if ~isempty(hax.Plotchildren)
    methods(hax,'create_legend_items',hax.Plotchildren);
  end
end

hax.init();
methods(hax,'update_userdata');

% remove auto updating from plot axes once the legend is manually set
hAxes = hax.Axes;
lis = get(hAxes,'ScribeLegendListeners');
if ~isequal(get(hAxes,'FontName'),hax.FontName)
    lis.fontname = [];
end
if ~isequal(get(hAxes,'FontSize'),hax.FontSize)
    lis.fontsize = [];
end
if ~isequal(get(hAxes,'FontWeight'),hax.FontWeight)
    lis.fontweight = [];
end
if ~isequal(get(hAxes,'FontAngle'),hax.FontAngle)
    lis.fontangle = [];
end
if ~isequal(get(hAxes,'LineWidth'),hax.LineWidth)
    lis.linewidth = [];
end
set(hAxes,'ScribeLegendListeners',lis);
