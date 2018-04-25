function axesUnitsPreSet(~, evdata)
% This function is undocumented and will change in a future release

%   Copyright 2010-2014 The MathWorks, Inc.

%   Callback when axes changes units
	ax = evdata.AffectedObject;
	p = get(ax, 'Parent');
    if isvalid(p)
        lm = getappdata(p,'SubplotListenersManager');
        if ~isempty(lm)
            lm.disable();
        end
    end
 end
