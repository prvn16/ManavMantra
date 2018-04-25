function doLayout(hObj, updateState, showColorbar, showMissingDataColorbar)
% Layout the Axes and Colorbars

% Copyright 2016-2017 The MathWorks, Inc.

import matlab.graphics.chart.Chart

% Constants for use later.
gapAxesToColorbar = 10; % Space between Axes and Colorbar
minGapColorbarToEdge = 0; % Minimum space between Colorbar labels
% and right edge of OuterPosition box.
minColorbarWidth = 5; % Minimum colorbar width
maxColorbarWidth = 20; % Maximum colorbar width
minColorbarLabelWidth = 16; % Minimum space to allow for colorbar labels
maxGapBetweenColorbars = 10; % Maximum space between the two colorbars
maxMissingDataColorbarHeight = 20; % Maximum height of the bottom colorbar

% Get the outer position and units.
hAx = hObj.Axes;
outerPos = hAx.OuterPosition_I;
units = hAx.Units_I;

% Grab the Viewport for unit conversions
vp = hAx.Camera.Viewport;

% Convert the outer position into pixels and points
outerPosPixels = Chart.convertUnits(vp, 'devicepixels', units, outerPos);
outerPosPoints = Chart.convertUnits(vp, 'points', units, outerPos);

% If units are 'normalized', the LooseInset scales with the OuterPosition,
% but otherwise the LooseInset is a fixed size. This means if the user sets
% the units to something other than normalized, scaled the figure, then
% sets the units back to normalized, they the insets may have changed.
% In order to preserve the inset behavior that the user would see if we did
% not change the loose insets, every time the units change we need to
% convert the original loose insets to the new units.
if isempty(hObj.LooseInsetCache)
    % This is the first time running the layout, so get the LooseInsets
    % from the Axes for the first time.
    
    % matlab.graphics.general.UnitPosition is a value (not handle) class
    liCache = vp;
    
    % Normalized loose insets are interpreted relative to the outer
    % position, not the canvas viewport.
    liCache.RefFrame = outerPosPixels;
    liCache.Units = units;
    hObj.LooseInsetCache = liCache;
    hObj.LooseInsetCachePosition = hAx.LooseInset;
else
    % First update the reference frame to match the
    % new OuterPosition and update the screen resolution.
    lic = hObj.LooseInsetCache;
    lic.RefFrame = outerPosPixels;
    lic.ScreenResolution = vp.ScreenResolution;
    
    % Now update the units so that a conversion between normalized and
    % other units uses the new reference frame and screen resolution.
    lic.Units = units;
    
    % matlab.graphics.general.UnitPosition is a value (not handle) class
    hObj.LooseInsetCache = lic;
end

% Grab handles to the colorbars
cbar = hObj.Colorbar;
mcbar = hObj.MissingDataColorbar;

% Restore the original loose insets.
hAx.LooseInset_I = hObj.LooseInsetCachePosition;

outerPositionActive = strcmpi(hObj.ActivePositionProperty, 'outerposition');

if isempty(hObj.NodeParent)
    % GetLayoutInformation only works if there is a canvas available.
    return;
end

% Get the current axes layout information.
layoutInfoCache = hAx.GetLayoutInformation;
posPoints = Chart.convertUnits(vp, 'points', 'pixels', layoutInfoCache.Position);

if showColorbar
    % Calculate how much space is needed for the gap between the colorbar
    % and the colorbar tick labels.
    % This mimics the algorithm used by the Rulers.
    tickgap = cbar.Ruler.TickLabelGapOffset + ...
        cbar.FontSize_I*cbar.Ruler.TickLabelGapMultiplier;
    
    % Find out how much room the missing data label requires.
    % extents(1): Width of missing data label
    if showMissingDataColorbar
        extents = updateState.getStringBounds(hObj.MissingDataLabel,...
            matlab.graphics.general.Font('Name',hObj.FontName,...
            'Size',hObj.FontSize), 'none','on');
    else
        extents = [0 0];
    end
    
    % Calculate how much space is needed for ruler labels.
    % minColorbarLabelWidth: Minimum space to leave for labels on ruler
    colorbarLabelWidth = max(extents(1), minColorbarLabelWidth);
    
    % Calculate how much space is needed around the axes and colorbar.
    
    % gapAxesToColorbar: Space between axes and colorbar
    % posPoints(3): width of axes plot box
    spaceForAxesAndColorbar = posPoints(3) - gapAxesToColorbar;
    
    if outerPositionActive
        % Calculate how wide to make the colorbar. Aim for 15% of the final
        % width of the Axes, with a minimum of 5 and maximum of 20.
        colorbarWidth = (0.15/1.15)*spaceForAxesAndColorbar;
    else
        % Calculate how wide to make the colorbar. Aim for 15% of the final
        % width of the Axes, with a minimum of 5 and maximum of 20.
        colorbarWidth = 0.15*posPoints(3);
    end
    colorbarWidth = min(max(colorbarWidth,minColorbarWidth),maxColorbarWidth);
    
    % Calculate the minimum space needed to accomodate the colorbar.
    % colorbarLabelWidth: Space for colorbar tick labels
    % tickgap: Space between colorbar box and the colorbar tick labels
    colorbarRoomPoints = gapAxesToColorbar + colorbarWidth + tickgap + ...
        colorbarLabelWidth + minGapColorbarToEdge;
    
    % Determine the current loose insets in points.
    liUnitPos = hObj.LooseInsetCache;
    liUnitPos.Units = 'points';
    liPoints = liUnitPos.Position;
    liWithColorbarPoints = liPoints;
    % Attempt to place the colorbar so the right edge is where right edge
    % of the axes would be if the colorbar were not present.
    % Do this by adding the colorbar width plus the gap between axes and
    % colorbar to the loose insets.
    liWithColorbarPoints(3) = liPoints(3) + colorbarWidth + gapAxesToColorbar;
    
    % Make sure the right side has enough room to accomodate the colorbar
    % and still leave space between colorbar labels and the edge. At small
    % sizes, liPoints will be small, and need colorbarRoomPoints of space,
    % pushing the colorbar left of the ideal spot.
    % At large sizes, liPoints will be large, and we can keep the
    % right-edge of the colorbar box where the right edge of axes would be
    % without colorbar.
    liWithColorbarPoints(3) = max(liWithColorbarPoints(3), colorbarRoomPoints);
    
    % If the loose insets don't leave any room for the colorbars, then turn
    % them off.
    if outerPositionActive
        enoughRoomForColorbar = ...
            (outerPosPoints(3) >= (liWithColorbarPoints(1) + liWithColorbarPoints(3) + colorbarWidth));
    else
        enoughRoomForColorbar = true;
    end
    
    if ~enoughRoomForColorbar
        cbar.Visible = 'off';
        mcbar.Visible = 'off';
        showColorbar = false;
        
        ti = getTightInsetsPoints(layoutInfoCache, vp);
        
        hObj.ChartDecorationInset = Chart.convertDistances(vp, units , 'points', ti);
    else
        % Set the loose insets to make room for the colorbars.
        liUnits = Chart.convertUnits(liUnitPos, units, 'points', liWithColorbarPoints);
        hAx.LooseInset_I(3) = liUnits(3);
        
        if any(hObj.SubplotCellOuterPosition ~= 0)
            % If we are in a subplot layout, compute ChartDecorationInset
            % to be relative to largest colorbar size that would fit in the
            % subplot box.
            
            % After adjusting Axes for looseInset, update total decoration
            % sizes. TightInset can change significantly when tick-labels
            % rotate, so make sure this measurement taken after we apply
            % our best estimate of the actual axes size.
            ti = getTightInsetsPoints(layoutInfoCache, vp);
            
            subplotBoxPoints = Chart.convertUnits(vp, 'points', units, hObj.SubplotCellOuterPosition);
            
            fixedSizeDecorationsWidth = (gapAxesToColorbar + tickgap + ...
                colorbarLabelWidth + minGapColorbarToEdge);
            
            % Total horizontal space available for axes and colorbar
            axesAndColorbarWidth = subplotBoxPoints(3) - fixedSizeDecorationsWidth;
            
            % We know that colorbar box is 15% of axes box, so colorbar's
            % box can be at most this large:
            colorbarWidthMax = (0.15/1.15)*axesAndColorbarWidth;
            
            % Worst-case insets needed by the subplot will be:
            maxColorbarAndDecorationWidth = colorbarWidthMax + fixedSizeDecorationsWidth;
            oldChartDecorationInset = hObj.ChartDecorationInset_I;
            newChartDecorationInset =  ...
                Chart.convertDistances(vp, units , 'points', ...
                [ti(1),ti(2),maxColorbarAndDecorationWidth,ti(4)]);
            
            if ~isequal(newChartDecorationInset,oldChartDecorationInset)
                hObj.ChartDecorationInset = newChartDecorationInset;
            end
        end
    end
else
    % When no colorbar, no room needed for colorbar in subplot layout
    ti = getTightInsetsPoints(layoutInfoCache, vp);
    hObj.ChartDecorationInset = ...
        Chart.convertDistances(vp, units , 'points', ti);
end

if showColorbar
    % The axes may have moved due to changing the loose insets, especially
    % if a tick label changed rotation, so query the axes layout
    % information again.
    layoutInfoCache = hAx.GetLayoutInformation;
    plotBoxPoints = Chart.convertUnits(vp, 'points', 'pixels', layoutInfoCache.PlotBox);
    
    % Find the right edge of plot box.
    % Use plot box instead of decorated plot box because the axes y-axis is
    % on the left side of the axes, so the tick labels will not interfere
    % with the colorbars.
    rightEdge = plotBoxPoints(1) + plotBoxPoints(3);
    
    % Calculate the colorbar positions.
    if showMissingDataColorbar
        axesHeight = plotBoxPoints(4);
        gap = max(0, min(maxGapBetweenColorbars, axesHeight/4));
        mcBarHeight = max(0, min(maxMissingDataColorbarHeight, axesHeight/4));
        cbarHeight = max(axesHeight - mcBarHeight - gap, 0);
        
        % Position of main colorbar
        cbarPosPoints = [ ...
            rightEdge + gapAxesToColorbar, ... % Left edge
            plotBoxPoints(2)+gap+mcBarHeight, ... % Bottom
            colorbarWidth, cbarHeight]; % Width and Height
        
        % Position of missing data colorbar
        mcbarPosPoints = [...
            rightEdge + gapAxesToColorbar, ... % Left edge
            plotBoxPoints(2), ... % Bottom
            colorbarWidth, mcBarHeight]; % Width and Height
        
        % Set the units to match the heatmap units before setting position.
        if ~strcmp(mcbar.Units_I, units)
            mcbar.Units_I = units;
        end
        
        % Update the missing data colorbar position if it has changed.
        lastUnits = hObj.ColorbarPositionCache.Units;
        lastPosition = hObj.ColorbarPositionCache.MissingDataColorbar;
        newPosition = Chart.convertUnits(vp, units, 'points', mcbarPosPoints);
        if ~strcmp(lastUnits, units) || ...
                ~all(abs((newPosition - lastPosition)./newPosition) < 1e-4)
            mcbar.Position_I = newPosition;
            hObj.ColorbarPositionCache.MissingDataColorbar = newPosition;
        end
    else
        % Position of main colorbar
        cbarPosPoints = [ ...
            rightEdge + gapAxesToColorbar, ... % Left edge
            plotBoxPoints(2), ... % Bottom
            colorbarWidth plotBoxPoints(4)]; % Width and Height
    end
    
    % Set the units to match the heatmap units before setting position.
    if ~strcmp(cbar.Units_I, units)
        cbar.Units_I = units;
    end
    
    % Update the colorbar position if it has changed.
    lastUnits = hObj.ColorbarPositionCache.Units;
    lastPosition = hObj.ColorbarPositionCache.Colorbar;
    newPosition = Chart.convertUnits(vp, units, 'points', cbarPosPoints);
    if ~strcmp(lastUnits, units) || ...
            ~all(abs((newPosition - lastPosition)./newPosition) < 1e-4)
        cbar.Position_I = newPosition;
        hObj.ColorbarPositionCache.Colorbar = newPosition;
        hObj.ColorbarPositionCache.Units = units;
    end
end

end

function tightInsetPoints = getTightInsetsPoints(layout,vp)
% Compute the TightInset from the layout information

% TightInset is the difference between plot box and decorated plot box.
posPoints = matlab.graphics.chart.Chart.convertUnits(vp, 'points', 'pixels', layout.Position);
decPBPoints = matlab.graphics.chart.Chart.convertUnits(vp, 'points', 'pixels', layout.DecoratedPlotBox);

tightInsetPoints = [0,0,0,0];
tightInsetPoints(1:2) = [ ...
    posPoints(1) - decPBPoints(1), ... % left
    posPoints(2) - decPBPoints(2)]; % bottom
tightInsetPoints(3:4) = [ ...
    decPBPoints(3) - posPoints(3) - tightInsetPoints(1),... % right
    decPBPoints(4) - posPoints(4) - tightInsetPoints(2)]; % top

% TightInset is never less than 0.
tightInsetPoints(tightInsetPoints < 0) = 0;

end
