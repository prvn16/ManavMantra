function aObj = enddrag(aObj)
%AXISCHILD/ENDDRAG End axischild drag
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2015 The MathWorks, Inc. 

if get(aObj,'AutoDragConstraint')
    aObj = set(aObj,'OldDragConstraint','restore');
end

suffix = get(aObj,'Suffix');
if ~isempty(suffix)
    myH = get(aObj,'MyHandle');
    feval(suffix{1},myH,suffix{2:end});
end
