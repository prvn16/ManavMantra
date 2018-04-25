function figObj = deselectall(figObj)
%FIGOBJ/DESELECTALL Deselect all for figobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

dragBin = figObj.DragObjects;
if ~isempty(dragBin.Items)
    for aObjH = fliplr(dragBin.Items);
        set(aObjH,'IsSelected',0);
    end
end