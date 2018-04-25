function axesDestroyed(hSrc, ~)
% This function is undocumented and will change in a future release

%   Copyright 2010-2014 The MathWorks, Inc.

%   Callback when axes destroyed
	ax = hSrc;
	p = get(ax, 'Parent');
	if ~isempty(p) && isvalid(p)
		if strcmp(get(p, 'BeingDeleted'), 'off')
			matlab.graphics.internal.removeAxesFromGrid(p, ax);
		elseif isappdata(p, 'SubplotGrid')
			rmappdata(p, 'SubplotListenersManager');
			rmappdata(p, 'SubplotGrid');
		end
	end
end