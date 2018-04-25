function firehierarchychanged(this)
%FIREHIERARCHYCHANGED <short description>
%   OUT = FIREHIERARCHYCHANGED(ARGS) <long description>

%   Copyright 2010-2012 The MathWorks, Inc.


ed = DAStudio.EventDispatcher;
ed.broadcastEvent('HierarchyChangedEvent', this)

% [EOF]
