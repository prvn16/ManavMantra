function children = gethchildren(h)
%GETHCHILDREN gets the wrappable subsystems beneath this node

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.

children = h.daobject.getHierarchicalChildren;
children = fxptui.filter(children);
% [EOF]
