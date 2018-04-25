function axesUnitsPostSet(~, evdata)
% This function is undocumented and will change in a future release

%   Copyright 2010-2014 The MathWorks, Inc.

%   Callback when axes done changing units
	ax = evdata.AffectedObject;
	p = get(ax, 'Parent'); 
    if isvalid(p)
        lm = getappdata(p,'SubplotListenersManager');
        if ~isempty(lm)
            lm.enable();
        end
    end
end
        
