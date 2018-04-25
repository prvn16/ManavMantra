function firepropertychange(this)
%FIREPROPERTYCHANGE 
%   OUT = FIREPROPERTYCHANGE(ARGS) <long description>

%   Copyright 2010 The MathWorks, Inc.

ed = DAStudio.EventDispatcher;
ed.broadcastEvent('PropertyChangedEvent', this);

% [EOF]
