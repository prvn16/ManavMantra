function [newData, dataErr] = setXYDisplayData(oldData, data, dim)
% Reorder the display labels based on the new display data.
% Called from set.XDisplayData and set.YDisplayData.

% Inputs:
% oldData: m-by-2 string array. First column is the current display data
% values. Second column is the corresponding labels.
%
% data: n-by-1 string array specifying the new display data.
%
% dim: Either 'x' or 'y'. Used by validateXYData for error messages.

% Copyright 2017 The MathWorks, Inc.

import matlab.graphics.chart.HeatmapChart

% Set up default values.
newData = oldData;

% Validate the new data.
[data, dataErr] = HeatmapChart.validateXYData(data, dim);

% Reorder the stored data based on the new data.
if isempty(dataErr)
    % Determine which of the new items are existing items.
    [tf,loc] = ismember(data,oldData(:,1));

    % Create a new 2-column matrix of items and labels.
    newData = [data(:) data(:)];

    % Fill in the item labels from existing items.
    newData(tf,2) = oldData(loc(tf),2);
end
