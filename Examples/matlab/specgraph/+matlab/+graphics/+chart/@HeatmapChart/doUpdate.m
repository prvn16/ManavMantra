function doUpdate(hObj, updateState)
% doUpdate for HeatmapChart

% Copyright 2016-2017 The MathWorks, Inc.

% Disable interactions during the update and reenable them when the update
% is finished. If an error occurs during the update, this will disable
% interactions until the error is resolved.
hObj.EnableInteractions = false;

% Update the controller in case the heatmap has been moved to a new parent.
hController = hObj.Controller;
if isscalar(hController) && isvalid(hController)
    hController.updateListeners();
end

% Get the ColorDisplayData
% get.ColorDisplayData will trigger a call to updateData if necessary,
% which will recalculate the data from the table and then update the XData,
% YData, and ColorData with the results.
colorData = hObj.ColorDisplayData;

% Get the current XDisplayData and YDisplayData
xData = cellstr(hObj.XDisplayData_I);
yData = cellstr(hObj.YDisplayData_I);

% Update the ColorData on the Heatmap object.
hObj.Heatmap.ColorData = colorData;

% Remove x-tick labels that are hidden.
xLabels = hObj.XDisplayLabels;
[tf, loc] = ismember(hObj.HideXDisplayLabels, xData);
xLabels(loc(tf)) = {''};

% Remove y-tick labels that are hidden.
yLabels = hObj.YDisplayLabels;
[tf, loc] = ismember(hObj.HideYDisplayLabels, yData);
yLabels(loc(tf)) = {''};

% Update the Categories and ticks on the x-axis.
xAxis = hObj.XAxis;
xAxis.Categories = xData;
xAxis.TickValues = xData;
xAxis.TickLabels = xLabels;

% Update the Categories and ticks on the y-axis.
yAxis = hObj.YAxis;
yAxis.Categories = yData;
yAxis.TickValues = yData;
yAxis.TickLabels = yLabels;

% Update the XLimits on the Ruler.
hAx = hObj.Axes;
xLimits = categorical(hObj.XLimits_I);
if all(ismissing(xLimits)) || isempty(xData)
    xAxis.LimitsMode = 'auto';
    hAx.DataSpace.XLim = [0.5 1.5];
else
    xAxis.Limits = xLimits;
    hAx.DataSpace.XLim = xAxis.makeNumeric(xLimits)+[-0.5 0.5];
end

% Update the YLimits on the Ruler.
yLimits = categorical(hObj.YLimits_I);
if all(ismissing(yLimits)) || isempty(yData)
    yAxis.LimitsMode = 'auto';
    hAx.DataSpace.YLim = [0.5 1.5];
else
    yAxis.Limits = yLimits;
    hAx.DataSpace.YLim = yAxis.makeNumeric(yLimits)+[-0.5 0.5];
end

% Update the ColorLimits
if strcmp(hObj.ColorLimitsMode, 'auto')
    % Set the limits on the ColorSpace based on the limits reported by the
    % Heatmap object.
    colorExtents = hObj.Heatmap.getColorDataExtents;
    if all(isfinite(colorExtents))
        % If the ColorData is scalar or uniform, the limits may be equal.
        if colorExtents(1) == colorExtents(2)
            colorExtents = colorExtents + [-1 1];
        end
        
        hObj.ColorLimits_I = colorExtents;
    elseif strcmp(hObj.ColorScaling, 'log')
        % No valid ColorData on a log scale, reset the color limits to the
        % default.
        
        % On a log-scale axes, the default limits are [0.1 1].
        % Take the log so that [0.1 1] shows up on the Colorbar ticks.
        hObj.ColorLimits_I = log([0.1 1]);
    else
        % No valid ColorData, reset the color limits to the default.
        hObj.ColorLimits_I = [0 1];
    end
end

% Set the limits on the ColorSpace to the specified limits.
hAx.ColorSpace.CLim = hObj.ColorLimits_I;

% Decide which colorbars to display.
mcbarVisible = hObj.ColorbarVisible;
if strcmp(hObj.ColorbarVisible, 'off')
    % Record that the colorbars are off for the layout.
    showColorbar = false;
    showMissingDataColorbar = false;
elseif any(isnan(hObj.Heatmap.ScaledColorData(:)))
    % Record that the colorbars are on for the layout.
    showColorbar = true;
    showMissingDataColorbar = true;
else
    % Turn off the missing data colorbar.
    mcbarVisible = 'off';
    
    % Record that just the regular colorbar is on for the layout.
    showColorbar = true;
    showMissingDataColorbar = false;
end

% Grab handles to the colorbars
cbar = hObj.Colorbar;
mcbar = hObj.MissingDataColorbar;

% Make sure the colorbar visibility is accurate in case they were
% previously turned off due to layout restrictions.
cbar.Visible = hObj.ColorbarVisible;
mcbar.Visible = mcbarVisible;

% Special treatment for log-scale color scaling
if showColorbar
    if strcmp(hObj.ColorScaling, 'log')
        scaleColormapWithLimits = false;
        if all(colorData(:) <= 0) && ~all(colorData(:) == 0)
            % Negative log-scale.
            limits = -exp(-hObj.ColorLimits_I);
        else
            % Positive log-scale.
            limits = exp(hObj.ColorLimits_I);
        end
        scale = 'log';
    else
        scaleColormapWithLimits = true;
        limits = hObj.ColorLimits_I;
        scale = 'linear';
    end
    
    if cbar.ScaleColormapWithLimits ~= scaleColormapWithLimits
        % Only toggle the value if it has changed to avoid marking the
        % colorbar dirty.
        cbar.ScaleColormapWithLimits = scaleColormapWithLimits;
    end
    if ~isequal(cbar.Limits_I, limits)
        % Only toggle the limits if they have changed to avoid marking the
        % colorbar dirty.
        cbar.Limits = limits;
    end
    cbar.Ruler.Scale = scale;
end

% Lay out the axes and colorbar
doLayout(hObj, updateState, showColorbar, showMissingDataColorbar)

% Re-enable interactions.
hObj.EnableInteractions = true;

end
