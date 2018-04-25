function aObj = enddrag(aObj)
%ARROWLINE/ENDDRAG Finish dragging an arrowline
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

makearrow(aObj.arrowhead);
savedState = get(aObj, 'SavedState');

myH = get(aObj,'MyHandle');
set(myH,'EraseMode',savedState.EraseMode);

if get(aObj,'AutoDragConstraint')
   aObj = set(aObj,'OldDragConstraint','restore');
end
suffix = get(aObj,'Suffix');
if ~isempty(suffix)
   feval(suffix{1},myH,suffix{2:end});
end
