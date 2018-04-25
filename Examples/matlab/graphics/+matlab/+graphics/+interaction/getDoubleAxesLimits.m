function lims = getDoubleAxesLimits(ax)

xlimits = ax.ActiveDataSpace.XLim;
ylimits = ax.ActiveDataSpace.YLim;
zlimits = ax.ActiveDataSpace.ZLim;
lims = [xlimits, ylimits, zlimits];
