function lims = getAxesLimits(ax)

lims = cell(numel(ax),1);
for i = 1:numel(ax)
    xlimits = ax(i).XLim;
    ylimits = ax(i).YLim;
    
    if ~is2D(ax(i))
        zlimits = ax(i).ZLim;
        lims{i} = {xlimits, ylimits, zlimits};
    else
        lims{i} = {xlimits, ylimits};
    end
end
