function [limits, errorID] = validateXYLimitsAgainstData(limits, data)
% Validate the limits against the XData/YData.

% Copyright 2016 The MathWorks, Inc.

% If the data are empty, then set the limits back to the default.
if isempty(data)
    limits = string([NaN NaN]);
    errorID = '';
else
    % Compare the limits to the data.
    [isdata, loc] = ismember(limits, data);
    
    if ~all(isdata)
        % One (or both) of the limits are not in the data.
        errorID = 'MATLAB:graphics:heatmap:LimitsNotData';
        limits = data([1 end]);
    elseif loc(2)<loc(1)
        % Limits are out of order based on the data.
        errorID = 'MATLAB:graphics:heatmap:InvalidLimits';
        limits = data([1 end]);
    else
        errorID = '';
    end
end

end
