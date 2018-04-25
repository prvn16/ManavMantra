function aObj = enddrag(aObj)
%AXISOBJ/ENDDRAG End axisobj drag
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

savedState = get(aObj, 'SavedState');
set(aObj,'Units',savedState.myOldUnits);


