function [colorDisplayData, errID, counts] = getColorDisplayData( ...
    rawColorData, xData, yData, xDisplayData, yDisplayData, missingDataValue, rawCounts)
% Return the ColorData sorted based on the XDisplayData and YDisplayData.

% Copyright 2016-2017 The MathWorks, Inc.

% Determine the size of the ColorData.
[ny,nx] = size(rawColorData);

% Determine whether to calculate counts.
calculateCounts = nargin == 7 && size(rawCounts,1) == ny && size(rawCounts,2) == nx;
if calculateCounts
    counts = rawCounts;
else
    counts = [];
end

% Validate the size of XData and YData with respect to the ColorData.
if numel(xData) ~= nx
    % XData does not match the number of columns in ColorData.
    errID = 'MATLAB:graphics:heatmap:XDataMismatch';
    colorDisplayData = rawColorData;
elseif numel(yData) ~= ny
    % YData does not match the number of rows in ColorData.
    errID = 'MATLAB:graphics:heatmap:YDataMismatch';
    colorDisplayData = rawColorData;
else
    % XData and YData match the size of ColorData.
    errID = '';
    
    % Determine if there are any values in XDisplayData or YDisplayData
    % that are not present in the XData/YData.
    [havexdata,xloc] = ismember(xDisplayData,xData);
    [haveydata,yloc] = ismember(yDisplayData,yData);
    
    if all(havexdata) && all(haveydata)
        % We have data for all the display data values, so just sort the
        % ColorData to match the sorting of the display data.
        colorDisplayData = rawColorData(yloc,xloc);

        % Calculate the corresponding counts.
        if calculateCounts
            counts = rawCounts(yloc,xloc);
        end
    else
        % Some display data values do not have matching data, so
        % pre-populate the output based on the missing data value, then
        % fill in the values we have data for.
        nx = size(xDisplayData,1);
        ny = size(yDisplayData,1);
        colorDisplayData = missingDataValue(ones(ny,nx));
        colorDisplayData(haveydata,havexdata) = ...
            rawColorData(yloc(haveydata),xloc(havexdata));

        % Calculate the corresponding counts.
        if calculateCounts
            counts = zeros(ny,nx);
            counts(haveydata,havexdata) = ...
                rawCounts(yloc(haveydata),xloc(havexdata));
        end
    end
end
