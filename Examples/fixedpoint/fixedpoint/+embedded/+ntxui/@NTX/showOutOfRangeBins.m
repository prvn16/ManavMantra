function showOutOfRangeBins(ntx)
% Display out-of-range bin indicators when relevant

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $     $Date: 2013/09/10 10:00:56 $

h = ntx.hXRangeIndicators;

% Update out-of-range underflow
xUnder = (ntx.BinEdges(1) < ntx.XAxisDisplayMin);
if xUnder
    cdata = zeros(1,2,3); % 2 polygons, one RGB triple each
    clr = ntx.ColorUnderflowBar;
    cdata(1,1,:) = clr;
    cdata(1,2,:) = clr;
    set(h(1),'Visible','on','CData',cdata);
else
    if isgraphics(h(1))  %ishghandle(h(1))
        set(h(1),'Visible','off');
    end
end

% Update out-of-range overflow
xOver = (ntx.BinEdges(end) > ntx.XAxisDisplayMax);
if xOver
    clr = ntx.ColorOverflowBar;
    cdata(1,1,:) = clr;
    cdata(1,2,:) = clr;
    set(h(2),'Visible','on','CData',cdata);
else
    if isgraphics(h(2)) %ishghandle(h(2))
        set(h(2),'Visible','off');
    end
end
