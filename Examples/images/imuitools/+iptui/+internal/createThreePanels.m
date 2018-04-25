function [hPanelTop, hPanelMiddle, hPanelBottom, layoutPosition] = createThreePanels(hParent, ratios, margin)
% createThreePanels - Create Panels used for histograms in HSV color space.
% Utility function for Color Thresholder app

% Copyright 2016 The MathWorks, Inc.  

% In order to honor the margin argument, do the computations in Pixel units.
origUnits = get(hParent, 'Units');
set(hParent, 'Units', 'Pixels');
drawnow  % Draw before querying position.

% Compute heights of each panel.
parentPosition = get(hParent, 'Position');

% Positions for panels when point cloud is hidden
parentHeight = parentPosition(4)*0.5;

panelHeights = (parentHeight - 4*margin) .* ratios;
panelWidth = parentPosition(3) - 2*margin;

panelPositionBottom = [margin, ...
                       margin, ...
                       panelWidth, ...
                       panelHeights(3)];

panelPositionMiddle = [margin, ...
                       panelPositionBottom(2) + panelPositionBottom(4) + margin, ...
                       panelWidth, ...
                       panelHeights(2)];

panelPositionTop = [margin, ...
                    panelPositionMiddle(2) + panelPositionMiddle(4) + margin, ...
                    panelWidth, ...
                    panelHeights(1)];
                
hPanelTop = uipanel('parent', hParent, 'Units', 'Pixels', 'Position', panelPositionTop,'tag','H');
hPanelMiddle = uipanel('parent', hParent, 'Units', 'Pixels', 'Position', panelPositionMiddle,'tag','S');
hPanelBottom = uipanel('parent', hParent, 'Units', 'Pixels', 'Position', panelPositionBottom,'tag','V');                
                
set([hPanelTop, hPanelMiddle, hPanelBottom], 'Units', 'normalized')

posFullLayout = {get(hPanelTop,'Position'),get(hPanelMiddle,'Position'),get(hPanelBottom,'Position')};

% Revert to Pixels to assign new position
set([hPanelTop, hPanelMiddle, hPanelBottom], 'Units', 'Pixels')

parentHeight = parentPosition(4)*0.4;
parentStart = parentPosition(4)*0.6;

panelHeights = (parentHeight - 4*margin) .* ratios;
panelWidth = (parentPosition(3) - 3*margin)/2;

panelPositionBottom = [2*margin + panelWidth, ...
    parentStart + margin, ...
    panelWidth, ...
    panelHeights(3)];

panelPositionMiddle = [2*margin + panelWidth, ...
    parentStart + margin + panelHeights(3), ...
    panelWidth, ...
    panelHeights(2)];

panelPositionTop = [margin, ...
    parentStart + margin, ...
    panelWidth, ...
    panelHeights(1)];

set(hPanelTop, 'Position', panelPositionTop);
set(hPanelMiddle, 'Position', panelPositionMiddle);
set(hPanelBottom, 'Position', panelPositionBottom);  

set(hParent, 'Units', origUnits);
set([hPanelTop, hPanelMiddle, hPanelBottom], 'Units', 'normalized', 'BorderType', 'line')               

posHalfLayout = {get(hPanelTop,'Position'),get(hPanelMiddle,'Position'),get(hPanelBottom,'Position')};
layoutPosition = [posHalfLayout, posFullLayout];

end