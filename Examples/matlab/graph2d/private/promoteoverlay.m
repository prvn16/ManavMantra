function promoteoverlay(fig)
%PROMOTEOVERLAY  Plot Editor helper function
%   Put the Scribe overlay axis back on top

%   Copyright 1984-2002 The MathWorks, Inc. 


axH=findall(fig,'type','axes');
if ~isempty(axH)
    overlay=double(find(handle(axH),'-class','graph2d.annotationlayer'));
    if isempty(overlay)
        overlay = findall(axH,'Tag','ScribeOverlayAxesActive');
    end
    
    if ~isempty(overlay)
        axes(overlay);
    end
end
