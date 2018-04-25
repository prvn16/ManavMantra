function [colorDisplayData, yDisplayData] = sortDisplayData( ...
    colorData, xData, yData, xDisplayData, yDisplayData, ...
    missingDataValue, dim, args)
% Helper function for sortx and sorty. The inputs are treated as though
% this function is sorty, and sortx will transpose and rearrange the inputs
% and outputs as necessary to convert from sorty to sortx.

% Inputs:
% xData, yData, colorData: Raw (unsorted) data. xData and yData will be
% swapped and colorData will be transposed when called by sortx.
%
% yData and yDisplayData: The dimension that are being sorted.
%
% xData and xDisplayData: Sort by this dimension.
%
% xDisplayData, yDisplayData: Will be swapped when called by sortx.
%
% missingDataValue: Scalar value used to fill in elements from
% colorDisplayData that are not in colorData.
%
% dim: Either 'X' (for sorty) or 'Y' (for sortx). Used in error message.
%
% args: Extra input arguments to pass on to sortrows.

% Copyright 2017 The MathWorks, Inc.

import matlab.graphics.chart.HeatmapChart

% Combine both XData and XDisplayData into one vector to allow sorting
% based on elements that are included in either list.
[xDisplayData, xa] = union(xDisplayData, xData, 'stable');

% Get the ColorDisplayData
[colorDisplayData, errID] = HeatmapChart.getColorDisplayData(colorData, ...
    xData, yData, xDisplayData, yDisplayData, missingDataValue);

% Throw an error if the XData or YData size did not match ColorData.
if ~isempty(errID)
    % sortx will transpose X and Y. Make sure that the error message
    % reflects the correct orientation.
    if strcmpi(dim,'Y')
        if contains(errID,'XDataMismatch')
            errID = 'MATLAB:graphics:heatmap:YDataMismatch';
        else
            errID = 'MATLAB:graphics:heatmap:XDataMismatch';
        end
    end
    throwAsCaller(MException(message(errID)));
end

% Determine which columns to use for sorting.
if numel(args) == 0 % sorty(h) or sortx(h)
    % If no input arguments were specified, sort based off the currently
    % visible XDisplayData, which is captured in the variable 'xa'.
    cols = xa;
else
    % Translate string, categorical, or character vector input into cell
    % array of character vectors.
    cols = args{1};
    if isstring(cols) || ischar(cols) || iscategorical(cols)
        cols = cellstr(cols);
    end
    
    % Make sure the sorting vector is a cell array of character vectors.
    if ~iscellstr(cols)
        throwAsCaller(MException(message('MATLAB:graphics:heatmap:InvalidSortingVector')));
    end
    
    % Translate the sorting vector into indexes.
    [tf,cols] = ismember(cols, xDisplayData);
    if ~all(tf)
        % Columns specified don't exist in XData or XDisplayData
        throwAsCaller(MException(message('MATLAB:graphics:heatmap:ElementsNotData',...
            [upper(dim) 'Data'],[upper(dim) 'DisplayData'])));
    end
end

try
    % Call sortrows
    [colorDisplayData,index] = sortrows(colorDisplayData, cols, args{2:end});

    % Collect the output
    yDisplayData = yDisplayData(index);
    colorDisplayData = colorDisplayData(:, xa);
catch sortErr
    % Rethrow the error from sortrows.
    throwAsCaller(sortErr);
end

end
