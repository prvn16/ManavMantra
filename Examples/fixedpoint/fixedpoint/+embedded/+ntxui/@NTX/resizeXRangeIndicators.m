function resizeXRangeIndicators(ntx)
% Adjust the x-position of the Under indicator
% Nothing else is needed here

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $     $Date: 2013/09/10 10:00:53 $

hUnder = ntx.hXRangeIndicators(1);

if isgraphics(hUnder) %ishghandle(hUnder)
    % Get x-extend from main axes position
    haxPosPix = get(ntx.hHistAxis,'Position');
    x2_ax = haxPosPix(1)+haxPosPix(3)-1; % last x-pixel in main axis
    Nx=40; Ny=30;
    hUnderAx = get(hUnder,'Parent');
    set(hUnderAx,'Position',[x2_ax-Nx+1 2 Nx Ny]);
end
