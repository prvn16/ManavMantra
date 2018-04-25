function t = doclink(map, key, txt)
% This function is undocumented and reserved for internal use.  It may be
% removed in a future release.

% Copyright 2007-2008 The MathWorks, Inc.

if matlab.internal.display.isHot
    t = sprintf('<a href="matlab: helpview([docroot ''%s''],''%s'')">%s</a>',...
                map, key, txt);
else
    t = txt;
end
