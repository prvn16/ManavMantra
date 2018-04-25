function aObj = domove(aObj, pointX, pointY, refresh)
%AXISOBJ/DOMOVE Move axisobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2003 The MathWorks, Inc.

savedState = get(aObj, 'SavedState');

switch savedState.DragConstraint
case ''
   pos = get(aObj,'Position');
   newX = pos(1) + (pointX-pos(1) - savedState.OffsetX);
   newY = pos(2) + (pointY-pos(2) - savedState.OffsetY);
   pos(1:2) = [newX newY];
   aObj = set(aObj,'Position',pos);
case 'fixX'
case 'fixY'
end
