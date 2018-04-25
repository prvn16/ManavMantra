function figObj = middrag(figObj)
%FIGOBJ/MIDDRAG Drag figobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 



dragBin = figObj.DragObjects;
for aObjH = dragBin.Items;
   middrag(aObjH);
end
