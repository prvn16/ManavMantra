function aObj = middrag(aObj)
%AXISCHILD/MIDDRAG Drag axischild
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

savedState = get(aObj,'SavedState');

pointer = get(savedState.Ax, 'CurrentPoint');
pointX = pointer(1,1);
pointY = pointer(1,2);

aObj = domove(aObj,pointX,pointY);


