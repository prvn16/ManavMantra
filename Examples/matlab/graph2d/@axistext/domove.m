function aObj = domove(aObj, pointX, pointY, refresh)
%AXISTEXT/DOMOVE Move axistext object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

savedState = get(aObj, 'SavedState');

pos = get(aObj,'Position');

switch get(aObj,'DragConstraint')
case ''
   pos(1) = (pointX - savedState.OffsetX);
   pos(2) = (pointY - savedState.OffsetY);
case 'fixX'
   pos(2) = (pointY - savedState.OffsetY);
case 'fixY'
   pos(1) = (pointX - savedState.OffsetX);
end

aObj = set(aObj,'Position',pos);
