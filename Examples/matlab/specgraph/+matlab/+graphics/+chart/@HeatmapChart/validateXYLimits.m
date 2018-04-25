function [limits, err] = validateXYLimits(limits, data, checkData, dim)
% Convert the supplied XLimits/YLimits to strings, validate the limits have
% two elements with none missing, and validate against the XData/YData.

% Copyright 2016 The MathWorks, Inc.

import matlab.graphics.chart.HeatmapChart

% Determine the property names to use in error messages.
propName = [dim 'Limits'];
dataPropName = [dim 'DisplayData'];

% Convert the data to strings.
err = MException.empty();
if ~isstring(limits)
    % The limits supplied are not already strings.
    % Attempt to cast it to string.
    try
        limits = string(limits);
    catch stringErr
        limits = string([NaN NaN]);
        err = MException(message('MATLAB:graphics:heatmap:InvalidString', lower(dim)));
        err = addCause(err, stringErr);
    end
end

% Make sure the limits are a row vector.
limits = limits(:)';

if isempty(err)
    if numel(limits) ~= 2
        % The limits must be a 2 element string vector.
        err = MException(message('MATLAB:graphics:heatmap:InvalidLimits', propName, dataPropName));
    elseif any(ismissing(limits))
        % The limits cannot contain any missing elements.
        err = MException(message('MATLAB:graphics:heatmap:MissingValues', lower(dim)));
    elseif checkData
        % Check the limits against the data.
        [limits, errID] = HeatmapChart.validateXYLimitsAgainstData(limits, data);
        
        % Convert the message to an MException if necessary.
        if ~isempty(errID)
            err = MException(message(errID, propName, dataPropName));
        end
    end
end

end
