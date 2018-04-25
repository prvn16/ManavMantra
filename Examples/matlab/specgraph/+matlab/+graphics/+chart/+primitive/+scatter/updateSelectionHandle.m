function updateSelectionHandle(hObj, hSel, vd)

% updateSelectionHandle(obj,vd) given Scatter or TextScatter object obj
% and vertex data vd configure the SelectionHandle state during an update.

%   Copyright 2016 The MathWorks, Inc.

if strcmp(hObj.Visible,'on') && strcmp(hObj.Selected,'on') && strcmp(hObj.SelectionHighlight,'on')
    
    % Draw the Selection Handles
    xminvd = min(vd(1,:));
    xmaxvd = max(vd(1,:));
    yminvd = min(vd(2,:));
    ymaxvd = max(vd(2,:));
    zminvd = min(vd(3,:));
    zmaxvd = max(vd(3,:));
    if zminvd == zmaxvd
        if strcmp(hObj.DimensionNames{1},'X') 
            %in Cartesian coordinates, make a bounding box
            hSel.VertexData = ...
                [xminvd, xminvd, xmaxvd, xmaxvd;
                 yminvd, ymaxvd, yminvd, ymaxvd;
                 zminvd, zminvd, zminvd, zminvd];
        else
            %in Polar coordinates, just select 16 vertices
            nhandles = 16;
            inds = round(linspace(1,size(vd,2),nhandles));
            
            hSel.VertexData = ...
                [vd(1,inds); ...
                 vd(2,inds);...
                 vd(3,inds)];
        end

    else
        hSel.VertexData = ...
            [xminvd, xminvd, xmaxvd, xmaxvd, xminvd, xminvd, xmaxvd, xmaxvd;
             yminvd, ymaxvd, yminvd, ymaxvd, yminvd, ymaxvd, yminvd, ymaxvd;
             zminvd, zminvd, zminvd, zminvd, zmaxvd, zmaxvd, zmaxvd, zmaxvd];
    end
    hSel.Visible = 'on';
else
    hSel.Visible = 'off';
end
