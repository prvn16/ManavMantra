function addlisteners(h)
%ADDLISTENERS  adds listeners to this object

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.

ed = DAStudio.EventDispatcher;
h.listeners = handle.listener(ed, 'PropertyChangedEvent', @(s,e)firepropertychange(h));

% [EOF]
