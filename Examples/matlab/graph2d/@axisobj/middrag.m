function aObj = middrag(aObj)
%AXISOBJ/MIDDRAG Drag axisobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

savedState = get(aObj,'SavedState');
pointer = get(savedState.Fig, 'CurrentPoint');

aObj = domove(aObj,pointer(1),pointer(2));
