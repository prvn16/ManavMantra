function b = isUnderLinkedLibrary(h)
% Return true if the block is under a linked library.This is same as the method defined
% in SimulinkFixedPoint.AbstractEntityAutoscaler.isUnderLinkedLibrary

%   Copyright 2009 The MathWorks, Inc.

b = false;
% If h is a model node, then return.
curParent = h.daobject.parent;
if isempty(curParent); return; end
% If a block is under a library link or is a library link, then the LinkStatus will be 
% either implicit or resolved. When the link is disabled, the LinkStatus will be either none or inactive.
if any(strcmp(get_param(h.daobject.getFullName,'LinkStatus'), {'resolved','implicit'}))
    b = true;
end

