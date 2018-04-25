function [ objPos ] = getPositionForLockedPlotBox(obj,moveType,point)
% This undocumented function may be removed in a future release.

% Copyright 2016 The MathWorks, Inc.

% Objects (axes) created with a locked Plotbox aspect ratio such as axis square,
% has special resize logic. The axes is resized so that the plot box
% aspect is always preserved. For such axes only one dimension is derived based on the mouse position and
% the rest of the parameters are calculated.

% old positions (in pixels):
hFig = ancestor(obj,'Figure');
hAncestor = get(obj,'Parent');
objPos = hgconvertunits(hFig,get(obj,'Position'),get(obj,'Units'),'Pixels',hAncestor);   

XL = objPos(1);
XR = objPos(1) + objPos(3);
YU = objPos(2) + objPos(4);
YL = objPos(2);

try
    % try to get the PlotBoxAspectRatio, polar axes does not have this
    % property.
    plotBoxAspect = obj.PlotBoxAspectRatio(1:2);
catch
    plotBoxAspect = [1,1];
end

% get the plotbox aspect ratio y to x
y2xRatio = plotBoxAspect(2)/plotBoxAspect(1);

% move the appropriate x/y values
switch moveType
    case 'topleft'
        %get the new X coordinate, when dragging from the topleft
        %corner, the bottom right corner should be at the fixed
        %position
        XL = point(1);
        
        objPos(1) = XL;
        % the Y coordinate will be unchanged since the bottom right
        % corner of the axes should not move
        objPos(2) = YL;
        % calculate the new width of the axes
        objPos(3) = XR - XL;
        % get the height by multiplying the width by the plot box
        % aspect ratio
        objPos(4) = objPos(3) * y2xRatio;
        
    case 'topright'
        XR = point(1);
        
        objPos(1) = XL;
        objPos(2) = YL;
        objPos(3) = XR - XL;
        objPos(4) = objPos(3) * y2xRatio;
        
    case {'bottomright','right'}
        XR = point(1);
        
        objPos(1) = XL;
        objPos(3) = XR - XL;
        objPos(4) = objPos(3)* y2xRatio;
        objPos(2) = YU - objPos(3)* y2xRatio;
        
    case {'bottomleft','left'}
        XL = point(1);
        
        objPos(1) = XL;
        objPos(3) = XR - XL;
        objPos(4) = objPos(3) * y2xRatio;
        objPos(2) = YU - objPos(3)* y2xRatio;
        
    case 'top'
        YU = point(2);
        
        objPos(1) = XL;
        objPos(2) = YL;
        objPos(4) = YU - YL;
        objPos(3) = objPos(4)* 1/y2xRatio;
        
    case 'bottom'
        YL = point(2);
        
        objPos(1) = XL;
        objPos(2) = YL;
        objPos(4) = YU - YL;
        objPos(3) = objPos(4)* 1/y2xRatio;
        
    otherwise
        return;
end

end

