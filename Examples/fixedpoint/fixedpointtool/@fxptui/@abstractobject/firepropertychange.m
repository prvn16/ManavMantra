function firepropertychange(h)
%FIREPROPERTYCHANGE   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.

ed = DAStudio.EventDispatcher;
ed.broadcastEvent('PropertyChangedEvent', h);

% [EOF]
