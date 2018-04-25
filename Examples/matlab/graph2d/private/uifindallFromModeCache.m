function h = uifindallFromModeCache(hMode,tagname,fieldname)
% This method is undocumented and will be removed in a future release.

%   Copyright 2013 The MathWorks, Inc.

% Try to retrieve the menu from the ModeStateData cache using
% the specified fieldname. If the menu has not been cached or
% the cached value was deleted then reestablish the cached value with
% findall

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
    h = findall(hMode.FigureHandle,'Tag',tagname);
    hMode.ModeStateData.(fieldname) = h;
end 