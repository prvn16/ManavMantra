function flag = hasuimode(hThis,name)
% This function is undocumented and will change in a future release

%HASUIMODE Returns whether a mode exists for the given mode.
%   FLAG = ISMODE(MODE,NAME) will evaluate to true if the mode with the
%   unique name specified by NAME exists in the figure MODE.

%   Copyright 2013 The MathWorks, Inc.

hMode = getuimode(hThis,name);
flag = ~isempty(hMode);