function off = isBrushBehaviorOff(ax)
%isBrushBehaviorOff Test if brush behavior is off

%  Copyright 2015 The MathWorks, Inc.

off = false;
b = hggetbehavior(ax,'Brush','-peek');
if ~isempty(b)
    off = ~b.Enable;
end
