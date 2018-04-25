function h = getPointerWindow()
% This function is undocumented and will change in a future release
% This undocumented helper function is for internal use only.

%   Copyright 2013 The MathWorks, Inc.

% In Graphics Version 2, the PointerWindow Property has been deprecated. 
% This function uses a workaround to determine which Figure window is currently under
% the mouse pointer
% This function does not work for docked figures in Graphics Version 2   

% This does not account for Docked Figures.
pointerLocation = get(0,'PointerLocation');
figs = allchild(0);
h = 0;
for n = 1:numel(figs)
    figPos = getpixelposition(figs(n));
    if (pointerLocation(1) >= figPos(1)) && ...
            (pointerLocation(1) <= figPos(1) + figPos(3)) && ...
            (pointerLocation(2) >= figPos(2)) && ...
            (pointerLocation(2) <= figPos(2) + figPos(4))
        h = figs(n);
        return;
    end
end
end
