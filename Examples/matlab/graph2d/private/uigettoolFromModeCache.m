function h = uigettoolFromModeCache(hMode,tagname,fieldname)
% This method is undocumented and will be removed in a future release.

%   Copyright 2013 The MathWorks, Inc.

% Try to retrieve the toolbar button from the ModeStateData cache using
% the specified fieldname. If the toolbar button has not been cached or
% the cached value was deleted then reestablish the cached value with uigettool

try
    h = hMode.ModeStateData.(fieldname);
catch me
    if strcmp('MATLAB:nonExistentField',me.identifier) 
        h = [];
    else
        rethrow(me)
    end
end
if any(isempty(h)) || ~all(ishghandle(h))
    h = uigettool(hMode.FigureHandle,tagname);
    hMode.ModeStateData.(fieldname) = h;
end 