function [colorDisplayData, yDisplayData] = sorty(hObj, varargin)
% SORTY Sort the rows of the heatmap color data matrix
%   SORTY(H) sorts the rows the heatmap color data matrix in ascending
%   order of the first column. When the first column has equal values,
%   SORTY sorts according to the next column and repeats this behavior for
%   succeeding equal values. SORTY will update YDisplayData and
%   ColorDisplayData to reflect the new sorting of the color data.
%
%   SORTY(H, COLUMN) sorts the rows of the heatmap color data matrix based
%   on the column(s) specified in the vector, COLUMN. For equal values, the
%   original order is preserved. COLUMN must be a cell array of character
%   vectors or a string vector of elements from XData or XDisplayData.
%
%   SORTY(H, COLUMN, DIRECTION) uses DIRECTION to specify the sort order.
%   DIRECTION can be string, a character vector, a string vector, or a cell
%   array of character vectors containing 'ascend' for ascending order
%   (default) or 'descend' for descending order.
%
%       When DIRECTION is a character vector or scalar string, SORTY sorts
%       in the specified direction for all columns in COLUMN.
%
%       When DIRECTION is a string vector or cell array of character
%       vectors, SORTY sorts in the specified direction for each column in
%       COLUMN.
%
%   SORTY(H, COLUMN, 'MissingPlacement',M) also specifies where to place the NaN
%   elements in the heatmap color data matrix. M must be:
%       'auto'  - (default) Places NaN elements last for ascending sort
%                 and first for descending sort.
%       'first' - Places NaN elements first.
%       'last'  - Places NaN elements last.
%
%   SORTY(H, COLUMN, DIRECTION, 'MissingPlacement',M) specifies both the
%   sort order and where to place NaN elements in the color data matrix.
%
%   B = SORTY( ___ ) returns the sorted color data matrix. The sorted color
%   data matrix can also be accessed via the ColorDisplayData property.
%
%   [B, YDATA] = SORTY( ___ ) also returns a cell array of character
%   vectors that reflects the new value of YDisplayData after sorting.

%   Copyright 2016-2017 The MathWorks, Inc.

% Collect the data to pass into sortDisplayData. Getting ColorDisplay will
% trigger updateData if necessary. Once the data is updated internal data
% properties are used.
colorData = hObj.ColorData;
xData = hObj.XData_I;
yData = hObj.YData_I;
xDisplayData = hObj.XDisplayData_I;
yDisplayData = hObj.YDisplayData_I;

% Call sortDisplayData
% 'X' is used for an error message regarding the column input.
[colorDisplayData, yDisplayData] = hObj.sortDisplayData( ...
    colorData, xData, yData, xDisplayData, yDisplayData, ...
    hObj.MissingDataValue, 'X', varargin);

% Reset the YLimits to show the full range of the YDisplayData.
hObj.YLimitsMode = 'auto';

% Set the YDisplayData so that YDisplayDataMode is toggled to 'manual'.
hObj.YDisplayData = yDisplayData;
yDisplayData = cellstr(yDisplayData);

if nargout < 1
    clear colorDisplayData
end
