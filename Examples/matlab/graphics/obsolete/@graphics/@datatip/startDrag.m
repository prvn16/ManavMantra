function down = startDrag(hThis,hFig)

%   Copyright 2014-2015 The MathWorks, Inc.

if nargout,
    down = @localMarkerButtonDownFcn;
else
    localMarkerButtonDownFcn(hThis.MarkerHandle,[],hThis,hFig);
end

function localMarkerButtonDownFcn(~,~,~,~)
