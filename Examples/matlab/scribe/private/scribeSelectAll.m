function scribeSelectAll(fig)

% Find and select all the scribe objects in a figure

%  Copyright 2010-2014 The MathWorks, Inc.

% Find scribe layer
[scribeax, child_scribeaxes] = graph2dhelper('findAllScribeLayers',fig);
scribeax = [scribeax; child_scribeaxes];
  
% Make a list of scribe objects
shapes = [];
scribeAxesExists = false;
for k=1:length(scribeax)
    if ((isobject(scribeax(k)) && isvalid(scribeax(k))) || ....       
        (any(ishghandle(scribeax(k))) && ~strcmpi(get(scribeax(k),'BeingDeleted'),'on')))
        scribeChildren = get(scribeax(k),'Children');
        if isempty(shapes)
            shapes = scribeChildren(:);
        else
            shapes = [shapes(:);scribeChildren(:)];
        end
        scribeAxesExists = true;
    end
end

if scribeAxesExists
    ax = findobj(get(fig,'Children'),'flat','type','axes');
    if ~isempty(ax)
        axNonData = true(1,length(ax));
        for k=length(ax):-1:1
           axNonData(k) = isappdata(ax(k),'NonDataObject');
        end
        ax(axNonData) = [];
    end

    if ~isempty(shapes)
      selectobject([shapes;ax],'replace');
    else
      selectobject(ax,'replace');
    end
end
