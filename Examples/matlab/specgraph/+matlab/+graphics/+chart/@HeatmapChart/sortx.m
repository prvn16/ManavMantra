function [colorDisplayData, xDisplayData] = sortx(hObj, varargin)
% SORTX Sort the columns of the heatmap color data matrix
%   SORTX(H) sorts the columns the heatmap color data matrix in ascending
%   order of the first row. When the first row has equal values, SORTX
%   sorts according to the next row and repeats this behavior for
%   succeeding equal values. SORTX will update XDisplayData and
%   ColorDisplayData to reflect the new sorting of the color data.
%
%   SORTX(H, ROW) sorts the columns of the heatmap color data matrix based
%   on the row(s) specified in the vector, ROW. For equal values, the
%   original order is preserved. ROW must be a cell array of character
%   vectors or a string vector of elements from YData or YDisplayData.
%
%   SORTX(H, ROW, DIRECTION) uses DIRECTION to specify the sort order.
%   DIRECTION can be string, a character vector, a string vector, or a cell
%   array of character vectors containing 'ascend' for ascending order
%   (default) or 'descend' for descending order.
%
%       When DIRECTION is a character vector or scalar string, SORTX
%       sorts in the specified direction for all rows in ROW.
%
%       When DIRECTION is a string vector or cell array of character
%       vectors, SORTX sorts in the specified direction for each row
%       in ROW.
%
%   SORTX(H, ROW, 'MissingPlacement',M) also specifies where to place the NaN
%   elements in the heatmap color data matrix. M must be:
%       'auto'  - (default) Places NaN elements last for ascending sort
%                 and first for descending sort.
%       'first' - Places NaN elements first.
%       'last'  - Places NaN elements last.
%
%   SORTX(H, ROW, DIRECTION, 'MissingPlacement',M) specifies both the sort
%   order and where to place NaN elements in the color data matrix.
%
%   B = SORTX( ___ ) returns the sorted color data matrix. The sorted color
%   data matrix can also be accessed via the ColorDisplayData property.
%
%   [B, XDATA] = SORTX( ___ ) also returns a cell array of character
%   vectors that reflects the new value of XDisplayData after sorting.

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
% sortDisplayData is written to sort rows, so switch xData and yData,
% switch xDisplayData and yDisplayData, and transpose colorData and
% colorDisplayData in order to accomodate sorting rows instead of columns.
% 'Y' is used for an error message regarding the row input.
[colorDisplayData, xDisplayData] = hObj.sortDisplayData( ...
    colorData', yData, xData, yDisplayData, xDisplayData, ...
    hObj.MissingDataValue, 'Y', varargin);

% Transpose colorDisplayData back to the correct orientation.
colorDisplayData = colorDisplayData';

% Reset the XLimits to show the full range of the XDisplayData.
hObj.XLimitsMode = 'auto';

% Set the XDisplayData so that XDisplayDataMode is toggled to 'manual'.
hObj.XDisplayData = xDisplayData;
xDisplayData = cellstr(xDisplayData);

if nargout < 1
    clear colorDisplayData
end
